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
    Hud_AddEventHandler( result[1], UIE_CLICK, AdvanceMenuEventHandler(GetMenu("Logbook")) )
    Hud_AddEventHandler( result[3], UIE_CLICK, PlayCampaign )
    return result
}

void function PlayCampaign(var button) {
    LaunchSPMissionSelect()
}