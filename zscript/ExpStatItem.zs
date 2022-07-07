const STAT_TYPE_STR = 0;
const STAT_TYPE_DEX = 1;
const STAT_TYPE_MAG = 2;
class ExpStatItem : PowerupGiver
{
    int statType;

    property StatType : statType;

	Default
	{
		+COUNTITEM
		+FLOATBOB
		Inventory.PickupFlash "PickupFlash";
		Inventory.MaxAmount 100;
	}

	override bool Use (bool pickup)
	{
		if (Owner == null) return true;
		
		let fonPlayer = fonPlayer(Owner);//Can only be used when in necromancer form
		if (fonPlayer)
        {
            fonPlayer.XPStatIncrease(StatType);
            
            //Decrease all stat items
            fonPlayer.A_TakeInventory("ExpStrItem", 1);
            fonPlayer.A_TakeInventory("ExpDexItem", 1);
            fonPlayer.A_TakeInventory("ExpMagItem", 1);
        }
		else
		{
			let pawn = PlayerPawn(Owner);
			pawn.A_Print("$TXT_NOTRANSFORMUSE");
		}

		return false;
	}
	
	override void Tick()
	{
		// Stat increases cannot exist outside an inventory
		if (Owner == NULL)
		{
			Destroy ();
		}
	}
}

class ExpStrItem : ExpStatItem
{
	Default
	{
        Scale 0.25;
        tag "$TAG_STRPICKUP";
		Inventory.Icon "XPSTA0";

		Inventory.PickupMessage "$TXT_STRPICKUP";

        ExpStatItem.StatType STAT_TYPE_STR;
	}
}

class ExpDexItem : ExpStatItem
{
	Default
	{
        tag "$TAG_DEXPICKUP";
		Inventory.Icon "XPDEA0";

		Inventory.PickupMessage "$TXT_DEXPICKUP";

        ExpStatItem.StatType STAT_TYPE_DEX;
	}
}

class ExpMagItem : ExpStatItem
{
	Default
	{
        tag "$TAG_MAGPICKUP";
		Inventory.Icon "XPMAA0";

		Inventory.PickupMessage "$TXT_MAGPICKUP";

        ExpStatItem.StatType STAT_TYPE_MAG;
	}
}