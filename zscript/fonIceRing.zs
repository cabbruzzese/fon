class fonIceRing : HNecroWeaponIceRing replaces HNecroWeaponIceRing
{
	States
	{

	Fire:
		ICER BCD 3;
		ICER E 8 A_HoNIceRingShoot;
		ICER FDCB 4;
		ICER A 3;
		ICER A 0 A_ReFire;
		Goto Ready;
    AltFire:
        ICER B 0 A_CheckMagic(ICE_LEVEL_BREATH, "Fire");
        ICER BC 3;
        ICER D 8;
        ICER E 2 A_IceRingFreeze(true);
		ICER EEEEEEE 2 A_IceRingFreeze(false);
		ICER FDCB 4;
		ICER A 3;
		ICER A 0 A_ReFire;
		Goto Ready;
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

	action void A_IceRingFreeze(bool isFirst)
	{
        if (isFirst)
        {
            Weapon w = player.ReadyWeapon;
            if (!w.DepleteAmmo(false, true, 1))
                return;

            A_StartSound("icegolem/blizzard");
    		HoNWeaponQuake(3, 4);
        }

		A_FireProjectile("IceRingFreeze");
	}
}

class IceRingFreeze : HON_Enemy_IceGolem_Icethrower
{
    Default
    {
        Speed 6;
    }
}