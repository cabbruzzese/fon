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
			if (!w.CheckAmmo(PrimaryFire, true, true, 1))
            	return;

        	w.DepleteAmmo(false, true, 1);
            
            A_StartSound("icegolem/blizzard", CHAN_WEAPON);
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
	states
	{
	Spawn:
		IGTA ABCDEFGHIJABCDEFGHIJABCDEFGHIJABCDEFGHIJ 1
		{
			A_SetScale(Scale.X * 1.0125);
			SetDamage(random(0, 4) ? 0 : 1);
		}
	Death:
		IGTA KLMNOPQRST 1;
		Stop;
	}
}