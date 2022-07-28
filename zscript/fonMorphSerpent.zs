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