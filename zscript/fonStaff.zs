//-----------------------------------------------------------------------------
// Code modified by from HON for Feat of Necromancy Mod. Original license below
//                                                          - peewee
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

const STAFF_CHARGE_MAX = 15;
class fonStaff : HNecroWeaponStaff replaces HNecroWeaponStaff
{
    int chargeValue;
    property ChargeValue : chargeValue;

    Default
    {
        fonStaff.ChargeValue 0;
        Weapon.SelectionOrder 1;
    }

    States
	{
    Ready:
		STAF ABCD 6 {
            invoker.ChargeValue = 0;
            A_WeaponReady();
        }
		Loop;
    Fire:
    Hold:
        STAF E 0 A_CheckMagic(STAFF_LEVEL_CHARGE, "FireFinish");
        STAF E 2 A_ChargeUp;
        STAF E 1 A_Refire;
    FireFinish:
        STAF E 1;
		STAF E 2;
		STAF F 1;
		STAF F 2 A_StaffShootCharge;
		STAF G 2;
		STAF CD 3;
        Goto Ready;
	AltFire:
        STAF E 0 A_CheckMagic(STAFF_LEVEL_SPREAD, "FireFinish");
		STAF E 1;
		STAF E 4;
		STAF F 4;
		STAF F 2 A_StaffShootSpread;
		STAF G 4;
		STAF CD 3;
		"####" "#" 0 A_Refire();
		Goto Ready;
	}

    action void A_StaffShootCharge()
    {
        Weapon w = player.ReadyWeapon;

        if (w.Ammo1.Amount < 2)
        {
            A_HoNStaffShoot();
            return;
        }
        
        string missileType = "HNecroWeaponStaffFireball";

        if (invoker.ChargeValue >= STAFF_CHARGE_MAX)
        {
            missileType = "StaffFireballLarge";
            w.DepleteAmmo(false, true, 1);
        }
        A_FireProjectile(missileType);
		A_StartSound("weapons/staff/fire", CHAN_WEAPON);

        HoNWeaponQuake(1, 3);
        
        invoker.ChargeValue = 0;
    }

    action void A_StaffShootSpread()
    {
        Weapon w = player.ReadyWeapon;
        if (w.Ammo1.Amount < 2)
        {
            if (w.CheckAmmo(PrimaryFire, true, true, 1))
            {
                w.DepleteAmmo(false, true);
                A_HoNStaffShoot();
            }
            return;
        }

        w.Ammo1.Amount -= 2;

        A_FireProjectile("HNecroWeaponStaffFireball", -8);
        A_FireProjectile("HNecroWeaponStaffFireball", 0);
        A_FireProjectile("HNecroWeaponStaffFireball", 8);
		A_StartSound("weapons/staff/fire", CHAN_WEAPON);
		
        HoNWeaponQuake(1, 3);
    }

    action void A_CheckMagic(int magicMin, StateLabel fallbackState)
    {
        Weapon w = player.ReadyWeapon;
        if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		int magic = fp.GetMagic();

        if (magic < magicMin)
            player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));
    }

    action void A_ChargeUp()
	{
		invoker.ChargeValue++;
		if (invoker.chargeValue > STAFF_CHARGE_MAX)
			invoker.chargeValue = STAFF_CHARGE_MAX;
	}
}

class StaffFireballLarge : HON_Acolyte_Attack
{
	default
	{
		DamageFunction (random(8, 12));
		Speed 30;
		//Scale 0.6;
		Alpha 0.6;
		RenderStyle "Add";
		DamageType "Fire";
        DamageFunction (random(10, 15));
		DeathSound "enemies/priest/projectiles/collision";
		SeeSound "";
        Decal "Firestaff";
	}
	states
	{
	Spawn:
		gcfa abcdefghij 2 bright Light("CULTISTMIS1");
		loop;
	Death:
		gcfx a 0
		{
			A_Explode(random(20, 30), 80);
			A_RadiusThrust(50);
		}
		gcfx abcdefghij 2 bright Light("CULTISTMIS2");
		stop;
	}
}