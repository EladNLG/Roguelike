global function RunTableToStruct
global function RunStructToTable

global enum RunResult
{
    DEFEAT,
    VICTORY,
    CRASH
}

global struct RunWeaponData
{
    string className
    array<string> mods
}

global struct RunData
{
    int unixTimestamp 
    int result
    string causeOfDeath
    string killerClassName
    string lastMapReached
    table<string, int> itemsCollected
    int runTime
    int damageDone
    int kills
    array<string> friends = []
    array<RunWeaponData> weapons = []
}

RunData function RunTableToStruct( table t )
{
    RunData data
    data.unixTimestamp = GetTableInt( t, "unixTimestamp" )
    data.causeOfDeath = GetTableString( t, "causeOfDeath" )
    data.killerClassName = GetTableString( t, "killerClassName" )
    data.lastMapReached = GetTableString( t, "lastMapReached", "sp_crashsite" )
    foreach (string key, var value in GetTableTable( t, "itemsCollected" ))
        data.itemsCollected[key] <- expect int( value )
    data.runTime = GetTableInt( t, "runTime" )
    data.damageDone = GetTableInt( t, "damageDone" )
    data.kills = GetTableInt( t, "kills" )
    foreach (var value in GetTableArray( t, ""))
}

/*
{
    "unixTimestamp": 1999999999,
    "causeOfDeath": "mp_weapon_frag_grenade",
    "killerClassName": "npc_soldier",
    "lastMapReached": "sp_sewers1",
    "itemsCollected": {
        "adrenaline_shot": 1,
        "jumpkit_parts": 2,
        "ammo_pack": 4,
        "emergency_soda": 1
    },
    "runTime": 420,
    "damageDone": 51245,
    "kills": 138
}
*/