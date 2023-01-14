globalize_all_functions

global bool allowMP = true
global bool allowSP = true

float startTime = 0.0

array<var> function AddRoguelikeMenu( ComboStruct comboStruct )
{
    AddComboButtonHeader( comboStruct, 0, "ROGUELIKE" )
    array<var> result = []
    result.append(AddComboButton( comboStruct, 0, 0, "New Run" ))
    result.append(AddComboButton( comboStruct, 0, 1, "Logbook" ))
    result.append(AddComboButton( comboStruct, 0, 2, "Stats" )) // maybe not
    Hud_SetLocked( result[2], true )
    result.append(AddComboButton( comboStruct, 0, 3, "Play Campaign" ))
    Hud_AddEventHandler( result[0], UIE_CLICK, OpenNewRunMenu )// NewRun )
    Hud_AddEventHandler( result[1], UIE_CLICK, AdvanceMenuEventHandler(GetMenu("Logbook")) )
    Hud_AddEventHandler( result[3], UIE_CLICK, PlayCampaign )
    
    return result
}

void function Roguelike_OnLoadingScreen()
{

}

void function OpenNewRunMenu(var button)
{
    if (!allowSP)
    {
        OpenSPDisabledPopup()
        return
    }
    AdvanceMenu(GetMenu("StartRun"))
}

void function PlayCampaign(var button) {
    LaunchSPMissionSelect()
}

void function NewRun( var button )
{
    int seed = int( Hud_GetUTF8Text( Hud_GetChild( GetMenu( "StartRun"), "SetSeed") ) )
    bool resetScript = false
    if (!NSIsModEnabled( "TF|Roguelike" ))
    {
        resetScript = true
        NSSetModEnabled( "TF|Roguelike", true )
        NSReloadMods() // do this now so we don't have to worry about TF|Roguelike not being enabled
    }
    SetConVarInt( "player_xp", 0 )
    SetConVarInt( "player_level", 0 )
    SetConVarInt( "roguelike_time", 0 )
    SetConVarInt( "roguelike_seed", 0 )
    SetConVarString( "player_armor", "" )
    SetConVarInt( "sp_startpoint", 7 )
    SetConVarInt( "level_count", 0 )
    SetConVarString( "player_items", "" )
    SetConVarInt( "roguelike_difficulty", int( Hud_GetDialogListSelectionValue( GetDifficultyButton() ) ) )
    if (resetScript) ClientCommand( "uiscript_reset; map sp_crashsite" )
    else ClientCommand( "map sp_crashsite" )
}

void function OpenSPDisabledPopup()
{
	DialogData dialogData
	dialogData.header = "ROGUELIKE UNAVAILABLE"
	dialogData.message = "To play roguelike, it needs to be toggled on. This requires a restart. Do you wish to toggle it on and close the game?"
	dialogData.image = $"ui/menu/common/dialog_error"
	AddDialogButton( dialogData, "#YES", void function() { 
		NSSetModEnabled("TF|Roguelike", true)
        thread QuitGameWithFrameDelay()
	} )
	AddDialogButton( dialogData, "#NO" )

	OpenDialog(dialogData)
}

void function OpenMPDisabledPopup()
{
	DialogData dialogData
	dialogData.header = "MULTIPLAYER UNAVAILABLE"
	dialogData.message = "To play MP, roguelike needs to be toggled off. This requires a restart. Do you wish to toggle it off and close the game?"
	dialogData.image = $"ui/menu/common/dialog_error"
	AddDialogButton( dialogData, "#YES", void function() { 
		NSSetModEnabled("TF|Roguelike", false)
        thread QuitGameWithFrameDelay()
	} )
	AddDialogButton( dialogData, "#NO" )

	OpenDialog(dialogData)
}

void function OpenFuckedUp_Thread()
{
	WaitFrame()
	OpenFuckedUp()
}

void function QuitGameWithFrameDelay()
{
    WaitFrame()
    ClientCommand("reload_mods; quit")
}

void function OpenFuckedUp()
{
	DialogData dialogData
	dialogData.header = "ROGUELIKE ERROR"
	dialogData.message = "Roguelike was toggled on/off manually. This makes both the campaign and multiplayer crash, unless a restart is done. Please close the game."
	dialogData.image = $"ui/menu/common/dialog_error"

	AddDialogButton( dialogData, "#OK", void function() { 
        ClientCommand("quit")
	} )
	OpenDialog(dialogData)
}