//-----------------------------------------------------------------------------
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

class fonMorphPower : HNecroMorphPower
{
	override bool Use(bool pickup)
	{
		if(owner.CountInv("HNecroMorphCooldown"))
		{
			PrintPickupMessage(true, "$TRANSFORM_COOLDOWN_FAIL");
			return 0;
		}
		int health=owner.health;
		Playerinfo p = Owner.player;
		let playervel = Owner.vel;

        bool changeBack = false;
        bool instantChange = false;
        
        let morphPlayer = HNecroPlayerBase(Owner);
        if (morphPlayer)
        {
            if (morphPlayer.GetClassName() == self.MorphType)
                changeBack = true;

            if (morphPlayer.Alternative)
            {
                let fonPlayer = fonPlayer(morphPlayer.Alternative);
                let playerStats = fonPlayer.GetStats();
                if(!changeBack && playerStats && playerStats.Dexterity >= FEROCITY_LEVEL_INSTAMORPH)
                    instantChange = true;
            }
            
        }
        
        if(p && p.morphTics && !instantChange)
		{
			FindFloorCeiling(0);
			if(owner.ceilingz < owner.floorz + 56.0)
			{
				PrintPickupMessage(true, "$TRANSFORM_HEIGHT_FAIL");
				return 0;
			}
			owner.UnMorph(self, 0, true);
			PrintPickupMessage(true, "$TRANSFORM_MESSAGE_NEC");
		}
		else
		{
            HNecroPlayerBase ownerObj = HNecroPlayerBase(Owner);
            if (instantChange)
            {
                ownerObj = HNecroPlayerBase(ownerObj.Alternative);
                Owner.UnMorph(self, 0, true);
            }
            
			ownerObj.A_Morph(MorphType, 0x7FFFFFFF, MRF_WHENINVULNERABLE|MRF_FULLHEALTH|
			MRF_ADDSTAMINA|MRF_LOSEACTUALWEAPON, "HNecroMorphFog", "HNecroMorphFog");
			PrintPickupMessage(true, AnnounceMessage);
		}
		Owner.vel = playervel;
		owner.A_GiveInventory("HNecroMorphCooldown");
		owner.health = owner.player.health = health;
		return 0;
	}
}

class fonSerpentMorph : fonMorphPower replaces HNecroSerpentMorph
{
	Default
	{
		//$Title Serpent Morph
		Inventory.Icon "graphics/statusbar/MRPH1ICN.png";
		Tag "$TAG_TransformSerpent";
		Inventory.PickupMessage "$PKUP_TransformSerpent";
		HNecroMorphPower.MorphType "fonMorphSerpent";
		HNecroMorphPower.AnnounceMessage("$TRANSFORM_MESSAGE_SER");
		HNecroMorphPower.HintMessage("$TRANSFORM_HINT_SER");
	}
	States
	{
	Spawn:
		MRP1 ABCDEFG 4 BRIGHT;
		Loop;
	}
}

class fonGolemMorph : fonMorphPower replaces HNecroGolemMorph
{
	Default
	{
		//$Title Stone Breaker Morph
		Inventory.Icon "graphics/statusbar/MRPH2ICN.png";
		Tag "$TAG_TransformGolem";
		Inventory.PickupMessage "$PKUP_TransformGolem";
		HNecroMorphPower.MorphType "fonMorphGolem";
		HNecroMorphPower.AnnounceMessage("$TRANSFORM_MESSAGE_GOL");
		HNecroMorphPower.HintMessage("$TRANSFORM_HINT_GOL");
	}
	States
	{
	Spawn:
		MRP2 ABCDEFG 4 BRIGHT;
		Loop;
	}
}

class fonFireDemonMorph : fonMorphPower replaces HNecroFireDemonMorph
{
	Default
	{
		//$Title Hell Burner Morph
		Inventory.Icon "graphics/statusbar/MRPH3ICN.png";
		Tag "$TAG_TransformFireDemon";
		Inventory.PickupMessage "$PKUP_TransformFireDemon";
		HNecroMorphPower.MorphType "HNecroPlayerMorphFireDemon";
		HNecroMorphPower.AnnounceMessage("$TRANSFORM_MESSAGE_DEM");
		HNecroMorphPower.HintMessage("$TRANSFORM_HINT_DEM");
	}
	States
	{
	Spawn:
		MRP3 ABCDEFG 4 BRIGHT;
		Loop;
	}
}

class fonWyvernMorph : fonMorphPower replaces HNecroWyvernMorph
{
	Default
	{
		//$Title Wyvern Morph
		Inventory.Icon "graphics/statusbar/MRPH4ICN.png";
		Tag "$TAG_TransformWyvern";
		Inventory.PickupMessage "$PKUP_TransformWyvern";
		HNecroMorphPower.MorphType "HNecroPlayerMorphWyvern";
		HNecroMorphPower.AnnounceMessage("$TRANSFORM_MESSAGE_WYV");
		HNecroMorphPower.HintMessage("$TRANSFORM_HINT_WYV");
	}
	States
	{
	Spawn:
		MRP4 ABCDEFG 4 BRIGHT;
		Loop;
	}
}