global function StartRun_Init
global function GetDifficultyButton

struct {
    var menu
    var difficulty
} file

void function StartRun_Init()
{
	AddMenu( "StartRun", $"resource/ui/menus/start_run.menu", InitMenu )
}

void function InitMenu()
{
    file.menu = GetMenu( "StartRun" )
    var menu = file.menu

    ComboStruct comboStruct = ComboButtons_Create( menu )

    int headerIndex = 0
    int buttonIndex = 0
    AddComboButtonHeader( comboStruct, headerIndex, "Artifacts" )
    var difficulty = AddComboButton( comboStruct, headerIndex, buttonIndex++, "Coming Soon" )
    Hud_SetLocked( difficulty, true )
    headerIndex++
    buttonIndex = 0
    AddComboButtonHeader( comboStruct, headerIndex, "Settings" )
    difficulty = AddComboButton( comboStruct, headerIndex, buttonIndex++, "Skip Redundant Levels [Yes]" )
    Hud_SetLocked( difficulty, true )
    difficulty = Hud_GetChild( menu, "SelectDifficulty")
    Hud_DialogList_AddListItem( difficulty, "Easy", "0" )
    Hud_DialogList_AddListItem( difficulty, "Normal", "1" )
    Hud_DialogList_AddListItem( difficulty, "Hard", "2" )
    Hud_DialogList_AddListItem( difficulty, "Master", "3" )
    Hud_DialogList_AddListItem( difficulty, "I'm MoDen31 (difficulty scales backwards)", "-6" )
    SetButtonRuiText(difficulty, "Difficulty")
    file.difficulty = difficulty

    Hud_AddEventHandler( Hud_GetChild( menu, "StartRun" ), UIE_CLICK, NewRun )

    ComboButtons_Finalize( comboStruct )
}

var function GetDifficultyButton()
{
    return file.difficulty
}