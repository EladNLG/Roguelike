global function Difficulty_Init

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"

struct 
{
    var timeRUI
    var difficultyRUI
    var difficultyLabelRUI
    BarTopoData& difficultyBar
    BarTopoData& bgBar
} file

array<string> difficulties = [
    "Easy",
    "Normal",
    "Hard",
    "Very Hard",
    "Master",
    "Insane",
    "Impossible",
    "So, how's it going?",
    "Wanna hear a song?",
    "K, here goes!",
    "Never gonna give",
    "you up",
    "Never gonna let",
    "you down",
    "Never gonna run",
    "around and",
    "desert you",
    "Never gonna make",
    "you cry",
    "Never gonna say",
    "goodbye",
    "Never gonna tell",
    "a lie",
    "and hurt you."
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
    AddCallback_EntitiesDidLoad( EntitiesDidLoad )
}

void function EntitiesDidLoad()
{
    // TIME
    var rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.315, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.1, 0.1> )
    RuiSetString( rui, "msgText", "HARD" )
    RuiSetFloat( rui, "msgFontSize", 90.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.difficultyRUI = rui
    //file.moneyRUI = rui
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.265, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.1, 0.1> )
    RuiSetString( rui, "msgText", "DIFFICULTY" )
    RuiSetFloat( rui, "msgFontSize", 45.0 )
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
    RuiSetFloat( rui, "msgFontSize", 90.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.timeRUI = rui
    rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.175, 0> )
    RuiSetFloat3( rui, "msgColor", <0.55, 0.55, 0.55> )
    RuiSetString( rui, "msgText", "TIME" )
    RuiSetFloat( rui, "msgFontSize", 45.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )

    BarTopoData bg = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.375, -0.185, 0>, 0.15, 0.01, eDirection.left, true, 1 )
    file.difficultyBar = BasicImageBar_CreateRuiTopo( <0,0,0>, < 0.375, -0.185, 0>, 0.15, 0.01, eDirection.left, true, 1 )
    BasicImageBar_UpdateSegmentCount( bg, 3, 0.05 )
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

const float TIME_PER_DIFFICULTY = 300
void function DifficultyRUI_Update()
{
    if (IsLobby()) return
    if (!IsNewThread()) throw "MoneyRUI_Update() must be called from a new thread."

    OnThreadEnd(
        function () : (){
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
            calledEnd = true
        }
        float time = Time() - GetGlobalNetTime("difficultyStartTime")
        float seconds = time % 60
        int minutes = int(time) / 60
        int difficulty = int(time / TIME_PER_DIFFICULTY)
        float difficultyFrac = time % TIME_PER_DIFFICULTY / TIME_PER_DIFFICULTY
        float timeSinceLastDifChange = time % (TIME_PER_DIFFICULTY / 3)

        RuiSetString( file.timeRUI, "msgText", format("%02i:%02i", minutes, int(fabs(seconds))) )
        
        BasicImageBar_SetFillFrac( file.difficultyBar, difficultyFrac )
        vector curColor = difficultyColors[int(min(difficulty, difficultyColors.len() - 1))]
        vector resultColor = <GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.x),
                                GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.y),
                                GraphCapped(timeSinceLastDifChange, 0, 3, 1, curColor.z)>
        
        foreach (var rui in file.difficultyBar.imageRuis )
        {
            RuiSetFloat3( rui, "basicImageColor", resultColor )
        }
        RuiSetFloat3( file.difficultyRUI, "msgColor", resultColor )
        RuiSetString( file.difficultyRUI, "msgText", difficulties[int(min(difficulty, difficulties.len() - 1))] )
        RuiSetFloat3( file.difficultyLabelRUI, "msgColor", resultColor )
        RuiSetFloat( file.difficultyRUI, "msgFontSize", 90.0 * min(1, 7.0 / difficulties[int(min(difficulty, difficulties.len() - 1))].len()) )

        WaitFrame()
    }
}