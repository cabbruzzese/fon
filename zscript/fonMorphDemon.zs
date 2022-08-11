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

const FLAME_VILE_OFFSET = 48;
const FLAME_VILE_RANGE = 1536;
const FLAME_VILE_COST = 25;

class fonMorphDemon : HNecroPlayerMorphFireDemon replaces HNecroPlayerMorphFireDemon
{
	Default
	{
		Player.MorphWeapon "fonWeaponDemon";
	}
}

const DEMON_CHARGE_MAX = 15;
class fonWeaponDemon: HNecroPlayerWeaponFireDemon replaces HNecroPlayerWeaponFireDemon
{
    int chargeValue;
    property ChargeValue : chargeValue;

    Default
    {
        fonWeaponDemon.ChargeValue 0;
    }

	States
	{
	Ready:
		WDEM A 1 {
            invoker.ChargeValue = 0;
            A_HoNMorphWeaponReady();
        }
		Loop;	
    Fire:
		WDEM B 2 A_SetPlayerState("ShotgunFire");
		WDEM CDE 2;
    Hold:
        WDEM F 2 A_ChargeUp;
        WEDM F 0 A_CheckDex(FEROCITY_LEVEL_DEMONCHARGE, "FireFinish");
        WDEM F 0 A_DFlameVileScan;
        WDEM F 0 A_Refire;
    FireFinish:
        WDEM G 2;
		WDEM H 2 A_fonFireDemonShotgun;
		WDEM IJ 2;
		WDEM A 17;
		Goto Ready;
	}

    action void A_ChargeUp()
	{
		invoker.ChargeValue++;
        int quakeIntensity = 0;
		if (invoker.chargeValue > DEMON_CHARGE_MAX)
        {
			invoker.chargeValue = DEMON_CHARGE_MAX;
            quakeIntensity = 1;
        }

        if (quakeIntensity > 0)
            A_Quake(quakeIntensity, 2, 0, 16, "");
	}

	action void A_fonFireDemonShotgun()
	{
        Weapon w = player.ReadyWeapon;
        if (!w)
            return;

        if (invoker.ChargeValue >= DEMON_CHARGE_MAX && w.Ammo1.Amount >= FLAME_VILE_COST)
        {
            A_TakeInventory("HNecroWeaponMorphAmmo", 25);
            A_StartSound("firedemon/fireball", CHAN_WEAPON);
            A_Quake(7, 7, 0, 640, "");		
            
            A_DFlameVileAttack();
        }
        else
        {
            A_HoNFireDemonShotgun();
        }
	}

    action void A_CheckDex(int dexMin, StateLabel fallbackState)
    {
        Weapon w = player.ReadyWeapon;
        if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		int dex = fp.GetDexterity();

        if (dex < dex)
            player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));
    }

    action void A_DFlameVileScan()
	{
		if (invoker.ChargeValue < DEMON_CHARGE_MAX)
			return;
		
		FTranslatedLineTarget t;
		
		int lineDamage = 0;
		double slope = AimLineAttack (angle, FLAME_VILE_RANGE);
		LineAttack(angle, FLAME_VILE_RANGE, slope, lineDamage, "Fire", "FlameVilePuff", LAF_NOINTERACT, t);
		if (t.linetarget != null)
		{
			if (t.linetarget.bIsMonster)
			{
				AdjustPlayerAngle(t);
				let mo = Spawn("FlameVilePuffBig");
				if (mo)
				{
					mo.SetOrigin(t.linetarget.Pos, false);
				}
			}
		}
	}

	action void A_DFlameVileAttack()
	{
		invoker.ChargeValue = 0;

		FTranslatedLineTarget t;
		int lineDamage = 0;
		double slope = AimLineAttack (angle, FLAME_VILE_RANGE);
		let puffObj = LineAttack(angle, FLAME_VILE_RANGE, slope, lineDamage, "Fire", "FlameVilePuff", true, t);
		if (puffObj)
		{
            let mo = SpawnPlayerMissile("FlameVilePuffBoom");

            if (mo)
            {
                mo.SetOrigin(puffObj.Pos, false);
                mo.A_Explode(80, 80, false);
                int newZ = Max(puffObj.Pos.z - 20, puffObj.floorz + 2);
                mo.SetZ(newZ);
            }
		}
	}
}

class FlameVilePuff : Actor
{
	Default
	{
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		RenderStyle "Translucent";
		Alpha 0.6;
		VSpeed 0.8;
		Scale 0.25;
	}
	States
	{
	Spawn:
		FDM2 ABCDEFGH 2 BRIGHT;
		FDM2 IJKLMNO 2 BRIGHT A_FadeOut;
		Stop;
	Death:
		Stop;
	}
}
class FlameVilePuffBig : FlameVilePuff
{
	Default
	{
		Scale 1.0;
	}
}
class FlameVilePuffBoom : Actor
{
	Default
	{
		Radius 6;
		Height 4;
		+NOBLOCKMAP +NOGRAVITY
		+PUFFONACTORS
		VSpeed 0;
        Speed 0;
		DamageType "Fire";
	}
	States
	{
	Spawn:
        LFC1 ABCDEFGHIJKLMNOPQRSTUVWXYZ 1 BRIGHT Light("FLICKERFLAME");
		Stop;
	}
}