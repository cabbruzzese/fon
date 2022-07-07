class FireLeaderLava : TimedActor
{
    Default
    {
        Speed 2;
        Radius 8;
        Height 8;
        Damage 3;
		Projectile;
		VSpeed 2;
        +SPAWNSOUNDSOURCE
        DamageType "Fire";
        DeathSound "weapons/staff/impact";
		Gravity 0.25;
		+NOBLOCKMAP +MISSILE +DROPOFF
		+NOTELEPORT
		-NOGRAVITY

        Obituary "$OB_FIREBOSS";

		TimedActor.TimeLimit 200;
    }
    States
    {
    Spawn:
        CLTF ABCDEFGHIJ 2 Bright;
        Loop;
    Death:
        CLTF J 4 Bright A_FireLeaderLavaImpact;
        CLTF KLMNOPQRSTUVWXY 2 Bright;
        Stop;
    }

	void A_FireLeaderLavaImpact ()
	{
		if (pos.Z <= floorz)
		{
			bNoGravity = true;
			Gravity = 1;
			AddZ(28);
		}
		A_Explode(10, 100, false);
	}

	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{
		//Don't hurt friendlies
		if (damage > 0 && victim)
		{
			//Player friendly leaders can hurt monsters, but not other player friendlies
			if (target && target.bFriendly)
			{
				if (victim.bIsMonster && victim.bFriendly)
					return 0;
				
				//friendly leaders can't hurt monsters
				let fonPlayer = fonPlayer.GetPlayerOrMorph(victim);
            	if (fonPlayer)
					return 0;
			}
			else
			{
				//Enemy leader can't hurt other monsters, unless they are player friendly
				if (victim.bIsMonster && !victim.bFriendly)
					return 0;
			}
		}

		return super.DoSpecialDamage(victim, damage, damagetype);
	}
}

class LightningLeaderFx1 : Actor
{
    Default
	{
		+NOBLOCKMAP +NOGRAVITY +NOCLIP +FLOAT
		+NOTELEPORT
		RenderStyle "Translucent";
		Alpha 0.6;

		SeeSound "undeadking/thunder2";
	}
	States
	{
	    Spawn:
            GKF2 A 2 Bright;
            GKF2 B 2 Bright A_LightningBurst;
		    GKF2 CDEFGHIJKLMNOP 2 Bright;
		    Stop;
	}

    action void A_LightningBurst()
	{
		A_Explode(50, 150, false);
        A_RadiusThrust(3000, 150, RTF_NOIMPACTDAMAGE);
	}

	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{
		//Don't hurt friendlies
		if (damage > 0 && victim && victim.bIsMonster && !victim.bFriendly)
			return 0;

		return super.DoSpecialDamage(victim, damage, damagetype);
	}
}

class IceLeaderFx1 : Actor
{
	Default
	{
		Speed 10;
		Radius 4;
		Height 4;
		Damage 1;
		DamageType "Ice";
		Gravity 0.125;
		+NOBLOCKMAP +DROPOFF +MISSILE
		+NOTELEPORT
		+STRIFEDAMAGE
	}
	States
	{
	Spawn:
		IBAL ABCB 3 Bright;
		Loop;
	}

	override int DoSpecialDamage (Actor victim, int damage, Name damagetype)
	{
		//Don't hurt friendlies
		if (damage > 0 && victim && victim.bIsMonster && !victim.bFriendly)
			return 0;

		return super.DoSpecialDamage(victim, damage, damagetype);
	}
}