const MAXXPHIT = 125;
const XPMULTI = 1000;
const STATNUM = 5;
const START_HEALTH = 75;
const REGENERATE_TICKS_MAX_DEFAULT = 128;
const REGENERATE_MIN_VALUE = 15;

const STAFF_LEVEL_SPREAD = 12;
const ICE_LEVEL_BREATH = 18;
const STAFF_LEVEL_CHARGE = 24;
const TORNADO_LEVEL_LIGHTNING = 30;

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
		Player.StartItem "HNecroWeaponMorphAmmo", 100;
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
	const AMMO_MAX_MORPH = 50;

	int GetNewAmmoMax(int baseMax, int stat)
	{
		double scaleMod = GetScaledMod(stat);
		return baseMax * scaleMod;
	}

	Ammo GetAmmoType (Class<Inventory> ammoName)
	{
		let ammoItem = Ammo(FindInventory(ammoName));
		if (ammoItem == null)
		{
			ammoItem = Ammo(GiveInventoryType(ammoName));
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
	}

	void UpdateLevelStats(PlayerLevelItem statItem)
	{
		SetAmmoMax(statItem);
		SetHealthMax(statItem);
		//Ammo max 
		//Gain 1 AC (5%) per 10 Dex
		//int armorMod = statItem.Dexterity / 2;
		//armorMod = Max(armorMod, 0);
		//armorMod = Min(armorMod, MAX_LEVEL_ARMOR);
		
		//let hArmor = HexenArmor(FindInventory("HexenArmor"));
		//if (hArmor)
			//hArmor.Slots[4] = armorMod;
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
			statItem.Dexterity += 1;
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

	override void PostBeginPlay()
	{
		Super.PostBeginPlay();

		let statItem = GetStats();
		SetAmmoMax(statItem);

		MaxHealth = statItem.MaxHealth;

		let expItem = Inventory(FindInventory("ExpSquishItemGiver"));
		if (expItem == null)
			expItem = GiveInventoryType("ExpSquishItemGiver");

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
		let lvlItem = PlayerLevelItem(FindInventory("PlayerLevelItem"));
		if (lvlItem == null)
		{
			lvlItem = PlayerLevelItem(GiveInventoryType("PlayerLevelItem"));
			lvlItem.Strength = InitStrength;
			lvlItem.Dexterity = InitDexterity;
			lvlItem.Magic = InitMagic;
			lvlItem.MaxHealth = MaxHealth;
		}

		return lvlItem;
	}

	ui PlayerLevelItem GetUIStats()
	{
		let lvlItem = PlayerLevelItem(FindInventory("PlayerLevelItem"));
		
		return lvlItem;
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
		if (Health < regenMax)
			GiveBody(1);
	}

	virtual void Regenerate(PlayerLevelItem statItem) { }

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

		//let statItem = GetStats();
        //GiveXP(statItem, 3);
	}

	override void OnRespawn()
	{
		Super.OnRespawn();

		let statItem = GetStats();

		MaxHealth = statItem.MaxHealth;
		A_SetHealth(MaxHealth);
	}
}