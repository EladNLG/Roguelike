untyped

global function FragileBird_Init

void function FragileBird_Init()
{
    AddCallback_OnClientConnected( PlayerConnected )
}

void function PlayerConnected( entity player )
{
    thread Player_Update( player )
}

void function Player_Update( entity player )
{
    bool isWallRunning = true
    while ( true )
    {
        wait 0.1
        if (player.IsTitan()) continue

        float airAcceleration = 500 // base air accel
        int stacks = Roguelike_GetItemCount( player, "fragile_bird" )
        int lStacks = Roguelike_GetItemCount( player, "leeching_hands" )

        if ( stacks <= 0 && lStacks <= 0 ) continue

        float bonus = 0.2 * stacks
        airAcceleration *= 1 + bonus

        if (player.IsWallRunning() && isWallRunning)
        {
            //print("Dealing " + int(30 * stacks * 0.1) + " damage for deltaTime " + 0.1)
            if (lStacks > 0) player.SetHealth( min( player.GetHealth() + (20 * lStacks * 0.1), player.GetMaxHealth() ) )
            if (stacks > 0) player.TakeDamage( 30 * stacks * 0.1, player, player, { scriptType = DF_NO_INDICATOR } )
        }
        // we do this to delay the damage a bit so those who wallkick don't get a bunch of damage based on things out of their control.
        else if (player.IsWallRunning()) isWallRunning = true
        else isWallRunning = false

        if (player.kv.airAcceleration.tofloat() < airAcceleration && stacks > 0)
        {
            player.kv.airAcceleration = airAcceleration
        }
    }
}