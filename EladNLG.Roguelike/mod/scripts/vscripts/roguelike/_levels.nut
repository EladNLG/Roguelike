global function Levels_Init
global function AddXP
global function GetLevel

const int BASE_XP_PER_LEVEL = 250
const float XP_PER_LEVEL_MULTIPLIER = 1.1

int xp = 0
int level = 0

void function Levels_Init()
{
    xp = GetConVarInt( "player_xp" )
    level = GetConVarInt( "player_level" )
    print("\nXP: " + xp + "\nLEVEL: " + level)

    AddCallback_OnLevelEnd( OnLevelEnd )
    AddCallback_OnPlayerRespawned( ClientConnected )
    AddCallback_OnLoadSaveGame( OnLoadSaveGame )
    thread Levels_Update()
}

void function OnLoadSaveGame( entity player )
{
    thread UpdateLevels()
}

void function UpdateLevels()
{
    WaitFrame()

    foreach ( entity player in GetPlayerArray() )
    {
        Remote_CallFunction_NonReplay( player, "ServerCallback_SetXP", xp, level )
    }
}

void function Levels_Update()
{
    while( true )
    {
        foreach (entity player in GetPlayerArray())
            if (IsAlive( player ) && player.GetMaxHealth() != CalculatePlayerMaxHP( player ))
            {
                Remote_CallFunction_Replay( player, "ServerCallback_SetXP", xp, level )
                OnLevelUp()
            }
        WaitFrame()
    }
}
void function ClientConnected( entity player )
{
    Remote_CallFunction_Replay( player, "ServerCallback_SetXP", xp, level, XP_PER_LEVEL_MULTIPLIER, BASE_XP_PER_LEVEL )
    OnLevelUp()
}

int function CalculateXPForLevel( int level )
{
    return int(BASE_XP_PER_LEVEL * pow( XP_PER_LEVEL_MULTIPLIER, level ))
}

int function GetLevel()
{
    return level
}

void function AddXP( int amount )
{
    xp += amount
    if( xp >= CalculateXPForLevel( level ) )
    {
        level += 1
        xp -= CalculateXPForLevel( level - 1 )
    }

    foreach (player in GetPlayerArray())
    {
        Remote_CallFunction_Replay( player, "ServerCallback_SetXP", xp, level )
    }
}

int function CalculatePlayerMaxHP( entity player )
{
    int baseHP = int(player.GetPlayerModHealth())
    if (player.IsTitan())
    {
        if (player.GetTitanSoul().IsDoomed())
            baseHP /= 5
    }

    return baseHP + int(0.2 * baseHP) * level
}

void function OnLevelUp()
{
    foreach (entity player in GetPlayerArray())
    {
        if (!IsAlive( player )) continue
        int baseHP = CalculatePlayerMaxHP(player)
        float healthFrac = float(player.GetHealth()) / player.GetMaxHealth()
        player.SetMaxHealth(baseHP)
        player.SetHealth( int(min(baseHP, baseHP * healthFrac + 20)) )
    }
}

void function OnLevelEnd( string mapName, LevelTransitionStruct trans )
{
    SetConVarInt( "player_xp", xp )
    SetConVarInt( "player_level", level )
}