//-----------------------------------------------------------------------------
// Code modified by from HON for Feat of Necromancy Mod. Original license below
//                      - peewee
//-----------------------------------------------------------------------------
//
// Copyright 2019-2022 HON Team, Frechou Games
// Copyright 1993-2022 GZDoom Team, id Software, and contributors
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see http://www.gnu.org/licenses/
//
//-----------------------------------------------------------------------------

class fonMorphWyvern : HNecroPlayerBase replaces HNecroPlayerMorphWyvern
{
	override void Tick()
	{
		if(health > 0 && !CountInv("fonMorphWyvernFlight"))
			A_GiveInventory("fonMorphWyvernFlight");
		Super.Tick();
	}

	override float FrictionAmount()
	{
		float b = GetCVar("HoN_Debug_PlayerFriction");
		if (b == 0.0)
			return 1.0;
		else
			return b;
	}

	Default
	{
		Height 40;
		Player.DisplayName "Wyvern";
		Player.SoundClass "Wyvern";
		Player.MorphWeapon "fonWeaponWyvern";
		Player.AttackZOffset 0;
		XScale 0.6;
		YScale 0.5;
		PainSound "wyvern/pain";
		DeathSound "wyvern/death";
		Player.ForwardMove 0.5, 0.5;
		Player.SideMove 0.5, 0.5;
		FloatSpeed 1;
		DamageFactor 1.3;
	}

	States
	{
	Spawn:
		wyve ab 3;
		wyve c 3 A_StartSound("wyvern/flap");
		wyve def 3;
		loop;
	Attack1:
		wyve gh 4 Light("WYVERNBLAST");
		wyve ij 4 Light("WYVERNBLAST2");
		Goto Spawn;
	Attack2:
		wyve klm 3;
		wyve n 35 BRIGHT;
		goto Spawn;
	Pain:
		wyve o 5;
		wyve o 5 A_Pain;
		Goto Spawn;
	Death:
		wyve p 5;
		wyve q 5 A_ScreamAndUnblock();
		wyve rstuvwx 5;
		wyve y -1;
		stop;
	Death.Ice:
		wyve z 52 A_HoNFreezeDeath;
		wyve z 1 A_HoNFreezeDeathChunks;
		Stop;
	}
	override void PlayAttacking(){}
	override void PlayAttacking2(){}
	override void PlayRunning(){}
}

const WYVERN_CHARGE_MAX = 15;
const WYVERN_DASH_COST = 20;
const WYVERN_THRUST_VAL = 40;
const WYVERN_THRUST_CHECKRANGE = 96;
const WYVERN_EXPLODE_RANGE = 100;
const WYVERN_EXPLODE_DAMAGE = 80;
const WYVERN_EXPLODE_THRUST = 50;
class fonWeaponWyvern: HNecroPlayerWeaponWyvern replaces HNecroPlayerWeaponWyvern
{
	int chargeValue;
    property ChargeValue : chargeValue;

    Default
    {
        fonWeaponWyvern.ChargeValue 0;
    }

	States
	{
	Ready:
	WYVW A 1 {
            invoker.ChargeValue = 0;
            A_HoNMorphWeaponReady();
        }
		Loop;
	Fire:
		WYVW A 4 A_SetPlayerState("Attack1");
    Hold:
        WYVW B 2 A_ChargeUp;
        WYVW B 0 A_CheckDex(FEROCITY_LEVEL_WYVERNFLY, "FireFinish", WYVERN_DASH_COST);
        WYVW B 0 A_Refire;
	FireFinish:
		WYVW B 2;
		WYVW BCD 4;
		WYVW E 4 A_fonWyvernBlastPlayer;
		WYVW FGB 4;
		Goto Ready;
	DashAttack:
		WYVW EEEEEE 3 bright Light("WYVERNBLAST2") A_fonDashAttack;
	DashAttackFinish:
		WYVW FGB 4;
		WYVW A 12;
		Goto Ready;
	}

	action void A_ChargeUp()
	{
		invoker.ChargeValue++;
        int quakeIntensity = 0;
		if (invoker.chargeValue > WYVERN_CHARGE_MAX)
        {
			invoker.chargeValue = WYVERN_CHARGE_MAX;
            quakeIntensity = 2;
        }

        if (quakeIntensity > 0)
            A_Quake(quakeIntensity, 2, 0, 16, "");
	}

	action void A_fonDashAttack()
	{
		Weapon w = player.ReadyWeapon;
        if (!w)
            return;

		Vel3DFromAngle(WYVERN_THRUST_VAL, angle, pitch);

		FTranslatedLineTarget t;
		int lineDamage = 0;
		double slope = AimLineAttack (angle, WYVERN_THRUST_CHECKRANGE);
		let puffObj = LineAttack(angle, WYVERN_THRUST_CHECKRANGE, slope, lineDamage, "Fire", "EmptyPuff", true, t);
		if (puffObj)
		{
			let mo = SpawnPlayerMissile("WyvernExplosionPuff");

            if (mo)
            {
                mo.SetOrigin(puffObj.Pos, false);
				mo.A_Explode(WYVERN_EXPLODE_DAMAGE, WYVERN_EXPLODE_RANGE, false);
            }

			A_Stop();
			A_RadiusThrust(WYVERN_EXPLODE_THRUST, WYVERN_EXPLODE_RANGE, RTF_NOIMPACTDAMAGE);
			Thrust(WYVERN_EXPLODE_THRUST, angle + 180);
			A_GiveInventory("HNecroStunEffect1Sec");
			player.SetPsprite(PSP_WEAPON, w.FindState("DashAttackFinish"));
		}
	}

	action void A_fonWyvernBlastPlayer()
	{
		Weapon w = player.ReadyWeapon;
        if (!w)
            return;

        if (invoker.ChargeValue >= WYVERN_CHARGE_MAX && w.Ammo1.Amount >= WYVERN_DASH_COST)
        {
            A_TakeInventory("HNecroWeaponMorphAmmo", WYVERN_DASH_COST);
            A_StartSound("wyvern/see", CHAN_WEAPON);

			player.SetPsprite(PSP_WEAPON, w.FindState("DashAttack"));
			invoker.ChargeValue = 0;
        }
        else
        {
            A_HoNWyvernBlastPlayer();
        }
	}

	action void A_CheckDex(int dexMin, StateLabel fallbackState, int ammoCheck = 0)
    {		
        Weapon w = player.ReadyWeapon;
        if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		if (!w)
			return;
		
		if (ammoCheck > 0 && w.Ammo1.Amount < ammoCheck)
			player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));

		int dex = fp.GetDexterity();

        if (dex < dexMin)
            player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));
    }
}

class WyvernExplosionPuff : Actor
{
	Default
	{
		Radius 6;
		Height 4;
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		VSpeed 0;
        Speed 0;
		SeeSound "enemies/priest/projectiles/collision";
	}
	States
	{
	Spawn:
        GNDX ABCDEFGHIJKLMNOPQRSTUVWX 1 Light("FLICKERFLAME2");
		Stop;
	}
}

class fonMorphWyvernFlight : PowerFlight replaces HNecroPlayerMorphWyvernFlight
{
	Default
	{
		Inventory.Icon "";
	}
	override void Tick ()
	{
		EffectTics++;
		if(owner && owner.getclass() != "fonMorphWyvern")
			EffectTics = 0;
		Super.Tick ();
	}
}