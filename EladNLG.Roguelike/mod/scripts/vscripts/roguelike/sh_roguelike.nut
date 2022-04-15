global function Roguelike_SetUpRemoteFuncs

void function Roguelike_SetUpRemoteFuncs()
{
    AddCallback_OnRegisteringCustomNetworkVars( RegisterRemoteFunctions )
}

void function RegisterRemoteFunctions()
{
    Remote_RegisterFunction( "ServerCallback_OnShopSpawned") // tells the client the shop has spawned
    Remote_RegisterFunction( "ServerCallback_OpenShop" ) // opens the shop
    Remote_RegisterFunction( "ServerCallback_ObtainedItem" ) // tells the client they have obtained an item, with it's ID
    Remote_RegisterFunction( "ServerCallback_SetItemAmount" )
    RegisterNetworkedVariable( "roguelikeCash", SNDC_PLAYER_EXCLUSIVE, SNVT_UNSIGNED_INT )
    #if CLIENT
    RegisterNetworkedVariableChangeCallback_int( "roguelikeCash", CashAmountChanged )
    #endif
}