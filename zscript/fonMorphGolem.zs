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
const GOLEM_QUAKE_DEBRISNUM = 18;
class GolemFloorQuake : Actor
{
	Default
	{
		Radius 5;
		Height 12;
		Speed 16;
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

		for (int i = 0; i < GOLEM_QUAKE_DEBRISNUM; i++)
		{
			let xVel = frandom[GolemQuake](-GOLEM_QUAKE_VEL_MAX, GOLEM_QUAKE_VEL_MAX);
            let yVel = frandom[GolemQuake](-GOLEM_QUAKE_VEL_MAX, GOLEM_QUAKE_VEL_MAX);
            let zVel = frandom[GolemQuake](GOLEM_QUAKE_VELZ_MIN, GOLEM_QUAKE_VELZ_MAX);

			let mo = VerticleProjectile("QuakeDebrisMissile", Pos.X + random(-2, 2), Pos.Y + random(-2, 2), xVel, yVel, zVel, true);
			if (mo)
			{
				mo.SetState (mo.SpawnState + random(0, 5));
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

class QuakeDebrisMissile : actor
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
	}
	states
	{
	Spawn:
		STN9 A -1;
		STN8 B -1;
		STN8 C -1;
		STN8 D -1;
		STN8 E -1;
		STN8 F -1;
		Stop;
	Death:
		STN9 A 1;
		Stop;
	}
}