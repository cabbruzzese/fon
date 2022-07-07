const MAXXPHIT = 125;
const XPMULTI = 1000;
const STATNUM = 5;
const START_HEALTH = 75;
const REGENERATE_TICKS_MAX_DEFAULT = 80;
const REGENERATE_MIN_VALUE = 15;

const STAFF_LEVEL_SPREAD = 10;
const ICE_LEVEL_BREATH = 16;
const STAFF_LEVEL_CHARGE = 22;
const TORNADO_LEVEL_LIGHTNING = 28;

const FEROCITY_LEVEL_ENERGY = 12;
const FEROCITY_LEVEL_REGEN = 16;

class fonPlayer : HNecroPlayer replaces HNecroPlayer
{
	int initStrength;
	int initDexterity;
	int initMagic;
	int regenerateTicks;
	int regenerateTicksMax;

	property InitStrength : initStrength;
	property InitDexterity : initDexterity;
	property InitMagic : initMagic;
	property RegenerateTicks : regenerateTicks;
	property RegenerateTicksMax : regenerateTicksMax;

	PlayerLevelItem levelItem;
	property LevelItem : levelItem;

	Default
	{
		fonPlayer.RegenerateTicks 0;
		fonPlayer.RegenerateTicksMax REGENERATE_TICKS_MAX_DEFAULT;

		fonPlayer.InitStrength 5;
		fonPlayer.InitDexterity 5;
		fonPlayer.InitMagic 5;

        Health START_HEALTH;
        Player.MaxHealth START_HEALTH;

		Player.StartItem "fonStaff", 1;
		Player.StartItem "fonSword", 1;
		Player.StartItem "HNecroWeaponStaffAmmo", 50;
		Player.StartItem "HNecroWeaponMorphAmmo", 50;
	}

	double GetScaledMod(int stat)
	{
		//First 10 scales to 1 by 10% increments
		if (stat <= 10)
			return stat * 0.1;
		
		//Remaining scales at 3.4% increments. 40 = double damage
		return 1 + ((stat - 10) * 0.034);
	}
	
	int GetModDamage(int damage, int stat, int scaled)
	{
		double mod = stat / 10.0;
		if (scaled)
			mod = GetScaledMod(stat);

		let modDamage = damage * mod;
		if (modDamage < 1)
			return 1;

		return modDamage;
	}
	
	int GetDamageForMagic(int damage)
	{
		let statItem = GetStats();
		return GetModDamage(damage, statItem.Magic, 1);
	}

	Class<Inventory> ClassTypeBag(Class<Inventory> className)
	{
		Class<Inventory> result = classname;
		return result;
	}

	void Heal(int amount)
	{
		//don't heal if dead
		if (Health <= 0)
			return;
		
		//Only heal if health is below max
		if (Health < MaxHealth)
		{
			int newHealth = Min(Health + amount, MaxHealth);
			A_SetHealth(newHealth);
		}
	}

	const AMMO_MAX_SWORD = 50;
	const AMMO_MAX_STAFF = 100;
	const AMMO_MAX_RING = 50;
	const AMMO_MAX_TORNADO = 50;
	const AMMO_MAX_PISTOL = 30;
	const AMMO_MAX_GRENADE = 30;
	const AMMO_MAX_SCYTHE = 50;
	const AMMO_MAX_MORPH = 100;

	int GetNewAmmoMax(int baseMax, int stat)
	{
		double scaleMod = GetScaledMod(stat);
		return baseMax * scaleMod;
	}

	Ammo GetAmmoType (Class<Inventory> ammoName)
	{
		let playerObj = GetPlayerOrMorph(self);

		let ammoItem = Ammo(playerObj.FindInventory(ammoName));
		if (ammoItem == null)
		{
			ammoItem = Ammo(playerObj.GiveInventoryType(ammoName));
			ammoItem.Amount = 0;
		}

		return ammoItem;
	}

	void SetAmmoTypeMax(Class<Inventory> ammoName, int baseMax, int stat)
	{
		let ammoItem = GetAmmoType(ammoName);
		int newAmmoMax = GetNewAmmoMax(baseMax, stat);

		ammoItem.MaxAmount = newAmmoMax;
	}

	void SetAmmoMax(PlayerLevelItem statItem)
	{
		if (!statItem)
			return;
		
		if (!player)
			return;

		SetAmmoTypeMax("HNecroWeaponSwordAmmo", AMMO_MAX_SWORD, statItem.Magic);
		SetAmmoTypeMax("HNecroWeaponStaffAmmo", AMMO_MAX_STAFF, statItem.Magic);
		SetAmmoTypeMax("HNecroWeaponIceRingAmmo", AMMO_MAX_RING, statItem.Magic);
		SetAmmoTypeMax("HNecroWeaponTornadoAmmo", AMMO_MAX_TORNADO, statItem.Magic);
		SetAmmoTypeMax("HNecroWeaponPistolAmmo", AMMO_MAX_PISTOL, statItem.Strength);
		SetAmmoTypeMax("HNecroWeaponGrenadeAmmo", AMMO_MAX_GRENADE, statItem.Strength);
		SetAmmoTypeMax("HNecroWeaponScytheAmmo", AMMO_MAX_SCYTHE, statItem.Magic);
		SetAmmoTypeMax("HNecroWeaponMorphAmmo", AMMO_MAX_MORPH, statItem.Dexterity);
	}

	const HEALTH_MAX_BASE = 50;
	const HEALTH_MAX_STEP = 5;
	void SetHealthMax (PlayerLevelItem statItem)
	{
		int maxHealthStep = HEALTH_MAX_STEP * statItem.Strength;
		int maxHealthNew = HEALTH_MAX_BASE + maxHealthStep;
		int healthDifference = maxHealthNew - MaxHealth;

		MaxHealth = maxHealthNew;
		statItem.MaxHealth = maxHealthNew;

		if (Health < maxHealthNew)
		{
			int healthHealed = Min(maxHealthNew, Health + healthDifference);
			A_SetHealth(healthHealed);
		}

		let altPawn = PlayerPawn(Alternative);
		if (altPawn)
		{
			altPawn.MaxHealth = MaxHealth;
			altPawn.A_SetHealth(Health);
		}
	}

	void UpdateLevelStats(PlayerLevelItem statItem)
	{
		SetAmmoMax(statItem);
		SetHealthMax(statItem);
	}

	int CalcXPNeeded(PlayerLevelItem statItem)
	{
		return statItem.ExpLevel * XPMULTI;
	}
	
	void GiveXP (PlayerLevelItem statItem, int expEarned)
	{
		statItem.Exp += expEarned;
		
		while (statItem.Exp >= statItem.ExpNext)
		{
			GainLevel(statItem);
		}
	}
	
	virtual void BasicStatIncrease(PlayerLevelItem statItem)
	{		
	}
	
	void DoBlend(Color color, float alpha, int tics)
	{
		A_SetBlend(color, alpha, tics);
	}

	void DoLevelGainBlend(PlayerLevelItem statItem)
	{
		DoBlend("77 77 77", 0.8, 40);
		
		string lvlMsg = String.Format("You are now level %d", statItem.ExpLevel);
		A_Print(lvlMsg);
	}
	
	void GainLevelHealth(PlayerLevelItem statItem)
	{
		if (Health < MaxHealth)
		 	A_SetHealth(MaxHealth);

		let altPawn = PlayerPawn(Alternative);
		if (altPawn && altPawn.Health < MaxHealth)
			altPawn.A_SetHealth(MaxHealth);
	}

	//Gain a level
	void GainLevel(PlayerLevelItem statItem, bool isNoBlend = false)
	{
		if (statItem.Exp < statItem.ExpNext)
			return;

		statItem.ExpLevel++;
		statItem.Exp = statItem.Exp - statItem.ExpNext;
		statItem.ExpNext = CalcXpNeeded(statItem);
		
		A_GiveInventory("ExpStrItem", STATNUM);
		A_GiveInventory("ExpDexItem", STATNUM);
		A_GiveInventory("ExpMagItem", STATNUM);

		if (!isNoBlend)
			DoLevelGainBlend(statItem);
		
		//BasicStatIncrease to call overrides in classes
		BasicStatIncrease(statItem);
		
		GainLevelHealth(statItem);
			
		UpdateLevelStats(statItem);
	}

	void XPStatIncrease(int StatType)
	{
		let statItem = GetStats();

		if (StatType == STAT_TYPE_STR)
			statItem.Strength += 1;
		else if (StatType == STAT_TYPE_DEX)
		{
			statItem.Dexterity += 1;
			GiveDexSkill(statItem.Dexterity);
		}
		else if (StatType == STAT_TYPE_MAG)
		{
			statItem.Magic += 1;
			GiveMagicSkill(statItem.Magic);
		}

		UpdateLevelStats(statItem);
	}

	void GiveMagicSkill(int magicVal)
	{
		switch (magicVal)
		{
			case STAFF_LEVEL_CHARGE:
				A_Print("$TXT_SKILLSTAFFCHARGE");
				break;
			case STAFF_LEVEL_SPREAD:
				A_Print("$TXT_SKILLSTAFFSPREAD");
				break;
			case ICE_LEVEL_BREATH:
				A_Print("$TXT_SKILLICEBREATH");
				break;
			case TORNADO_LEVEL_LIGHTNING:
				A_Print("$TXT_SKILLTORNADOLIGHTNING");
				break;
		}
	}

	void GiveDexSkill(int dexVal)
	{
		switch (dexVal)
		{
			case FEROCITY_LEVEL_ENERGY:
				A_Print("$TXT_SKILLENERGY");
				break;
			case FEROCITY_LEVEL_REGEN:
				A_Print("$TXT_SKILLREGEN");
				break;
		}
	}

    void DoXPHit(Actor xpSource, int damage, name damagetype)
	{
        if (damage <= 0)
            return;
        
        if (!xpSource)
            return;

        if (!xpSource.bISMONSTER)
            return;

        int xp = Min(damage, MAXXPHIT);

		let statItem = GetStats();
        GiveXP(statItem, xp);
	}

	const ENERGY_GAIN_MAX = 20;
	void DoMonsterKill(Actor victim)
	{
		let statItem = GetStats();
		if (Health > 0 && victim && statItem.Dexterity >= FEROCITY_LEVEL_ENERGY)
		{
			int energyGain = Min(statItem.Dexterity / 3, ENERGY_GAIN_MAX);
			A_GiveInventory("HNecroWeaponMorphAmmo", energyGain);

			A_PrintBold(String.Format("Energy Drain: %d", energyGain));

			let altPawn = PlayerPawn(Alternative);
			if (altPawn)
			{
				altPawn.A_GiveInventory("HNecroWeaponMorphAmmo", energyGain);
			}
		}
	}

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		let statItem = GetStats();
		SetAmmoMax(statItem);

		MaxHealth = statItem.MaxHealth;

		let playerObj = GetPlayerOrMorph(self);

		let expItem = Inventory(playerObj.FindInventory("ExpSquishItemGiver"));
		if (expItem == null)
			expItem = playerObj.GiveInventoryType("ExpSquishItemGiver");

		//Set minimum spawn level in multiplayer
		if (multiplayer || DEBUG_MODE)
		{
			CVar minLevelSetting = CVar.FindCVar('xrpg_minlevel');

        	if(minLevelSetting)
        	{
				while (statItem.ExpLevel < minLevelSetting.GetInt())
				{
					statItem.Exp = statItem.ExpNext;
					GainLevel(statItem, true);

					statItem.Exp = 0;
				}
			}
		}
	}

	PlayerLevelItem GetStats()
	{
		let playerObj = GetPlayerOrMorph(self);

		if (levelItem == null)
		{
			levelItem = PlayerLevelItem(playerObj.GiveInventoryType("PlayerLevelItem"));
			levelItem.Strength = InitStrength;
			levelItem.Dexterity = InitDexterity;
			levelItem.Magic = InitMagic;
			levelItem.MaxHealth = MaxHealth;
		}

		return levelItem;
	}

	ui PlayerLevelItem GetUIStats()
	{
		let playerObj = GetPlayerOrMorphUI(self);
		
		return LevelItem;
	}

	int GetStrength()
	{
		let statItem = GetStats();
		return statItem.Strength;
	}

	int GetMagic()
	{
		let statItem = GetStats();
		return statItem.Magic;
	}

	void RegenerateHealth(int regenMax)
	{
		regenMax = Max(regenMax, REGENERATE_MIN_VALUE);
		regenMax = Min(regenMax, MaxHealth / 2);
		if (Health < regenMax)
			GiveBody(1);
		
		let altPawn = PlayerPawn(Alternative);
		if (altPawn && altPawn.Health < regenMax)
			altPawn.GiveBody(1);
	}

	virtual void Regenerate(PlayerLevelItem statItem)
	{ 
		if (statItem.Dexterity >= FEROCITY_LEVEL_REGEN)
		{
			int regenMax = statItem.Dexterity + REGENERATE_MIN_VALUE;
			RegenerateHealth(regenMax);
		}
	}

	override void Tick()
	{
		RegenerateTicks++;
		if (RegenerateTicks > RegenerateTicksMax)
		{
			RegenerateTicks = 0;

			if (Health > 0)
			{
				let statItem = GetStats();
				Regenerate(statItem);
			}
		}

		Super.Tick();
	}

	override void PreMorph(Actor mo, bool current)
	{
		let newPawn = PlayerPawn(mo);
		if (newPawn)
		{
			//keep max health
			let statItem = GetStats();
			newPawn.MaxHealth = statItem.MaxHealth;
		}
	}


	override void OnRespawn()
	{
		Super.OnRespawn();

		let statItem = GetStats();

		MaxHealth = statItem.MaxHealth;
		A_SetHealth(MaxHealth);
	}

	static fonPlayer GetPlayerOrMorph(Actor obj)
	{
		if (!obj)
			return null;

		PlayerPawn pawn = PlayerPawn(obj);

		if (!pawn)
			return null;
		
		fonPlayer fonPlayerObj = fonPlayer(pawn);
		if (fonPlayerObj)
			return fonPlayerObj;

		if (!pawn.Alternative)
			return null;

		fonPlayerObj = fonPlayer(pawn.Alternative);
		return fonPlayerObj;
	}

	static ui fonPlayer GetPlayerOrMorphUI(Actor obj)
	{
		if (!obj)
			return null;

		PlayerPawn pawn = PlayerPawn(obj);

		if (!pawn)
			return null;
		
		fonPlayer fonPlayerObj = fonPlayer(pawn);
		if (fonPlayerObj)
			return fonPlayerObj;

		if (!pawn.Alternative)
			return null;
		
		fonPlayerObj = fonPlayer(pawn.Alternative);
		return fonPlayerObj;
	}
}