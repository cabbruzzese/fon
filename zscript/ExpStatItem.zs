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

	bool ReduceInventory(Actor ownerObj, name itemType)
	{
		if (!ownerObj)
			return false;
		
		let itemObj = ExpStatItem(ownerObj.FindInventory(itemType));
		if (!itemObj)
			return false;

		if (itemObj.Amount < 1)
			return false;

		if (itemObj.StatType == StatType)
			return false;
		
		return ownerObj.A_TakeInventory(itemType, 1);
	}

	override bool Use (bool pickup)
	{
		if (Owner == null) return true;
		
		let fonPlayer = fonPlayer.GetPlayerOrMorph(Owner);
		if (fonPlayer)
        {
            fonPlayer.XPStatIncrease(StatType, PlayerPawn(Owner));
            
            //Decrease all stat items
			ReduceInventory(Owner, "ExpStrItem");
			ReduceInventory(Owner, "ExpDexItem");
			ReduceInventory(Owner, "ExpMagItem");
        }

		return true;
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