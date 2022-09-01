class RaiseDeadItem : Inventory
{
	Class<Actor> summonType;
	property SummonType : summonType;

	Default
	{
		+INVENTORY.UNDROPPABLE
		+INVENTORY.UNTOSSABLE
		+INVENTORY.AUTOACTIVATE
		+INVENTORY.PERSISTENTPOWER
		+INVENTORY.UNCLEARABLE

		RaiseDeadItem.SummonType "fonSummonGhost";
	}

    override bool Use(bool pickup)
    {
        if (!Owner || Owner.bFriendly)
			return false;
		
		//Don't summon dying ghosts
		if (Owner is "HON_Enemy_Lemure")
			return false;

		Actor mo = Spawn(self.SummonType, Owner.Pos, ALLOW_REPLACE);
		Spawn("HNecroMorphFog", Owner.Pos, ALLOW_REPLACE);
		Owner.A_StartSound(mo.ActiveSound, CHAN_VOICE);

        if (mo && mo.bFriendly)
        {
            actor marker = null;
            bool success;
			[success, marker] = A_SpawnItemEx("fonFriendMarker", 0, 0, mo.height + 10);
			if(marker)
				marker.Master = mo;
        }

		Owner.Destroy();

        return false;
    }
}

class RaiseGhostItem : RaiseDeadItem
{
    Default
    {
        RaiseDeadItem.SummonType "MonsterSummonGhost";
    }
}

class MonsterSummonGhost : HON_Enemy_Lemure
{
	Default
	{
	}
}

const GHOST_LIFE_MAX = 2048;
class fonSummonGhost : MonsterSummonGhost
{
    int lifeCounter;

    property lifeCounter : LifeCounter;

	Default
	{
		Health 50;

        +NOICEDEATH
        +FRIENDLY
        Translation "Ice";
        RenderStyle "Translucent";
        Alpha 0.6;

        fonSummonGhost.LifeCounter GHOST_LIFE_MAX;
	}

    override void Tick()
    {
        LifeCounter--;
        if (LifeCounter < 1 && Health > 0)
        {
            DamageMobj (null, null, TELEFRAG_DAMAGE, 'None');            
            SetStateLabel("Death");
        }
        Super.Tick();
    }
}