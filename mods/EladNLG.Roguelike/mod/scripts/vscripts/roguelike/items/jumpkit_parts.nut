global function JumpKitParts_Init


void function JumpKitParts_Init()
{
    AddCallback_OnRoguelikeInventoryChanged( UpdatePlayerStats )
	AddCallback_OnPilotBecomesTitan( UpdateTitanStats )
	AddCallback_OnTitanBecomesPilot( UpdatePilotStats )
    AddCallback_OnPlayerRespawned( UpdatePlayerStats )
}

void function UpdateTitanStats( entity player, entity titan )
{
    player.SetMoveSpeedScale(1.0)
    if (PlayerHasPassive( player, ePassives.PAS_SHIFT_CORE ) )
        player.SetPowerRegenRateScale( 6.5 + (0.065 * Roguelike_GetEntityStat( player, "mobility" ) ) )
    else player.SetPowerRegenRateScale( 1.0 + (0.01 * Roguelike_GetEntityStat( player, "mobility" ) ) )
    //owner.SetDodgePowerDelayScale( 1.0 )
}

void function UpdatePilotStats( entity player, entity titan )
{
    float moveSpeedScale = 1.0

    moveSpeedScale += 0.1 * Roguelike_GetItemCount( player, "jumpkit_parts" )

    moveSpeedScale *= 1.0 + Roguelike_GetEntityStat( player, "mobility" ) / 300.0

    moveSpeedScale *= 1.0 - Roguelike_GetItemCount( player, "fatigue" ) * 0.2
    player.SetPowerRegenRateScale( 1.0 + (0.01 * Roguelike_GetEntityStat( player, "discipline" ) ) )
    player.SetMoveSpeedScale( moveSpeedScale )
    //titan.SetMoveSpeedScale( 1.0 + 0.05 * Roguelike_GetItemCount( titan, "jumpkit_parts" ) )
}

void function UpdatePlayerStats( entity player )
{
    if (!player.IsPlayer())
        return
    if (player.IsTitan())
    {
        player.SetMoveSpeedScale(1.0)
        if (PlayerHasPassive( player, ePassives.PAS_SHIFT_CORE ) )
            player.SetPowerRegenRateScale( 6.5 + (0.065 * Roguelike_GetEntityStat( player, "mobility" ) ) )
        else player.SetPowerRegenRateScale( 1.0 + (0.01 * Roguelike_GetEntityStat( player, "mobility" ) ) )
        return
    }
    float moveSpeedScale = 1.0

    moveSpeedScale += 0.1 * Roguelike_GetItemCount( player, "jumpkit_parts" )

    moveSpeedScale *= 1.0 + Roguelike_GetEntityStat( player, "mobility" ) / 300.0

    moveSpeedScale *= 1.0 - Roguelike_GetItemCount( player, "fatigue" ) * 0.2
    player.SetPowerRegenRateScale( 1.0 + (0.01 * Roguelike_GetEntityStat( player, "discipline" ) ) )
    player.SetMoveSpeedScale( moveSpeedScale )
}