untyped
global function ServerCallback_OnShopSpawned
global function ServerCallback_OpenShop

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
void function ServerCallback_OnShopSpawned( int shop )
{
    printt("FUCKING THE SHOP :DDDDD")
    thread SetModelScale(shop, 0.5)
    // For some reason - the entities actually spawn later than the remote func.
    // This is solved by fucking the shop - until it works, hence the name.
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