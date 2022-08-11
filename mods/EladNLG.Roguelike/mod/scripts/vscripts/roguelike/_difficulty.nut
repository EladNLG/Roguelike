untyped
global function AddCallback_OnDifficultyIncreased
global function Difficulty_Init
global function Difficulty_UpdateNPC
global function ScaleDamageWithEntityLevel
global function GetChestCost
global function ForceDifficultyCallbacks

global int roguelikeDifficulty = 0
global int levelCount = 0

struct
{
    array<void functionref( int, int ) > difficultyCallbacks = []
} file

void function Difficulty_Init()
{
    if (IsLobby()) return
    levelCount = GetConVarInt( "level_count" )
    AddCallback_OnDifficultyIncreased( DifficultyIncreased )
    //AddCallback_OnDamageEvent( DamageEvent )
    AddCallback_EntitiesDidLoad( Difficulty_Update )
    AddCallback_EntitiesDidLoad( PreventTimerOnCutscene )
}


void function ForceDifficultyCallbacks()
{
    float time = Time() - GetGlobalNetTime("difficultyStartTime")
    float timePerDifficulty = TIME_PER_DIFFICULTY / pow(GetLevelCountMultiplier(), levelCount)
    roguelikeDifficulty = int(time * 3 / timePerDifficulty)
    foreach (void functionref( int, int ) callback in file.difficultyCallbacks)
        callback( roguelikeDifficulty, roguelikeDifficulty / 3 )
}

void function ScaleDamageWithEntityLevel( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    float damage = DamageInfo_GetDamage( damageInfo )
    print(damage)

    if (DamageInfo_GetForceKill( damageInfo ))
        return

    if (attacker != ent && attacker.GetClassName() != "trigger_hurt")
    {
        int level = !attacker.IsPlayer() ? roguelikeDifficulty : GetLevel()
        float damageScale = 1 + 0.2 * max(-4, level)
        if ("divisor" in ent.s)
            damageScale /= expect float( ent.s.divisor )
        float baseDamage = DamageInfo_GetDamage( damageInfo )
        print(baseDamage * damageScale)
        //print( "MAX DAMAGE LEVEL: " + (524287 / baseDamage) )
        if (baseDamage * damageScale > 524287)
        {
            CodeWarning( "OVER MAX DAMAGE!" )
            DamageInfo_SetDamage( damageInfo, 524287 )
        }
        else DamageInfo_ScaleDamage( damageInfo, damageScale )
    }
    else
    {
        printt("DAMAGE", damage, ent.GetMaxHealth())
        if (damage * float(ent.GetMaxHealth()) / 100.0 > 524287)
            DamageInfo_SetDamage( damageInfo, 524287 )
        else DamageInfo_ScaleDamage( damageInfo, float(ent.GetMaxHealth()) / ent.GetPlayerModHealth())
    }
}

int function GetChestCost(float multiplier = 1.0)
{
    //print(50 * (1 + 0.2 * initialDifficulty) * multiplier)
    return int(50 * (1 + 0.2 * GetInitialDifficulty()) * multiplier)
}

int function GetInitialDifficulty()
{
    float timePerDifficulty = TIME_PER_DIFFICULTY / pow(GetLevelCountMultiplier(), levelCount)
    return int(GetConVarInt("roguelike_time") * 3 / timePerDifficulty)
}

void function Difficulty_Update()
{
    if (!IsNewThread())
    {
        thread Difficulty_Update()
        return
    }
    int lastDifficulty = 0;
    while (true)
    {
        float time = Time() - GetGlobalNetTime("difficultyStartTime")
        float timePerDifficulty = TIME_PER_DIFFICULTY / pow(GetLevelCountMultiplier(), levelCount)
        roguelikeDifficulty = int(time * 3 / timePerDifficulty)
        //print(roguelikeDifficulty)
        while (lastDifficulty < roguelikeDifficulty)
        {
            foreach (void functionref( int, int ) callback in file.difficultyCallbacks)
                callback( roguelikeDifficulty, roguelikeDifficulty / 3 )
            lastDifficulty++
        }
        WaitFrame()
    }
}

void function PreventTimerOnCutscene()
{
    entity player

    if (!IsNewThread())
        thread PreventTimerOnCutscene()

    while (true)
    {
        if (!IsValid(player))
        {
            while (GetPlayerArray().len() <= 0)
            {
                WaitFrame()
                print("shit")
            }
            player = GetPlayerArray()[0]
        }
        player.WaitSignal("NewFirstPersonSequence")
        print("\n\n\n\n\n\nAH SHIT")
        float startTime = Time()
        WaitFrame()
        foreach( P in GetPlayerArray() )
            Remote_CallFunction_NonReplay( P, "ServerCallback_FreezeTimer" )
        WaittillAnimDone( player )
        print("\nANIM TIME:\n" + (Time() - startTime))
        RemoveFromTimer( Time() - startTime )
        foreach( P in GetPlayerArray() )
            Remote_CallFunction_NonReplay( P, "ServerCallback_ShowTimer" )
    }
}

void function AddCallback_OnDifficultyIncreased( void functionref( int, int ) callback )
{
    file.difficultyCallbacks.append( callback )
}

void function DifficultyIncreased( int newDifficulty, int newDifficultyLevel )
{
    foreach (entity npc in GetNPCArray())
    {
        //print(npc)
        Difficulty_UpdateNPC( npc )
    }
}

void function Difficulty_UpdateNPC( entity npc )
{
    if (typeof( npc.Dev_GetAISettingByKeyField( "Health" ) ) == "string") return

    int baseHealth = expect int( npc.Dev_GetAISettingByKeyField( "Health" ) )

    //printt("BASE HEALTH:", baseHealth)
    //printt("NEW BASE HEALTH:", baseHealth)
    //printt("HEALTH PER LEVEL:", int(0.3 * baseHealth))
    //printt("ROGUELIKE_DIFFICULTY:", roguelikeDifficulty)
    //printt("HEALTH FROM LEVELS:", int(0.3 * baseHealth) * roguelikeDifficulty)
    int newBaseHealth = baseHealth + int(0.3 * baseHealth) * roguelikeDifficulty
    //printt("NEW HEALTH:", newBaseHealth)
    baseHealth = int(clamp( newBaseHealth, 1, 524287))

    if (newBaseHealth > baseHealth)
    {
        float divisor = float(newBaseHealth) /   baseHealth
        npc.s.damageDivisor <- divisor
    }



    float healthFrac = float(npc.GetHealth()) / npc.GetMaxHealth()

    npc.SetMaxHealth( baseHealth )
    npc.SetHealth( int(baseHealth * healthFrac) )
}