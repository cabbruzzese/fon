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

const FONSWORDRANGE=72.0;
class fonSword : fonMeleeWeapon replaces HNecroWeaponSword
{
	int swingcount;
	Default
	{
		//$Title Magical Sword
		Tag "$TAG_Sword";
		Inventory.PickupMessage "$PKUP_Sword";
		Weapon.AmmoType "HNecroWeaponSwordAmmo";
		Weapon.AmmoUse 1;
		+WEAPON.AMMO_OPTIONAL
		+WEAPON.NOALERT
		XScale 0.84;
		YScale 0.7;
		Weapon.SelectionOrder 3;
	}

	States
	{
	Spawn:
		PSRD A -1 Light("SWORDAMMO2");
		Stop;
	Select:
		SWRD A 1 A_HonSwordCheck('Raise');
		Loop;
	SelectAmmo:
		SWRD NNNOOO 1 A_HonSwordCheck('Raise', true);
		Loop;
	Deselect:
		SWRD A 1 A_HonSwordCheck('Lower');
		Loop;
	DeselectAmmo:
		SWRD NNNOOO 1 A_HonSwordCheck('Lower', true);
		Loop;
	Ready:
		SWRD A 1 A_HonSwordCheck('Ready');
		Loop;
	ReadyAmmo:
		SWRD NO 3 A_HonSwordCheck('Ready', true);
		Goto Ready;
	Fire:
		SWRD B 4 A_HonSwordCheck('Attack');
		SWRD C 3;
		SWRD D 2;
		SWRD E 2 A_FonMeleeWeaponStrike(FONSWORDRANGE, 1, 15);
		SWRD FG 2;
		TNT1 A 6;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	FireAmmo:
		SWRD P 4;
		SWRD Q 3;
		SWRD R 2;
		SWRD S 2 A_FonMeleeWeaponStrike(FONSWORDRANGE, 1, 15);
		SWRD TU 2;
		TNT1 A 6;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	Horizontal:
		SWRD Z 3;
		SWRD H 4;
		SWRD I 3;
		SWRD J 2;
		SWRD J 2
		{
			A_WeaponOffset(60, 0, WOF_KEEPY|WOF_ADD);
			A_FonMeleeWeaponStrike(FONSWORDRANGE, 8, 15, true);
		}
		SWRD J 2 A_WeaponOffset(80, 10, WOF_ADD);
		SWRD JJ 2 A_WeaponOffset(100, 20, WOF_ADD);
		TNT1 A 4 A_WeaponOffset(0, 32);
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	HorizontalAmmo:
		SWR2 A 3;
		SWRD V 4;
		SWRD W 3;
		SWRD X 2;
		SWRD X 2
		{
			A_WeaponOffset(60, 0, WOF_KEEPY|WOF_ADD);
			A_FonMeleeWeaponStrike(FONSWORDRANGE, 8, 15, true);
		}
		SWRD X 2 A_WeaponOffset(80, 10, WOF_ADD);
		SWRD XX 2 A_WeaponOffset(100, 20, WOF_ADD);
		TNT1 A 4 A_WeaponOffset(0, 32);
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	}
}