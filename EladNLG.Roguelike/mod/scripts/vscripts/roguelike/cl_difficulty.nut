global function Difficulty_Init
global function ServerCallback_FreezeTimer
global function ServerCallback_UnfreezeTimer
global function ServerCallback_HideTimer
global function ServerCallback_ShowTimer

global int roguelikeDifficulty

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"

struct
{
    var timeRUI
    var timeLabelRUI
    var difficultyRUI
    var difficultyLabelRUI
    BarTopoData& difficultyBar
    BarTopoData& bgBar
} file

array<string> difficulties = [
    "Easy", // 0
    "Normal", // 3
    "Hard",// 6
    "Very Hard", // 9
    "Master", // 12
    "Insane", // 15
    "Impossible", // 18
    "So, how's it going?", // 21
    "Wanna hear a song?", // 24
    "K, here goes!", // 27
    "Never gonna give",// 30
    "you up",// 33
    "Never gonna let",// 36
    "you down", // 39
    "Never gonna run", // 42
    "around and", //    45
    "desert you", // 48
    "Never gonna make", // 51
    "you cry", // 54
    "Never gonna say", // 57
    "goodbye", // 60
    "Never gonna tell", // 63
    "a lie", // 66
    "and hurt you." // 69 * 100 / 60 = 345
]

array<vector> difficultyColors = [
    <0.1, 0.9, 0.1>,
    <0.4, 0.9, 0.1>,
    <0.9, 0.9, 0.1>,
    <0.9, 0.4, 0.1>,
    <0.9, 0.1, 0.1>,
    <0.9, 0.1, 0.4>,
    <0.9, 0.1, 0.9>,
    <0.4, 0.1, 0.9>,
    <0.1, 0.1, 0.9>,
    <0.1, 0.1, 0.4>,
    <0.1, 0.1, 0.1>
]

void function Difficulty_Init()
{
    //if (GetConVarInt("roguelike_time") <= 0)
    //    RunUIScript( "ResetTimer" )
    RegisterSignal( "RoguelikeTimerOff" )
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    // TIME
    var rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.265, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.1, 0.1> )
    RuiSetString( rui, "msgText", "HARD" )
    RuiSetFloat( rui, "msgFontSize", 60.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.difficultyRUI = rui
    //file.moneyRUI = rui
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.225, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.1, 0.1> )
    RuiSetString( rui, "msgText", "DIFFICULTY" )
    RuiSetFloat( rui, "msgFontSize", 30.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )
    file.difficultyLabelRUI = rui
    // DIFFICULTY
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.1, 0> )
    RuiSetFloat3( rui, "msgColor", <0.55, 0.55, 0.55> )
    RuiSetString( rui, "msgText", "01:35" )
    RuiSetFloat( rui, "msgFontSize", 60.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.timeRUI = rui
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.15, 0> )
    RuiSetFloat3( rui, "msgColor", <0.55, 0.55, 0.55> )
    RuiSetString( rui, "msgText", "TIME" )
    RuiSetFloat( rui, "msgFontSize", 30.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )
    file.timeLabelRUI = rui
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.4, 0> )
    RuiSetFloat3( rui, "msgColor", <0.55, 0.55, 0.55> )
    RuiSetString( rui, "msgText", "made by eladnlg" )
    RuiSetFloat( rui, "msgFontSize", 30.0 )
    RuiSetFloat( rui, "msgAlpha", 0.5 )
    RuiSetFloat( rui, "thicken", 0.0 )

    float vertMultiplier = COCKPIT_RUI_WIDTH / COCKPIT_RUI_HEIGHT
    BarTopoData bg = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.39, -0.24, 0>, 0.12 + 0.005, 0.005 + 0.005 * vertMultiplier, eDirection.left, true )
    file.difficultyBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.39, -0.24, 0>, 0.12, 0.005, eDirection.left, true, 1 )
    //BasicImageBar_UpdateSegmentCount( bg, 3, 0.05 )
    BasicImageBar_UpdateSegmentCount( file.difficultyBar, 3, 0.05 )
    foreach (var rui in file.difficultyBar.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.9, 0.1, 0.1> )
    }
    foreach (var rui in bg.imageRuis )
    {
        RuiSetFloat3( rui, "basicImageColor", <0.0, 0.0, 0.0> )
        RuiSetFloat( rui, "basicImageAlpha", 0.75 )
    }
    file.bgBar = bg

    thread DifficultyRUI_Update()
}

void function RestartUpdateWhenHUDOn()
{
    if (!IsNewThread()) throw "This needs be in new thread"

    clGlobal.levelEnt.WaitSignal( "MainHud_TurnOn" )

    BasicImageBar_SetFillFrac( file.bgBar, 1.0 )

    thread DifficultyRUI_Update()
}

bool signalledHideTimer = false
void function DifficultyRUI_Update()
{
    if (IsLobby()) return
    if (!IsNewThread()) throw "MoneyRUI_Update() must be called from a new thread."

    OnThreadEnd(
        function () : (){
            if (signalledHideTimer) return
            BasicImageBar_SetFillFrac( file.difficultyBar, 0.0 )
            BasicImageBar_SetFillFrac( file.bgBar, 0.0 )
            thread RestartUpdateWhenHUDOn()
        }
    )
    bool calledEnd = false

    float lastTSLDC = 0
    while (true)
    {
        if (!calledEnd && clGlobal.levelEnt != null)
        {
            clGlobal.levelEnt.EndSignal("MainHud_TurnOff")
            clGlobal.levelEnt.EndSignal("RoguelikeTimerOff")
            calledEnd = true
        }
        float timePerDifficulty = TIME_PER_DIFFICULTY / pow(GetLevelCountMultiplier(), GetConVarInt( "level_count" ))
        float time = Time() - GetGlobalNetTime("difficultyStartTime")
        float seconds = time % 60
        int minutes = int(time) / 60
        int difficulty = int(time / timePerDifficulty)
        roguelikeDifficulty = int(time * 3 / timePerDifficulty)
        float difficultyFrac = time % timePerDifficulty / timePerDifficulty
        float timeSinceLastDifChange = time % (timePerDifficulty / 3)

        RuiSetString( file.timeRUI, "msgText", format("%02i:%02i", minutes, int(fabs(seconds))) )

        BasicImageBar_SetFillFrac( file.difficultyBar, difficultyFrac )
        vector curColor = difficultyColors[int(max(min(difficulty, difficultyColors.len() - 1),0))]
        vector resultColor = <GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.x),
                                GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.y),
                                GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.z)>

        foreach (var rui in file.difficultyBar.imageRuis )
        {
            RuiSetFloat3( rui, "basicImageColor", resultColor )
        }
        RuiSetFloat3( file.difficultyRUI, "msgColor", resultColor )
        RuiSetString( file.difficultyRUI, "msgText", difficulties[int(max(min(difficulty, difficulties.len() - 1), 0))] )
        RuiSetFloat3( file.difficultyLabelRUI, "msgColor", resultColor )
        RuiSetString( file.difficultyLabelRUI, "msgText", "Level " + (roguelikeDifficulty + 1) )
        RuiSetFloat( file.difficultyRUI, "msgFontSize", 45.0 * min(1, 13.0 / difficulties[int(max(min(difficulty, difficulties.len() - 1),0))].len()) )

        WaitFrame()
    }
}

void function ServerCallback_FreezeTimer()
{
    signalledHideTimer = true
    clGlobal.levelEnt.Signal("RoguelikeTimerOff")
}

void function ServerCallback_UnfreezeTimer()
{
    thread DifficultyRUI_Update()
}

void function ServerCallback_HideTimer()
{
    thread ServerCallback_HideTimer_Thread()
}

void function ServerCallback_HideTimer_Thread()
{
    while (file.bgBar.topoData.len() <= 0)
        WaitFrame()
    print("\n\n\n\nAAAAAAAAAAAAA")
    signalledHideTimer = true
    clGlobal.levelEnt.Signal("RoguelikeTimerOff")

    BasicImageBar_SetFillFrac( file.bgBar, 0.0 )
    BasicImageBar_SetFillFrac( file.difficultyBar, 0.0 )

    RuiSetFloat( file.timeRUI, "msgAlpha", 0.0 )
    RuiSetFloat( file.timeLabelRUI, "msgAlpha", 0.0 )
    RuiSetFloat( file.difficultyRUI, "msgAlpha", 0.0 )
    RuiSetFloat( file.difficultyLabelRUI, "msgAlpha", 0.0 )
}

void function ServerCallback_ShowTimer()
{
    BasicImageBar_SetFillFrac( file.bgBar, 1.0 )

    RuiSetFloat( file.timeRUI, "msgAlpha", 0.9 )
    RuiSetFloat( file.timeLabelRUI, "msgAlpha", 0.9 )
    RuiSetFloat( file.difficultyRUI, "msgAlpha", 0.9 )
    RuiSetFloat( file.difficultyLabelRUI, "msgAlpha", 0.9 )

    thread DifficultyRUI_Update()
}