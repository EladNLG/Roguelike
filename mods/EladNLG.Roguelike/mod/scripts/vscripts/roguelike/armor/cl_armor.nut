untyped
global function ClArmor_Init
global function ArmorDropGainedFocus
global function ArmorDropLostFocus
global function Roguelike_SetupStats
var armorRes = null
array<vector> colors = [
    <0.6, 0.2, 0.2>,
    <0.2, 0.6, 0.2>,
    <0.2, 0.2, 0.6>,
    <0.6, 0.2, 0.4>,
    <0.6, 0.6, 0.2>
]

void function ClArmor_Init()
{
    AddServerToClientStringCommandCallback( "UpdateArmor", UpdateArmor )
}

void function ArmorDropGainedFocus( entity ent )
{
    print("hello")
    armorRes = HudElement("ArmorUI")
    string strData = ent.GetScriptName().slice( 6, ent.GetScriptName().len() )
    ArmorData data = StringToArmorData(strData)
    Roguelike_SetupStats(data)
    Hud_SetVisible(armorRes, true)
}

void function ArmorDropLostFocus( entity ent )
{
    Hud_SetVisible(armorRes, false)
}

void function Roguelike_SetupStats( ArmorData data )
{
    //ArmorData prevData = Armor_Create( "TEST ARMOR", RARITY_LEGENDARY )
    Hud_SetText(Hud_GetChild(armorRes, "ItemTitle"), data.name)
    print(data.slot)

    ArmorData prev = Roguelike_GetEntityArmor( GetLocalClientPlayer(), data.slot )
    Hud_SetColor(Hud_GetChild(armorRes, "ArmorTitleBG"), ColorVectorToArray(Roguelike_GetRarityPickupColor(data.rarity)))
    Hud_SetColor(Hud_GetChild(armorRes, "SlotStripe"), ColorVectorToArray(colors[data.slot]))
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Mobility"), "Mobility", prev.mobility, data.mobility )
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Resilience"), "Resilience", prev.resilience, data.resilience )
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Recovery"), "Recovery", prev.recovery, data.recovery )
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Discipline"), "Discipline", prev.discipline, data.discipline )
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Strength"), "Strength", prev.strength, data.strength )
    Roguelike_SetStatBar( Hud_GetChild(armorRes, "Intelligence"), "Intelligence", prev.intelligence, data.intelligence )
    Roguelike_SetTotalBar( Hud_GetChild(armorRes, "Total"), "Total", prev.total, data.total )
}

void function UpdateArmor( array<string> args )
{
    string argStr = ""
    foreach (int index, string arg in args)
    {
        argStr += arg + " "
    }
    argStr = argStr.slice(0, argStr.len() - 1)
    ArmorData data = StringToArmorData( argStr )
    //print(argStr)
    entity player = GetLocalClientPlayer()
    Roguelike_GiveEntityArmor( player, StringToArmorData( argStr ) )

    RunUIScript( "UpdateArmor", argStr )

}
array<int> function ColorVectorToArray( vector v ) 
{
    return [ int( v.x * 255 ), int( v.y * 255 ), int( v.z * 255 ), 240 ]
}

function UpdateAmmoChargesBarSegments( var bar, int count )
{
	int width = Hud_GetHeight( bar )
    int gap = 1
    int segmentWidth = (width - ( (count - 1) * gap) ) / count
    //print(segmentWidth)
    bar.SetBarSegmentInfo( gap, segmentWidth )
}