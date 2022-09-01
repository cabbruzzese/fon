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

class fonFriendMarker : HNecroFriendMarker replaces HNecroFriendMarker
{
	override void tick()
	{
		if(master && master.health > 0)
			A_Warp(AAPTR_MASTER, 0, 0, master.height + 10);
		else
			A_Remove(AAPTR_DEFAULT, RMVF_EVERYTHING);
		super.tick();
	}
	Default
	{
		Scale 0.5;
		+NOINTERACTION
	}
	States
	{
	Spawn:
		ALYM A 10;
		ALYM B 10 A_GiveSquishItem;
		Loop;
	MarkerAnimate:
		ALYM AB 10 BRIGHT;
		Loop;
	}

	action void A_GiveSquishItem ()
	{		
		if (!master)
			return;

		let sItem = master.FindInventory("SummonExpSquishItem");

		if (!sItem)
			master.GiveInventoryType("SummonExpSquishItem");

		SetStateLabel("MarkerAnimate");
	}
}
