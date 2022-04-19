global function AddCallback_OnDifficultyIncreased
global function Difficulty_Init
global function Difficulty_UpdateNPC
global function ScaleDamageWithEntityLevel

global int roguelikeDifficulty = 0

struct
{
    array<void functionref( int, int ) > difficultyCallbacks = []
} file

void function Difficulty_Init()
{
    AddCallback_OnDifficultyIncreased( DifficultyIncreased )
    //AddCallback_OnDamageEvent( DamageEvent )
    AddCallback_EntitiesDidLoad( Difficulty_Update )
}

void function ScaleDamageWithEntityLevel( entity ent, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )
    
    int level = attacker.GetTeam() == TEAM_IMC ? roguelikeDifficulty : GetLevel()
    float damageScale = 1 + 0.2 * level
    float baseDamage = DamageInfo_GetDamage( damageInfo )
    //print( "MAX DAMAGE LEVEL: " + (524287 / baseDamage) )
    if (baseDamage * damageScale > 524287)
    {
        CodeWarning( "OVER MAX DAMAGE!" )
        DamageInfo_SetDamage( damageInfo, 524287 )
    }
    else DamageInfo_ScaleDamage( damageInfo, damageScale )
}

const float TIME_PER_DIFFICULTY = 300
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
        roguelikeDifficulty = int(min(99, time / TIME_PER_DIFFICULTY * 3))
        while (lastDifficulty < roguelikeDifficulty)
        {
            foreach (void functionref( int, int ) callback in file.difficultyCallbacks)
                callback( roguelikeDifficulty, roguelikeDifficulty / 3 )
            lastDifficulty++
        }
        WaitFrame()
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
    print( "baseHealth: " + baseHealth )

    baseHealth = baseHealth + int(0.25 * baseHealth) * roguelikeDifficulty

    float healthFrac = float(npc.GetHealth()) / npc.GetMaxHealth()

    npc.SetMaxHealth( baseHealth )
    npc.SetHealth( int(baseHealth * healthFrac) )
}