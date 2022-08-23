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

const FIREPISTOL_AMMO_COST = 2;
class fonPistol : HNecroWeaponPistol replaces HNecroWeaponPistol
{
    States
	{
	AltFire:
        PSCN G 0 A_CheckMagic(PISTOL_LEVEL_FIREAMMO, "AltFireNormal", FIREPISTOL_AMMO_COST);
        PSCN G 3;
		PSCN H 3 A_StartSound("weapons/pistol/reload", 0, CHANF_OVERLAP);
		PSCN IJI 3;
		PSCN K 2;
		PSCN LA 4;
		PSCN B 1 A_fonFirePistolShoot;
		PSCN C 2;
		PSCN D 1;
		PSCN E 2;
		PSCN F 7;
		PSCN G 4;
		PSCN H 4 A_StartSound("weapons/pistol/reload", 0, CHANF_OVERLAP);
		PSCN IJI 4;
		PSCN K 5;
		PSCN LA 6;
		"####" "#" 0 A_Refire;
		Goto Ready;
    AltFireNormal:
        PSCN B 1 A_fonAltFirePistolNormal;
		PSCN C 2;
		PSCN D 1;
		PSCN E 2;
		PSCN F 7;
		PSCN G 4;
		PSCN H 4 A_StartSound("weapons/pistol/reload", 0, CHANF_OVERLAP);
		PSCN IJI 4;
		PSCN K 5;
		PSCN LA 6;
		"####" "#" 0 A_Refire;
		Goto Ready;
	}

    action void A_fonAltFirePistolNormal()
    {
        Weapon w = player.ReadyWeapon;
        if (!w)
            return;

        if (w.CheckAmmo(PrimaryFire, true, true, 1))
        {
            w.Ammo1.Amount--;
            A_HoNPistolShoot();
        }
    }

    action void A_fonFirePistolShoot()
	{
        Weapon w = player.ReadyWeapon;
        if (!w)
            return;
        
        if (w.Ammo1.Amount < FIREPISTOL_AMMO_COST)
		{
            A_fonAltFirePistolNormal();
			return;
		}
        
        w.Ammo1.Amount -= FIREPISTOL_AMMO_COST;
		A_StartSound("weapons/pistol/fire", CHAN_WEAPON);
		A_FireBullets(11.2, 7.1, 20, random(6, 12), "fonFirePistolBulletPuff", FBF_USEAMMO | FBF_NORANDOM | FBF_NORANDOMPUFFZ);
		HoNWeaponQuake(7, 6);
	}

    action void A_CheckMagic(int magicMin, StateLabel fallbackState, int ammoCheck = 0)
    {
        Weapon w = player.ReadyWeapon;
        if(!player)
			return;
		let fp = fonPlayer.GetPlayerOrMorph(player.mo);
		if (!fp)
			return;

        if (!w)
            return;
        
        if (ammoCheck > 0 && w.Ammo1.Amount < ammoCheck)
			player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));

		int magic = fp.GetMagic();

        if (magic < magicMin)
            player.SetPsprite(PSP_WEAPON, w.FindState(fallbackState));
    }
}

class fonFirePistolBulletPuff : Actor
{
	Default
	{
		+DONTSPLASH
		+NOBLOCKMAP
		+NOGRAVITY
		+NOTELEPORT
        +PUFFONACTORS
		Scale 0.2;
		Mass 5;
		Decal "PistolCannon";
	}
	States
	{
        //spawn on actor
    Spawn:
        SCFL IJKL 3 BRIGHT Light("FLICKERFLAME1");
        Stop;
	Crash:	//Hit a wall
        MCF3 WXYZ[]\ 2 BRIGHT Light("FLICKERFLAME1");
        SCF2 DEFGDEFGDEFGDEFG 2 BRIGHT Light("FLICKERFLAME1");
		Stop;
	}
}