global function ServerCallback_SetXP
global function Levels_Init

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"

struct 
{
    var levelRUI
    BarTopoData& levelBar
    BarTopoData& levelBgBar
} file

int xp = 0
int level = 0

void function Levels_Init()
{
    var rui = RuiCreate( RUI_TEXT_LEFT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.05, 0.225, 0> )
    RuiSetFloat3( rui, "msgColor", <0.2, 0.7, 0.9> )
    RuiSetString( rui, "msgText", "LEVEL 1" )
    RuiSetFloat( rui, "msgFontSize", 90.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.levelRUI = rui

	float vertMultiplier = COCKPIT_RUI_WIDTH / COCKPIT_RUI_HEIGHT
    file.levelBgBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < -0.375, -0.185, 0>, 0.15 + 0.005, 0.01 + 0.005 * vertMultiplier, eDirection.left, true )
    file.levelBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < -0.375, -0.185, 0>, 0.15, 0.01, eDirection.right, true, 1 )
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

    BasicImageBar_SetFillFrac( file.levelBar, 0.75 )

    thread Levels_Update()
}

void function Levels_Update()
{
    while ( true )
    {
        int levelXP = CalculateXPForLevel( level )
        float xpFrac = float(xp) / levelXP

        RuiSetString( file.levelRUI, "msgText", "LEVEL " + (level + 1) )

        BasicImageBar_SetFillFrac( file.levelBar, xpFrac )
        
        WaitFrame()
    }

}

int BASE_XP_PER_LEVEL = 250
float XP_PER_LEVEL_MULTIPLIER = 1.1

void function ServerCallback_SetXP( int newXP, int newLevel, float XP_PER_LEVEL = 1.05, int BASE_XP = 250 )
{
    xp = newXP
    level = newLevel
    BASE_XP_PER_LEVEL = BASE_XP
    XP_PER_LEVEL_MULTIPLIER = XP_PER_LEVEL
}

int function CalculateXPForLevel( int level )
{
    return int(BASE_XP_PER_LEVEL * pow( XP_PER_LEVEL_MULTIPLIER, level ))
}