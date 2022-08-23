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

const STAFF_CHARGE_MID = 10;
const STAFF_CHARGE_MAX = 20;
const STAFF_SPREAD_COST = 2;
const STAFF_CHARGE_COST = 2;
const STAFF_METEOR_COST = 3;
const STAFF_METEOR_FORWARD = 35;
const STAFF_METEOR_HEIGHTOFFSET = 25;
const STAFF_METEOR_RIGHTOFFSET = 30;
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

    action void A_StaffShootMeteors()
    {
        FindFloorCeiling(0);
        int spawnz = min (ceilingz - 10.0, pos.z + STAFF_METEOR_HEIGHTOFFSET) - pos.z;
        let forwardOffset = AngleToVector(angle, STAFF_METEOR_FORWARD);

        for(int i = 0; i < 3; i++)
        {
            let mo = A_FireProjectile("fonStaffMeteorCharging", 0, false, STAFF_METEOR_RIGHTOFFSET - (i * STAFF_METEOR_RIGHTOFFSET), spawnz);
            if (mo)
            {
                mo.SetOrigin(mo.Pos + forwardOffset, false);
                mo.A_SetHealth((i * 1) + 1);
            }
        }
    }

    action void A_StaffShootCharge()
    {
        Weapon w = player.ReadyWeapon;
        if (!w)
            return;

        if (invoker.ChargeValue >= STAFF_CHARGE_MAX && w.Ammo1.Amount >= STAFF_METEOR_COST)
        {
            w.Ammo1.Amount -= STAFF_METEOR_COST;
            A_StaffShootMeteors();
        }
        else if (invoker.ChargeValue >= STAFF_CHARGE_MID && w.Ammo1.Amount >= STAFF_CHARGE_COST)
        {
            w.Ammo1.Amount -= STAFF_CHARGE_COST;
            A_FireProjectile("StaffFireballLarge", 0, false);
            A_StartSound("weapons/staff/fire", CHAN_WEAPON);
            HoNWeaponQuake(1, 3);
        }
        else
        {
            A_HoNStaffShoot();
        }

        invoker.ChargeValue = 0;
    }

    action void A_StaffShootSpread()
    {
        Weapon w = player.ReadyWeapon;
        if (!w)
            return;
        
        if (w.Ammo1.Amount < STAFF_SPREAD_COST)
        {
            if (w.CheckAmmo(PrimaryFire, true, true, 1))
            {
                w.DepleteAmmo(false, true);
                A_HoNStaffShoot();
            }
            return;
        }

        w.Ammo1.Amount -= STAFF_SPREAD_COST;

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
        let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		int magic = fp.GetMagic();

		invoker.ChargeValue++;
        int quakeIntensity = 0;
		if (invoker.chargeValue >= STAFF_CHARGE_MAX)
        {
            if (magic >= STAFF_LEVEL_CHARGE2)
			{
                invoker.chargeValue = STAFF_CHARGE_MAX;
                quakeIntensity = 3;
            }
            else
            {
                invoker.chargeValue = STAFF_CHARGE_MID;
                quakeIntensity = 1;
            }
        }
        else if (invoker.chargeValue > STAFF_CHARGE_MID)
        {
            quakeIntensity = 1;
        }

        if (quakeIntensity > 0)
            A_Quake(quakeIntensity, 2, 0, 16, "");
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

const METEOR_REAIM_RANGE = 1536;
const METEOR_REAIM_SPEED = 18;
class fonStaffMeteorCharging : HON_Bishop_Attack_Charging
{
    Default
    {
        RenderStyle "Translucent";
        Alpha 0.6;
    }
	States
	{
	Spawn:
		GCFC abcdefghij 1 bright Light("FIREDEMON")
		{
            if (Scale.X < 2.0)
            {
                Scale.X *= 1.025;
                Scale.Y *= 1.025;
            }
		}
        GCFC j 0 bright Light("FIREDEMON")
		{
            Health--;
		}
        GCFC j 0 A_JumpIfHealthLower(1, "SpawnFinish");
        Loop;
    SpawnFinish:
        GCFC j 1 bright Light("FIREDEMON") A_FireMeteor;
	Death:
		"####" "#" 1 BRIGHT Light("FIREDEMON") A_FadeOut;
		Loop;
	}

    action void A_ReAim(Actor meteorObj)
    {
        if (!target || !meteorObj)
            return;
        
		FTranslatedLineTarget t;
		
		int lineDamage = 0;
		double slope = target.AimLineAttack (target.angle, METEOR_REAIM_RANGE);
		let puffObj = target.LineAttack(target.angle, METEOR_REAIM_RANGE, slope, lineDamage, "Fire", "EmptyPuff", LAF_NOINTERACT, t);
		if (puffObj != null)
		{
            Actor faceTarget = puffObj;
            if (t.linetarget)
                faceTarget = t.linetarget;
            
            meteorObj.A_Face(faceTarget, 0, 0, 0, 0, 0, 0);
            meteorObj.VelIntercept(faceTarget, -1, false, true);
		}
    }

    action void A_FireMeteor()
    {
        if (!target)
            return;
        
        Class<Actor> missileType = "fonPlayerBishopAttack1";
        int typeRand = Random(1,3);
        if (typeRand == 2)
            missileType = "fonPlayerBishopAttack2";
        else if (typeRand == 3)
            missileType = "fonPlayerBishopAttack3";
        
        let mo = target.SpawnPlayerMissile(missileType, target.angle);
        if (mo)
        {
            mo.SetOrigin(Pos, false);
            mo.target = target;
            A_ReAim(mo);
        }
    }
}

class fonPlayerBishopAttack1 : HON_Bishop_Attack1
{
    default
    {
        DamageFunction (random(15, 25));
    }
}
class fonPlayerBishopAttack2 : HON_Bishop_Attack2
{
    default
    {
        DamageFunction (random(15, 25));
    }
}
class fonPlayerBishopAttack3 : HON_Bishop_Attack3
{
    default
    {
        DamageFunction (random(15, 25));
    }
}