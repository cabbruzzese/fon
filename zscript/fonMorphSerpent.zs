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

class fonMorphSerpent : HNecroPlayerMorphSerpent replaces HNecroPlayerMorphSerpent
{
	Default
	{
		Player.MorphWeapon "fonWeaponSerpent";
	}
}

class fonWeaponSerpent : HNecroPlayerWeaponSerpent replaces HNecroPlayerWeaponSerpent
{
	States
	{
	Fire:
		SRPM GH 3;
		SRPM I 3;
		SRPM J 3 A_fonSerpentSpit;
		SRPM K 3;
		SRPM A 1;
		Goto Ready;
	AltFire:
		SRPM AD 3;
		SRPM E 3 A_SerpentMelee;
		SRPM F 3;
		Goto Ready;
	}

	action void A_SerpentMelee()
	{
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

		int maxDamage = 6 + (fp.GetDexterity() / 3);
		int damage = random(1, maxDamage);
		A_CustomPunch(damage, true, 0, "", meleesound:"snake/bite", misssound:"snake/bite");
	}

	action void A_fonSerpentSpit()
	{
		A_StartSound("snake/spit", CHAN_WEAPON);
		A_Quake(1, 3, 0, 100, "");

		Class<Actor> projectileClass = "HON_SerpentBall_Player";

		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (fp && fp.GetDexterity() >= FEROCITY_LEVEL_FORKTONGUE)
			projectileClass = "Hon_SerpentBall_PlayerSplit";

		A_FireProjectile(projectileClass);
	}
}
class Hon_SerpentBall_PlayerSplit : HON_SerpentBall
{
	states
	{
	Spawn:
		srpb AAAA 4;
		srpb A 0 A_SerpentBallSplit;
		Stop;
	}

	action void A_FireBallSplit(int angleMod)
	{
		let mo = target.SpawnPlayerMissile ("HON_SerpentBall_Player", angle + angleMod);
		if (mo != null)
		{
			mo.SetOrigin(Pos, false);
			mo.target = target;
			mo.A_SetPitch(pitch);
			mo.Vel.Z = Vel.Z;
		}
	}

	action void A_SerpentBallSplit()
	{
		A_FireBallSplit(-6);
		A_FireBallSplit(6);
	}
}