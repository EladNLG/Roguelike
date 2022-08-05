untyped
global function ServerCallback_OnShopSpawned
global function ServerCallback_OpenShop

const RUI_TEXT_CENTER = $"ui/cockpit_console_text_center.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"
const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"

void function ServerCallback_OnShopSpawned( int shop )
{
    printt("FUCKING THE SHOP :DDDDD")
	AddServerToClientStringCommandCallback( "shopitems", SetShopItems)
	AddServerToClientStringCommandCallback( "itembought", SetShopItems)
    thread SetModelScale(shop, 0.5)

    if (GetMapName() == "sp_training") {
        var topo = CreateWorldTopo( < -6140, -11600, -229>, <0, 90, 0>, 200, 200.0 / 16.0 * 9)
        var rui = RuiCreate( RUI_TEXT_CENTER, topo, RUI_DRAW_WORLD, 0 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0.0> )
		RuiSetFloat3( rui, "msgColor", <1,1,1> )
		RuiSetString( rui, "msgText", "Press %speed% to dash." )
		RuiSetFloat( rui, "msgFontSize", 64.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", -0.25 )
        topo = CreateWorldTopo( < -5476, -6200, -60>, <0, 0, 0>, 200, 200.0 / 16.0 * 9)
        rui = RuiCreate( RUI_TEXT_CENTER, topo, RUI_DRAW_WORLD, 0 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0.0> )
		RuiSetFloat3( rui, "msgColor", <1,1,1> )
		RuiSetString( rui, "msgText", "Chests appear around the world.\nPress %use% when you have enough money to open them." )
		RuiSetFloat( rui, "msgFontSize", 64.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", -0.25 )
    }
    /*if (GetMapName() == "sp_sewers1") {
        var topo = CreateWorldTopo( < 11804 + 142, 4900, 600>, <0, 90, 0>, 292, 292.0 / 16.0 * 9)
        var rui = RuiCreate( RUI_TEXT_CENTER, topo, RUI_DRAW_WORLD, 01000 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0.0> )
		RuiSetFloat3( rui, "msgColor", <1,1,1> )
		RuiSetString( rui, "msgText", "EladNLG `1presents" )
		RuiSetFloat( rui, "msgFontSize", 128.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", 0.25 )
        rui = RuiCreate( RUI_TEXT_CENTER, topo, RUI_DRAW_WORLD, 1000 )
		RuiSetInt( rui, "maxLines", 2 )
		RuiSetInt( rui, "lineNum", 2 )
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0.0> )
		RuiSetFloat3( rui, "msgColor", <1,1,1> )
		RuiSetString( rui, "msgText", "`1something incredibly" )
		RuiSetFloat( rui, "msgFontSize", 128.0 )
		RuiSetFloat( rui, "msgAlpha", 1.5 )
		RuiSetFloat( rui, "thicken", 0.25 )
        rui = RuiCreate( RUI_TEXT_CENTER, topo, RUI_DRAW_WORLD, 0 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 1 )
		RuiSetFloat2( rui, "msgPos", <0.0, 0.0, 0.0> )
		RuiSetFloat3( rui, "msgColor", <0.8, 0.4, 0.1> )
		RuiSetString( rui, "msgText", "STUPID" )
		RuiSetFloat( rui, "msgFontSize", 512.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", 1.0 )
    }*/
    // For some reason - the entities actually spawn later than the remote func.
    // This is solved by fucking the shop - until it works, hence the name.
}

void function SetShopItems( array<string> args )
{
	string items = GetArgString(args)
	RunUIScript("Roguelike_SetShopItems", items)
}

void function ItemBought( array<string> args )
{
	int index = int( args[0] )
	RunUIScript("Roguelike_ItemBought", index)
}

string function GetArgString( array<string> args )
{
	string s = ""
	for (int i = 0; i < args.len(); i++) {
		s += args[i]
		if (i < args.len() - 1) s += " "
	}
	return s
}

void function SetModelScale(int shop, float scale)
{
    /*while (!IsValid(GetEntityFromEncodedEHandle(shop)))
        WaitFrame()
    var rui = RuiCreate( RUI_TEXT_RIGHT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.95, 0.325, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.1, 0.1> )
    RuiSetString( rui, "msgText", "MALTA LOCATION" )
    RuiSetFloat( rui, "msgFontSize", 45.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )*/

    //thread UpdateMaltaLocation(rui, shop)
}

void function UpdateMaltaLocation( var rui, int shop )
{
    while (true)
    {
        WaitFrame()
        if (!IsValid(GetEntityFromEncodedEHandle(shop)))
            continue
        entity ashop = GetEntityFromEncodedEHandle(shop)
        vector relOrigin = RotateVector( GetLocalClientPlayer().GetOrigin() - ashop.GetOrigin(), -1 * ashop.GetAngles() ) 
        RuiSetString(rui, "msgText", "<" + relOrigin.x + ", " + relOrigin.y + ", " + relOrigin.z + ">")
    }
}

// fucking util functions >:(
vector function RotateVector( vector vec, vector rotateAngles )
{
	return vec.x * AnglesToForward( rotateAngles ) + vec.y * -1.0 * AnglesToRight( rotateAngles ) + vec.z * AnglesToUp( rotateAngles )
}

void function ServerCallback_OpenShop()
{
    RunUIScript( "ServerCallback_OpenShop" )
}