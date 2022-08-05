untyped

int highestScore = 0
int secondHighestScore = 0
int ourScore = 0

globalize_all_functions

void function OnPrematchStart()
{
    //NSUpdateTimeInfo( GetGlobalNetTime("difficultyStartTime") - Time() )
}

void function NSUpdateGameStateClientStart()
{
    #if MP
    AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
    #endif
    AddCallback_EntitiesDidLoad( AAAAAAAAAAAAAAAAAAAEntitiesDidLoad )
}

// WHO DID GLOBALIZE_ALL_FUNCTIONS??????????
void function AAAAAAAAAAAAAAAAAAAEntitiesDidLoad()
{
    thread NSUpdateGameStateLoopClient()
    OnPrematchStart()
}

void function NSUpdateGameStateLoopClient()
{
    while ( true )
    {
        foreach ( player in GetPlayerArray() )
        {
            if ( GameRules_GetTeamScore( player.GetTeam() ) >= highestScore )
            {
                highestScore = GameRules_GetTeamScore( player.GetTeam() )
            }
            else if ( GameRules_GetTeamScore( player.GetTeam() ) > secondHighestScore )
            {
                secondHighestScore = GameRules_GetTeamScore( player.GetTeam() )
            }
        }
        if ( GetLocalClientPlayer() != null )
        {
            ourScore = GameRules_GetTeamScore( GetLocalClientPlayer().GetTeam() )
        }
        int limit = 99
        array<string> maps = [
            "sp_training",
            "sp_crashsite",
            "sp_sewers1",
            "sp_timeshift_spoke02",
            "sp_hub_timeshift",
            "sp_beacon_spoke0",
            "sp_beacon",
            "sp_tday",
            "sp_s2s",
            "sp_skyway_v1"
        ]
        NSUpdateGameStateClient( maps.find( GetMapName() ) <= 0 ? 1 : maps.find( GetMapName() ), maps.len(), roguelikeLevel + 1, roguelikeDifficulty + 1, roguelikeLevel + 1, false, 99 )
        OnPrematchStart()
        wait 1.0
    }
}