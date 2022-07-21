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

        if (playerLevel > 22)
            monsterList.Push(getClassPointer("hon_enemy_wyvern"));
        if (playerLevel > 20)
            monsterList.Push(getClassPointer("HON_Enemy_FireDemon"));
        if (playerLevel > 17)
            monsterList.Push(getClassPointer("HON_Enemy_SoulEater"));
        if (playerLevel > 15)
            monsterList.Push(getClassPointer("HON_Enemy_UndeadKnight"));
        if (playerLevel > 13)
            monsterList.Push(getClassPointer("HON_Enemy_TormentedUndead"));
        if (playerLevel > 10)
            monsterList.Push(getClassPointer("HON_Enemy_Bishop"));
        if (playerLevel > 8)
            monsterList.Push(getClassPointer("HON_Enemy_IceGolem"));
        if (playerLevel > 7)
            monsterList.Push(getClassPointer("HON_Enemy_StoneGolem"));
        if (playerLevel > 6)
            monsterList.Push(getClassPointer("HON_Enemy_Priest"));
        if (playerLevel > 5)
            monsterList.Push(getClassPointer("HON_Enemy_Gargoyle"));
        if (playerLevel > 4)
            monsterList.Push(getClassPointer("HON_Enemy_Lemure"));
        if (playerLevel > 3 && playerLevel < 9)
            monsterList.Push(getClassPointer("HON_Enemy_UndeadMinion"));
        if (playerLevel > 2 && playerLevel < 8)
            monsterList.Push(getClassPointer("HON_Enemy_SwampSerpent"));
        
        if (playerLevel < 10)
            monsterList.Push(getClassPointer("HON_Enemy_Acolyte"));

        int monsterPick = random(0, monsterList.Size() - 1);
        return monsterList[monsterPick];
    }

    Class<Actor> GetWonderingMonsterAquatic()
    {
        if (random(1,3) == 1)
        {
            return getClassPointer("HON_Enemy_SwampSerpent");
        }

        return getClassPointer("HON_Enemy_SeaNightmare");
    }

    Vector3 GetDestination()
    {
        let listObj = getPosList();

        int destinationPick = random(0, listObj.Size() - 1);
        return listObj.GetItem(destinationPick);
    }

    int GetDestinationListSize()
    {
        return getPosList().Size();
    }

    Actor SpawnMonsterForRepop(Class<Actor> actorClass)
    {
        let spawnClass = actorClass;

        let mo = players[0].mo.Spawn(spawnClass);

        return mo;
    }

    const REPOP_RETRY_MAX = 5;
    void DoRepopulate()
    {
        //Don't try to repopulate if list of destinations is empty
        if (GetDestinationListSize() < 1)
            return;

        int retries = 0;
        bool success = false;

        int playerLevel = GetMaxPlayerLevel();
        let actorClass = GetWonderingMonster(playerLevel);

        let mo = SpawnMonsterForRepop(actorClass);

        while (retries < REPOP_RETRY_MAX && !success)
        {
            retries++;
            let dest = GetDestination();

            
            if (TestMover.CanMove(mo, dest, true))
            {
                success = true;
            }
        }

        if (!success)
        {
            mo.Destroy();
        }
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