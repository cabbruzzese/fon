class fonGrenadeAmmoBig : HNecroWeaponGrenadeAmmoBig replaces HNecroWeaponGrenadeAmmoBig
{
	Default
	{
		DropItem "fonGrenade";
	}
}

const GRENADE_TIMER_MAX = 100;
class fonGrenade : HNecroWeaponGrenade replaces HNecroWeaponGrenade
{
	int grenadeTimer;

	States
	{
	Ready:
		GNDW A 1 A_fonGrenadeReady;
		Loop;		
	Fire:
		GNDW B 8;
	Hold:
		GNDW B 1;
		GNDW B 1 A_TickTimer;
		GNDW F 2 A_Jump(128, "Fire2");
		GNDW G 6 A_fonThrowGrenade;
		GNDW H 5;
		GNDW I 4;
		GNDW J 3;
		TNT1 A 13 A_CheckReload;
		Goto Ready;
	Fire2:
		GNDW B 2;
		GNDW C 6 A_fonThrowGrenade;
		GNDW D 5;
		GNDW E 4;
		TNT1 A 16 A_CheckReload;
		Goto Ready;
	}

	action void A_fonGrenadeReady()
	{
		invoker.grenadeTimer = 0;
		A_WeaponReady();
	}

	action void A_TickTimer()
	{
		invoker.grenadeTimer++;

		if (invoker.grenadeTimer >= GRENADE_TIMER_MAX)
		{
			Weapon w = player.ReadyWeapon;
			player.SetPsprite(PSP_WEAPON, w.FindState("Fire2"));
			return;
		}

		A_Refire();
	}

	action void A_fonThrowGrenade()
	{
		let gren = fonThrownGrenade(A_FireProjectile("fonThrownGrenade"));
		if(gren)
		{
			string s = String.Format("Grenade Timer is: %d", invoker.grenadeTimer);
			A_PrintBold(s);
			gren.GrenadeTimer = invoker.grenadeTimer;
			gren.Vel.Z += 8.0;
		}

		invoker.grenadeTimer = 0;
	}
}

class fonThrownGrenade : HNecroWeaponThrownGrenade replaces HNecroWeaponThrownGrenade
{
	int grenadeTimer;
	property GrenadeTimer : grenadeTimer;

	override void Tick()
	{
		if(GrenadeTimer < 1000)
		{
			if(!Level.isFrozen())
				GrenadeTimer++;
			if(GrenadeTimer >= 100 && GrenadeTimer < 999)
			{
				GrenadeTimer = 1000;
				if (!InStateSequence(curState, ResolveState("Bounce.Actor.Creature")))
					SetStateLabel("Bounce.Actor.Creature");
			}
		}
		Super.Tick();
	}
}