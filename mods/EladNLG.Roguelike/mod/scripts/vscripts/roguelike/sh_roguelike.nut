untyped
global function Roguelike_SetUpRemoteFuncs
global function Roguelike_GetProcCoefficent
global function GetLevelCountMultiplier
global const float TIME_PER_DIFFICULTY = 240

struct
{
    table<int, float> procCoefficent
} file

float function GetLevelCountMultiplier()
{
    switch (GetConVarInt("roguelike_difficulty"))
    {
        case 0:
            return 1.1
        case 1:
            return 1.15
        case 2: 
            return 1.2
        case 3:
            return 1.25
    }
    return 1.1
}

void function Roguelike_SetUpRemoteFuncs()
{
    AddCallback_OnRegisteringCustomNetworkVars( RegisterRemoteFunctions )
}
const int ROGUELIKE_DAMAGESOURCEID_START = 4903274

void function RegisterRemoteFunctions()
{
    Remote_RegisterFunction( "ServerCallback_OnShopSpawned") // tells the client the shop has spawned
    Remote_RegisterFunction( "ServerCallback_OpenShop" ) // opens the shop
    Remote_RegisterFunction( "ServerCallback_ObtainedItem" ) // tells the client they have obtained an item, with it's ID
    Remote_RegisterFunction( "ServerCallback_SetItemAmount" )
    Remote_RegisterFunction( "ServerCallback_SetXP" )
    Remote_RegisterFunction( "ServerCallback_FreezeTimer" )
    Remote_RegisterFunction( "ServerCallback_UnfreezeTimer" )
    Remote_RegisterFunction( "ServerCallback_HideTimer" )
    Remote_RegisterFunction( "ServerCallback_ShowTimer" )
    Remote_RegisterFunction( "ServerCallback_UnlockAchievement" )
    Remote_RegisterFunction( "ServerCallback_SetLoanAmount")
    if (!IsLobby())
    {
        RegisterNetworkedVariable( "roguelikeCash", SNDC_PLAYER_GLOBAL, SNVT_UNSIGNED_INT )
        RegisterNetworkedVariable( "roguelikeCashStacks", SNDC_PLAYER_GLOBAL, SNVT_UNSIGNED_INT )
        RegisterNetworkedVariable( "roguelikeCashStacksStacks", SNDC_PLAYER_GLOBAL, SNVT_UNSIGNED_INT )
        RegisterNetworkedVariable( "difficultyStartTime", SNDC_GLOBAL, SNVT_TIME )
        #if CLIENT
        RegisterNetworkedVariableChangeCallback_int( "roguelikeCash", CashAmountChanged )
        #endif
    }
    getconsttable()[ "eDamageSourceId" ][ "ukelele" ] <- 4903274 // random number to avoid conflict with other mods
    RegisterWeaponDamageSourceName( "ukelele", "Ukelele" )
    file.procCoefficent[4903274] <- 0.2
}

float function Roguelike_GetProcCoefficent( int damageSourceId )
{
    return file.procCoefficent[damageSourceId]
}