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
			if(GrenadeTimer >= 100)
			{
				GrenadeTimer = 1000;
				if (!InStateSequence(curState, ResolveState("Bounce.Actor.Creature")))
					SetStateLabel("Bounce.Actor.Creature");
			}
		}
		Super.Tick();
	}
}