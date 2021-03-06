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

const AXERANGE=100.0;
class fonAxe : fonMeleeWeapon replaces HON_Axe1
{
	int swingcount;
	Default
	{
		//$Title Magical Sword
		Tag "$TAG_BAxe";
		Inventory.PickupMessage "$PKUP_BAxe";
		XScale 1.0; //0.84;
		YScale 1.0; //0.7;
		Weapon.SelectionOrder 2;
	}

	States
	{
	Spawn:
		AXE1 A -1;
		Stop;
	Select:
		BAXE A 1 A_HonSwordCheck('Raise');
		Loop;
	SelectAmmo:
		PAXE A 1 A_HonSwordCheck('Raise', true);
		Loop;
	Deselect:
		BAXE A 1 A_HonSwordCheck('Lower');
		Loop;
	DeselectAmmo:
		PAXE A 1 A_HonSwordCheck('Lower', true);
		Loop;
	Ready:
		BAXE A 1 A_HonSwordCheck('Ready');
		Loop;
	ReadyAmmo:
		PAXE A 3 A_HonSwordCheck('Ready', true);
		Goto Ready;
	JumpAttack:
		BAXE G 10;
		BAXE H 3;
		BAXE I 3 A_FonMeleeWeaponStrike(AXERANGE, 15, 35);
		BAXE J 3;
		TNT1 A 8;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	JumpAttackAmmo:
		PAXE G 10;
		PAXE H 3;
		PAXE I 3 A_FonMeleeWeaponStrike(AXERANGE, 15, 35);
		PAXE J 3;
		TNT1 A 8;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	Fire:
		BAXE B 0 A_AxeCheck('Attack');
	Horizontal:
		BAXE B 10;
		BAXE C 4;
		BAXE D 3 A_FonMeleeWeaponStrike(AXERANGE, 1, 30, true);
		BAXE E 3;
		BAXE F 3;
		TNT1 A 8;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	FireAmmo:
	HorizontalAmmo:
		PAXE B 10;
		PAXE C 4;
		PAXE D 3 A_FonMeleeWeaponStrike(AXERANGE, 1, 30, true);
		PAXE E 3;
		PAXE F 3;
		TNT1 A 8;
		TNT1 A 0 A_HoNSwordRefire();
		Goto Ready;
	}

	action void A_AxeCheck(name mode, bool glowing = false)
	{
		if(!player)
			return;
		
		Weapon w = player.ReadyWeapon;
		bool goodammo;
		if(w.Ammo1 && w.Ammo1.Amount > 0)
			goodammo = true;

		if (!player.OnGround)
		{
			if (goodammo)
				player.SetPsprite(PSP_WEAPON, w.FindState("JumpAttackAmmo"));
			else
				player.SetPsprite(PSP_WEAPON, w.FindState("JumpAttack"));
				
			return;
		}

		A_HonSwordCheck(mode, glowing);
	}
}
