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

class fonMorphGolem : HNecroPlayerMorphGolem replaces HNecroPlayerMorphGolem
{
	Default
	{
		Player.MorphWeapon "fonWeaponGolem";
	}
}

class fonWeaponGolem : HNecroPlayerWeaponGolem replaces HNecroPlayerWeaponGolem
{
	States
	{
	Fire:
		WGOL A 3 A_SetPlayerState("Punch");
		WGOL BC 3;
		WGOL D 3 A_fonGolemPunch;
		WGOL DCB 3;
		WGOL A 8;
		WGOL A 0
		{
			if(CountInv("HNecroWeaponMorphAmmo") >= 5)
				A_ReFire("Fire2");
		}
		Goto Ready;
	Fire2:
		WGOL A 3 A_SetPlayerState("Punch2");
		WGOL EF 3;
		WGOL G 3 A_fonGolemPunch;
		WGOL GFE 3;
		WGOL A 8;
		Goto Ready;
	AltFire:
		WGOS A 2
		{
			A_GiveInventory("HNecroStunEffect1Sec");
			A_SetPlayerState("Stomp");
		}
		WGOS BCDE 2;
		WGOS F 25
		{
			A_TakeInventory("HNecroWeaponMorphAmmo", 10);
			if(player)
				A_fonGolemStomp();
		}
		WGOS BA 5;
		Goto Ready;
	}
	action void A_fonGolemPunch()
	{
        let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		int maxDamage = 45 + (fp.GetDexterity() / 2);
		int damage = random(15, maxDamage);

		A_TakeInventory("HNecroWeaponMorphAmmo", 5);
		A_CustomPunch(damage, true, 0, "HNecroPlayerWeaponGolemPuff");
	}

	action void A_fonGolemStomp()
	{
		HNecroGlobal.A_HoNGolemQuake(player.mo, 24, 36, 384);

		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (fp && fp.GetDexterity() >= FEROCITY_LEVEL_QUAKE)
			A_FireProjectile("GolemFloorQuake", 0, false);
	}
}

const GOLEM_QUAKE_VELZ_MIN = 4.0;
const GOLEM_QUAKE_VELZ_MAX = 10.0;
const GOLEM_QUAKE_VEL_MAX = 1.5;
const GOLEM_QUAKE_DEBRISNUM = 9;
class GolemFloorQuake : Actor
{
	Default
	{
		Radius 5;
		Height 12;
		Speed 14;
		FastSpeed 20;
		Damage 0;
		RenderStyle "Add";

		Projectile;
		-ACTIVATEIMPACT
		-ACTIVATEPCROSS
		+ZDOOMTRANS
		+FLOORHUGGER
		+RIPPER
	}
	
	states
	{
	Spawn:
		TNT1 AAAAAA 8 Bright A_QuakeFloorFire;
		Stop;
	Death:
		TNT1 A 0;
		Stop;
	}

	void A_QuakeFloorFire()
	{
		SetZ(floorz);

		//Spawn rock splash on ground
		let smo = Spawn("HoNBloodDust");
		if (smo)
		{
			int newZ = CurSector.NextLowestFloorAt(pos.x, pos.y, pos.z, pos.z, FFCF_NOPORTALS) + 12;
			smo.SetOrigin((Pos.X,Pos.Y,newZ), false);
		}

		for (int i = 0; i < GOLEM_QUAKE_DEBRISNUM; i++)
		{
			let xVel = frandom[GolemQuake](-GOLEM_QUAKE_VEL_MAX, GOLEM_QUAKE_VEL_MAX);
            let yVel = frandom[GolemQuake](-GOLEM_QUAKE_VEL_MAX, GOLEM_QUAKE_VEL_MAX);
            let zVel = frandom[GolemQuake](GOLEM_QUAKE_VELZ_MIN, GOLEM_QUAKE_VELZ_MAX);

			let mo = VerticleProjectile("QuakeDebrisMissile", Pos.X + random(-2, 2), Pos.Y + random(-2, 2), xVel, yVel, zVel, true);
			if (mo)
			{
				mo.SetState (mo.SpawnState + random(0, 5));
				
				if (random(1,8) == 1)
					mo.A_SetScale(3.0);
			}
		}
	}
	
	Actor VerticleProjectile(Class<Actor> projType, int xPos, int yPos, double xVel, double yVel, double zVel, bool isFloor = false)
    {
        Actor mo = Spawn(projType);
        if (!mo)
            return null;
        
        mo.target = target;
        mo.SetOrigin((xPos, yPos, mo.Pos.Z), false);

        double newz;
        if (isFloor)
            newz = mo.CurSector.NextLowestFloorAt(mo.pos.x, mo.pos.y, mo.pos.z, mo.pos.z, FFCF_NOPORTALS) + mo.height;
        else
            newz = mo.CurSector.NextHighestCeilingAt(mo.pos.x, mo.pos.y, mo.pos.z, mo.pos.z, FFCF_NOPORTALS) + mo.height;
        
        mo.SetZ(newz);

        mo.Vel.X = xVel;
        mo.Vel.Y = yVel;
        mo.Vel.Z = zVel;

        mo.CheckMissileSpawn (radius);

        return mo;
    }
}

class QuakeDebrisMissile : TimedActor
{
	default
	{
		Projectile;
		Damage 1;
		Radius 8;
		Height 12;
		Speed 14;
		FastSpeed 22;
		+FORCEXYBILLBOARD
		-NOGRAVITY

		Gravity 0.5;

		TimedActor.TimeLimit 72;
		TimedActor.DieOnTimer true;
	}
	states
	{
	Spawn:
		STN9 A -1;
		STN9 B -1;
		STN9 C -1;
		STN9 D -1;
		STN9 E -1;
		STN9 F -1;
		Stop;
	Death:
		STN9 A 0 A_SetScale(0.3);
		SWRP ABCDE 2;
		Stop;
	}
}