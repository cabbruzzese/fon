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

const LIGHTNING_COST = 2;
class fonTornado : HNecroWeaponTornado replaces HNecroWeaponTornado
{
	States
	{
	AltFire:
        TORS B 0 A_CheckMagic(TORNADO_LEVEL_LIGHTNING, "Fire");
		TORS B 6;
		TORS CDE 4;
		TORS F 4 TornadoLightningFire;
		TORS G 12;
		TORS G 0 A_ReFire;
		Goto Ready;
	}

	action void TornadoLightningFire()
	{
        Weapon w = player.ReadyWeapon;
		if (w.Ammo1.Amount < LIGHTNING_COST)
		{
			if (w.CheckAmmo(PrimaryFire, true, true, 1))
			{
				w.Ammo1.Amount--;
				A_HoNTornadoShoot();
			}
			return;
		}

        w.Ammo1.Amount -= LIGHTNING_COST;

		if (random(1,2) == 1)
            A_StartSound("undeadking/thunder1", CHAN_WEAPON);
        else
            A_StartSound("undeadking/thunder2", CHAN_WEAPON);
        
		A_FireProjectile("TornadoLightningMissile");
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
}

class TornadoLightningSmoke : Actor
{
	Default
	{
	    +NOBLOCKMAP +NOGRAVITY +SHADOW
	    +NOTELEPORT +CANNOTPUSH +NODAMAGETHRUST
        Scale 0.2;
        RenderStyle "Translucent";
        Alpha 0.6;
	}
	States
	{
	Spawn:
		SWRP F 6;
        SWRP GHIJ 1;
		Stop;
	}
}
class TornadoLightningMissile : FastProjectile
{
    int lightningCount;
    property LightningCount:lightningCount;
    Default
    {
        Speed 90;
        Radius 8;
        Height 6;
        Damage 1;
        Projectile;
        +RIPPER
        +CANNOTPUSH +NODAMAGETHRUST
        +SPAWNSOUNDSOURCE
        MissileType "TornadoLightningSmoke";
        Scale 0.2;
        RenderStyle "Translucent";
        Alpha 0.6;

        TornadoLightningMissile.LightningCount 2;

        DamageType "Electric";
    }
    States
    {
    Spawn:
        SWRP F 1 Bright;
        MLF2 F 1 Bright A_WandLightiningSplit;
    Death:
        SWRP GHIJ 1 Bright;
        Stop;
    }

	action void A_WandLightiningSplit ()
	{
		if (target == null)
		{
			return;
		}

        if (invoker.LightningCount < 1)
            return;

        invoker.LightningCount--;
        A_SplitTornadoLightningFire();
        A_SplitTornadoLightningFire();
	}

    action void A_SplitTornadoLightningFire()
	{
		if (target == null)
		{
			return;
		}
		
        int randAngle = random[MSpellLightning1](-12, 12);
        int randPitch = random[MSpellLightning1](-8, 8);
		TornadoLightningMissile mo = TornadoLightningMissile(target.SpawnPlayerMissile ("TornadoLightningMissile", angle + randAngle));
		if (mo != null)
		{
			mo.SetOrigin(Pos, false);
			mo.target = target;
			mo.A_SetPitch(pitch + randPitch);
			mo.Vel.Z = Vel.Z + randPitch;
            mo.LightningCount = invoker.LightningCount;
		}
	}
}

class fonTornadoShot : HNecroWeaponTornadoShot replaces HNecroWeaponTornadoShot
{
	override int DoSpecialDamage (Actor target, int damage, Name damagetype)
	{
		let t=target;
		if (!t.bDontThrust)
		{
			t.angle += Random2[WhirlwindDamage]() * (360 / 4096.);
			t.Vel.X += Vel.X / 4.;
			t.Vel.Y += Vel.Y / 4.;
		}

		if (!(Level.maptime & 8))
			t.DamageMobj (null, self.target, random(5, 7), 'Melee');
		return -1;
	}
}