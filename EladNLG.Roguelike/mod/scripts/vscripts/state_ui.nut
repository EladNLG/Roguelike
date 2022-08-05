untyped

globalize_all_functions

void function NSUpdateGameStateUIStart()
{
    thread NSUpdateGameStateLoopUI()
}

void function NSUpdateGameStateLoopUI()
{
    bool isLoading = false
    while ( true )
    {
        wait 1.0
        if ( uiGlobal.loadedLevel == "" )
        {
            if ( uiGlobal.isLoading )
            {
                isLoading = true
                NSSetLoading( true )
            }
            else
            {
                NSSetLoading( false )
                NSUpdateGameStateUI( "a", "", "", "", true, false )
            }
            continue
        }
        NSSetLoading( false )
        NSUpdateGameStateUI( GetActiveLevel(), // gamemode
        Localize( "#" + GetActiveLevel().toupper() + "_CAMPAIGN_NAME" ), // Gamemode name
        "solo", "Roguelike - Mission", IsFullyConnected(), false )
    }
}

void function ResetTimer()
{
    NSUpdateGameStateUI( "", "", "solo", "Roguelike", true, false )
}