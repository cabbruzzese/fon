class fonFlaskYellow : HNecroHealthFlaskYellow replaces HNecroHealthFlaskYellow
{
	override bool Use (bool pickup)
	{
        int maxHeal = 200;
        let playerPawn = PlayerPawn(Owner);
        if (playerPawn)
            maxHeal = playerPawn.MaxHealth + health;
        
        return Owner.GiveBody (health, maxHeal);
	}
}
