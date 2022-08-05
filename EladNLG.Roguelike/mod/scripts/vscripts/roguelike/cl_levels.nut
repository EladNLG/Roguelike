untyped
global function ServerCallback_SetXP
global function Levels_Init
global function Roguelike_PlayerChoice

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"

struct 
{
    var levelRUI
    var weaponDataTopo
    BarTopoData& levelBar
    BarTopoData& levelBgBar
    BarTopoData& dashBar
    BarTopoData& dashBgBar
} file

global int roguelikeXP = 0
global int roguelikeLevel = 0

void function Levels_Init()
{
    AddServerToClientStringCommandCallback( "choice", MakeChoice )
    var rui = RuiCreate( RUI_TEXT_LEFT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.05, 0.21, 0> )
    RuiSetFloat3( rui, "msgColor", <0.2, 0.7, 0.9> )
    RuiSetString( rui, "msgText", "LEVEL 1" )
    RuiSetFloat( rui, "msgFontSize", 45.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )
    file.levelRUI = rui

	float vertMultiplier = COCKPIT_RUI_WIDTH / COCKPIT_RUI_HEIGHT
    file.levelBgBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < -0.385, -0.24, 0>, 0.125 + 0.005, 0.005 + 0.005 * vertMultiplier, eDirection.left, true )
    file.levelBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < -0.385, -0.24, 0>, 0.125, 0.005, eDirection.right, true, 1 )
    #if SP
    file.dashBgBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.0, 0.1, 0>, 0.05 + 0.005, 0.01 + 0.005 * vertMultiplier, eDirection.left, true )
    file.dashBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.0, 0.1, 0>, 0.05, 0.01, eDirection.right, true, 1 )
    //BasicImageBar_UpdateSegmentCount( file.dashBar, 1, 0.05 )
    #endif
    //BasicImageBar_UpdateSegmentCount( bg, 3, 0.05 )
    //BasicImageBar_UpdateSegmentCount( file.difficultyBar, 3, 0.05 )
    foreach (var rui in file.levelBar.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.2, 0.7, 0.9> )
    }
    foreach (var rui in file.levelBgBar.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.0, 0.0, 0.0> )
        RuiSetFloat( rui, "basicImageAlpha", 0.75 )
    }
    #if SP
    foreach (var rui in file.dashBar.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.2, 0.7, 0.9> )
    }
    foreach (var rui in file.dashBgBar.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.0, 0.0, 0.0> )
        RuiSetFloat( rui, "basicImageAlpha", 0.75 )
    }
    #endif

    RegisterConCommandTriggeredCallback( "+speed", void function( entity player ) : () {
        if (player.IsTitan()) return
        player.ClientCommand( "+dodge" )
        #if SP
        Roguelike_UnlockAchievement( "dashed" )
        #endif
        player.ClientCommand( "+offhand3" )
    } )
    RegisterConCommandTriggeredCallback( "-speed", void function( entity player ) : () {
        player.ClientCommand( "-dodge" )
        player.ClientCommand( "-offhand3" )
    } )

    BasicImageBar_SetFillFrac( file.levelBar, 0.75 )

    BarTopoData data
    
    thread Levels_Update()
}

vector function WorldToScreenPos( vector position )
{
    array pos = expect array( Hud.ToScreenSpace( position ) )

    vector result = <float( pos[0] ), float( pos[1] ), 0 >
    //print(result)
    return result
}

void function Levels_Update()
{
    while ( true )
    {
        WaitFrame()
        int levelXP = CalculateXPForLevel( roguelikeLevel )
        float xpFrac = float(roguelikeXP) / levelXP

        RuiSetString( file.levelRUI, "msgText", "LEVEL " + (roguelikeLevel + 1) )

        BasicImageBar_SetFillFrac( file.levelBar, xpFrac )

        #if SP
        if (IsValid( GetLocalViewPlayer() ))
        {
            BasicImageBar_SetFillFrac( file.dashBar, GetLocalViewPlayer().GetDodgePower() / 100.0 )
            if (GetLocalViewPlayer().IsTitan())
            {
                BasicImageBar_SetFillFrac( file.dashBgBar, 0.0 )
                BasicImageBar_SetFillFrac( file.dashBar, 0.0 )
            }
            else BasicImageBar_SetFillFrac( file.dashBgBar, 1.0 )
            foreach (var rui in file.dashBar.imageRuis )
            {
                RuiSetFloat3( rui, "basicImageColor", <0.2, 0.7, 0.9> * (GetLocalViewPlayer().GetDodgePower() < 100.0 ? 0.6 : 1.0) )
            }
        }
        #endif
    }

}

int BASE_XP_PER_LEVEL = 250
float XP_PER_LEVEL_MULTIPLIER = 1.1

void function ServerCallback_SetXP( int newXP, int newLevel, float XP_PER_LEVEL = 1.05, int BASE_XP = 250 )
{
    roguelikeXP = newXP
    roguelikeLevel = newLevel
    BASE_XP_PER_LEVEL = BASE_XP
    XP_PER_LEVEL_MULTIPLIER = XP_PER_LEVEL
}

int function CalculateXPForLevel( int level )
{
    return int(BASE_XP_PER_LEVEL * /*pow( XP_PER_LEVEL_MULTIPLIER, level )*/ (1.0 + (level * (XP_PER_LEVEL_MULTIPLIER - 1.0))))
}

const CONVERSATION_TIMEOUT	 					= 10.0
const CONVERSATION_INTRO_DURATION 				= 1.0
const CONVERSATION_TEXT_REMOVE_DURATION 		= 0.75
const CONVERSATION_TEXT_REMOVE_DURATION_TIMEOUT = 1.0

int function Roguelike_PlayerChoice( entity player, string choiceA, string choiceB, bool choiceAEnabled = true, bool choiceBEnabled = true )
{
    //###################################
    // Show the options RUI
    //###################################

    // RUI Choice Box
    var rui = RuiCreate( $"ui/conversation.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 9999 )
    RuiSetFloat( rui, "startTime", Time() )
    RuiSetFloat( rui, "introDuration", CONVERSATION_INTRO_DURATION )
    RuiSetFloat( rui, "timer", CONVERSATION_TIMEOUT )
    RuiSetResolutionToScreenSize( rui )

    int numChoices = 0

    if ( choiceA != "" )
    {
        numChoices++
        RuiSetString( rui, "text1", choiceA )
        RuiSetBool( rui, "choice1Available", choiceAEnabled )
        RuiSetBool( rui, "choice1WasSelected", false )
    }
    if ( choiceB != "" )
    {
        numChoices++
        RuiSetString( rui, "text2", choiceB )
        RuiSetBool( rui, "choice2Available", choiceBEnabled )
        RuiSetBool( rui, "choice2WasSelected", false )
    }

    RuiSetInt( rui, "numChoices", numChoices )

    EmitSoundOnEntity( player, "UI_PlayerDialogue_Selection" )

    //###########################################
    // Wait for user selection or timeout
    //###########################################

    table results
    if ( choiceAEnabled && choiceBEnabled )
    {
        printt( "Waiting for A or B" )
        thread DialogueChoiceTimeout( player, "DialogueChoice1", "DialogueChoice2" )
        results = WaitSignal( player, "DialogueChoice1", "DialogueChoice2", "DialogueChoiceTimeout" )
    }
    else if ( choiceAEnabled )
    {
        printt( "Waiting for A" )
        thread DialogueChoiceTimeout( player, "DialogueChoice1" )
        results = WaitSignal( player, "DialogueChoice1", "DialogueChoiceTimeout" )
    }
    else if ( choiceBEnabled )
    {
        printt( "Waiting for B" )
        thread DialogueChoiceTimeout( player, "DialogueChoice2" )
        results = WaitSignal( player, "DialogueChoice2", "DialogueChoiceTimeout" )
    }

    //#################################################
    // User has made selection or timed out, handle it
    //#################################################

    int choice
    float responseDuration = 2.0
    switch( results.signal )
    {
        case "DialogueChoice1":
            choice = 1
            break

        case "DialogueChoice2":
            choice = 2
            break

        case "DialogueChoiceTimeout":
        default:
            choice = 0
            break
    }

    float textFadeOutDuration = choice == 0 ? CONVERSATION_TEXT_REMOVE_DURATION_TIMEOUT : CONVERSATION_TEXT_REMOVE_DURATION

    // Tell the RUI we have made a selection, or lack of one.
    RuiSetFloat( rui, "choiceMadeTime", Time() )
    RuiSetFloat( rui, "choiceDuration", responseDuration )
    RuiSetFloat( rui, "textRemoveDuration", textFadeOutDuration )
    RuiSetInt( rui, "choiceMade", choice )

    if ( choice == 0 )
        EmitSoundOnEntity( player, "UI_PlayerDialogue_Notification" )
    else
        EmitSoundOnEntity( player, "ui_holotutorial_Analyzingfinish" )

    return choice
}

void function DialogueChoiceTimeout( entity player, cancelTimeoutSignal_A = "", cancelTimeoutSignal_B = "" )
{
    EndSignal( player, "OnDeath" )
    EndSignal( player, "OnDestroy" )
    if ( cancelTimeoutSignal_A != "" )
        EndSignal( player, cancelTimeoutSignal_A )
    if ( cancelTimeoutSignal_B != "" )
        EndSignal( player, cancelTimeoutSignal_B )

    wait CONVERSATION_INTRO_DURATION + CONVERSATION_TIMEOUT

    if ( IsValid( player ) )
        Signal( player, "DialogueChoiceTimeout" )
}

void function MakeChoice( array<string> args )
{
    string argStr = ""
    foreach (int index, string arg in args)
    {
        argStr += arg + " "
    }

    array<string> choices = split( argStr, "|" )

    thread ChooseAndSendResultToServer( choices[0], choices[1] )
}

void function ChooseAndSendResultToServer( string a, string b )
{
    int result = Roguelike_PlayerChoice( GetLocalClientPlayer(), a, b )

    GetLocalClientPlayer().ClientCommand("choose " + result )
}