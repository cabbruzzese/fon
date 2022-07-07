class BossMaker : EventHandler
{
    WanderingMonsterItem InitWanderingMonster(Actor monsterObj)
    {
        let wmItem = WanderingMonsterItem(monsterObj.FindInventory("WanderingMonsterItem"));

        if (wmItem)
            return wmItem;
        
        wmItem = WanderingMonsterItem(monsterObj.GiveInventoryType("WanderingMonsterItem"));

        wmItem.BaseSpeed = monsterObj.Speed;

        return wmItem;
    }

    override void WorldThingSpawned(WorldEvent e)
    {
        // Check that the Actor is valid and an enemy monster and not a boss
        if (e.thing && e.thing.bIsMonster && !e.thing.bFriendly && !e.thing.bBoss)
        {
            //no boss monsters (undead kings do not have boss flag. Presumably to allow unmodified ripper damage.)
            if (e.thing is "HON_Enemy_UndeadKingBlue")
                return;

            InitWanderingMonster(e.thing);
        }
    }
}

const REPOP_TIMEOUT_MAX = 1500;
const REPOP_TIMEOUT_RAND = 1500;
class RepopulationHandler : EventHandler
{
    int repopulatedTime;
    Vector3List repopPositions;

    Vector3List getPosList()
    {
        if (!repopPositions)
        {
            repopPositions = new ("Vector3List");
            repopPositions.Init();
        }
        
        return repopPositions;
    }

    override void WorldThingSpawned(WorldEvent e)
    {
        if (e && e.thing && e.thing is "HNecroHealthFlask")
        {
            let newPos = (e.thing.Pos.X, e.thing.Pos.Y, e.thing.Pos.Z);
            getPosList().Push(newPos);
        }
    }

    void ResetRepopTimeout()
    {
        repopulatedTime = REPOP_TIMEOUT_MAX + random(0, REPOP_TIMEOUT_RAND);
    }

    override void WorldLoaded (WorldEvent e)
    {
        if (!e.IsSaveGame)
            ResetRepopTimeout();
    }

    int GetPlayerLevel(int playerNum)
    {
        let fonPlayer = fonPlayer.GetPlayerOrMorph(players[playerNum].mo);		
		if (!fonPlayer)
			return 1;

        let statItem = fonPlayer.GetStats();
        return statItem.ExpLevel;
    }

    int GetMaxPlayerLevel()
    {
        int maxLevel = 1;
        for (int i = 0; i < MaxPlayers; i++)
        {
            int playerLevel = GetPlayerLevel(i);

            if (playerLevel > maxLevel)
                maxLevel = playerLevel;
        }
    
		return maxLevel;
    }

    Class<Actor> getClassPointer(name className)
    {
        return className;
    }
    
    Class<Actor> GetWonderingMonster(int playerLevel)
    {
        Array<Class<Actor> > monsterList;
        Class<Actor> classBag;

        if (playerLevel > 18)
            monsterList.Push(getClassPointer("HON_Enemy_FireDemon"));
        if (playerLevel > 16)
            monsterList.Push(getClassPointer("HON_Enemy_SoulEater"));
        if (playerLevel > 14)
            monsterList.Push(getClassPointer("HON_Enemy_UndeadKnight"));
        if (playerLevel > 10)
            monsterList.Push(getClassPointer("HON_Enemy_TormentedUndead"));
        if (playerLevel > 9)
            monsterList.Push(getClassPointer("HON_Enemy_IceGolem"));
        if (playerLevel > 8)
            monsterList.Push(getClassPointer("HON_Enemy_StoneGolem"));
        if (playerLevel > 7)
            monsterList.Push(getClassPointer("HON_Enemy_Bishop"));
        if (playerLevel > 6)
            monsterList.Push(getClassPointer("HON_Enemy_Priest"));
        if (playerLevel > 5)
            monsterList.Push(getClassPointer("HON_Enemy_Gargoyle"));
        if (playerLevel > 4)
            monsterList.Push(getClassPointer("HON_Enemy_Lemure"));
        if (playerLevel > 3)
            monsterList.Push(getClassPointer("HON_Enemy_UndeadMinion"));
        if (playerLevel > 2)
            monsterList.Push(getClassPointer("HON_Enemy_SwampSerpent"));
        
        monsterList.Push(getClassPointer("HON_Enemy_Acolyte"));

        int monsterPick = random(0, monsterList.Size() - 1);
        return monsterList[monsterPick];
    }

    Vector3 GetDestination()
    {
        int destinationPick = random(0, getPosList().Size() - 1);
        return getPosList().GetItem(destinationPick);
    }

    void DoRepopulate()
    {
        int playerLevel = GetMaxPlayerLevel();
        let actorClass = GetWonderingMonster(playerLevel);

        let dest = GetDestination();

        players[0].mo.Spawn(actorClass, dest);
    }

    override void WorldTick ()
    {
        repopulatedTime--;
        if (repopulatedTime <= 0)
        {
            ResetRepopTimeout();
            DoRepopulate();
        }
    }
}