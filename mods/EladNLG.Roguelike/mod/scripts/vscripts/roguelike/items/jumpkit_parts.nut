global function JumpKitParts_Init


void function JumpKitParts_Init()
{
    AddCallback_OnRoguelikeInventoryChanged( OnInventoryChanged )
	AddCallback_OnPilotBecomesTitan( UpdatePilotAndTitanStats )
	AddCallback_OnTitanBecomesPilot( UpdatePilotAndTitanStats )
    AddCallback_OnPlayerRespawned( UpdatePlayerStats )
}

void function OnInventoryChanged( entity player, string item, int oldCount, int newCount )
{
    if (!player.IsPlayer())
        return
    float moveSpeedScale = 1.0

    moveSpeedScale += 0.1 * Roguelike_GetItemCount( player, "jumpkit_parts" )

    moveSpeedScale *= 1.0 - Roguelike_GetItemCount( player, "fatigue" ) * 0.2
    
    player.SetMoveSpeedScale( moveSpeedScale )
}

void function UpdatePilotAndTitanStats( entity pilot, entity titan )
{
    pilot.SetMoveSpeedScale( 1.0 + 0.1 * Roguelike_GetItemCount( pilot, "jumpkit_parts" ) )
    //titan.SetMoveSpeedScale( 1.0 + 0.05 * Roguelike_GetItemCount( titan, "jumpkit_parts" ) )
}

void function UpdatePlayerStats( entity player )
{
    player.SetMoveSpeedScale( 1.0 + 0.1 * Roguelike_GetItemCount( player, "jumpkit_parts" ) )
}