globalize_all_functions

global const PLAYER_HAS_ROGUELIKE_MOD = true

array<var> function AddRoguelikeMenu( ComboStruct comboStruct )
{
    AddComboButtonHeader( comboStruct, 0, "ROGUELIKE" )
    array<var> result = []
    result.append(AddComboButton( comboStruct, 0, 0, "New Run" ))
    result.append(AddComboButton( comboStruct, 0, 1, "Logbook" ))
    result.append(AddComboButton( comboStruct, 0, 2, "Stats" ))
    result.append(AddComboButton( comboStruct, 0, 3, "Play Campaign" ))
    Hud_AddEventHandler( result[0], UIE_CLICK, NewRun )
    Hud_AddEventHandler( result[1], UIE_CLICK, AdvanceMenuEventHandler(GetMenu("Logbook")) )
    Hud_AddEventHandler( result[3], UIE_CLICK, PlayCampaign )
    return result
}

void function PlayCampaign(var button) {
    LaunchSPMissionSelect()
}

void function NewRun( var button )
{
    SetConVarInt( "player_xp", 0 )
    SetConVarInt( "player_level", 0 )
    SetConVarInt( "roguelike_time", 0 )
    SetConVarInt( "sp_startpoint", 6 )
    SetConVarString( "player_1_items", "" )
    SetConVarString( "player_2_items", "" )
    SetConVarString( "player_3_items", "" )
    SetConVarString( "player_4_items", "" )
    if (!NSIsModEnabled( "TF|Roguelike" ))
    {
        NSSetModEnabled( "TF|Roguelike", true )
        NSReloadMods() // do this now so we don't have to worry about TF|Roguelike not being enabled
        ClientCommand( "uiscript_reset; map sp_crashsite" )
    }
    else ClientCommand( "map sp_crashsite" )
}