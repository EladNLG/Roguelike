global function ServerCallback_OpenShop

void function ServerCallback_OpenShop()
{
    if ( uiGlobal.activeMenu != null )
        return
    AdvanceMenu( GetMenu( "ShopTest" ) )
}