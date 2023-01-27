untyped

globalize_all_functions

struct 
{
    array<string> items
    array<string> itemsInShop
} file

void function _Shop_Init()
{
    if (IsLobby()) return
    if (IsSingleplayer())
        SetConVarInt( "sv_quota_stringcmdspersecond", 1000 )
    else SetConVarInt( "sv_quota_stringcmdspersecond", 60 )
    AddClientCommandCallback( "buyammo", CC_BuyAmmo )
    AddClientCommandCallback( "buyitem", CC_BuyItem )
    if (GetDeveloperLevel() <= 0)
        AddClientCommandCallback( "SpawnViewGrunt", ClientCommand_SpawnViewGrunt )
    AddCallback_OnNPCKilled( OnNPCKilled_AddMoney )
    AddCallback_EntitiesDidLoad( AAAAAAAAEntitiesDidLoad )
    file.items = Roguelike_GetAllItemsOfRarity( RARITY_UMBRAL )
    file.itemsInShop = ["","","","",""]
    Roguelike_RollItemsInShop()
}

array<string> function Roguelike_GetItemsInShop()
{
    return file.itemsInShop
}

void function Roguelike_RollItemsInShop()
{
    for (int i = 0; i < 5; i++)
    {
        if (file.itemsInShop[i] != "-")
            file.itemsInShop[i] = file.items[xorshift_range_int(0, file.items.len())]
    }
}
void function AAAAAAAAEntitiesDidLoad()
{
    if (GetMapName() != "sp_s2s") return
	array<entity> pods = GetEntArrayByScriptName( "lifeboats_pods" )
    Highlight_SetNeutralHighlight( pods[0], "roguelike_chest" )
}

float function ScaleRewardWithDifficulty( int reward, float multiplier )
{
    return reward * (1 + multiplier * roguelikeDifficulty)
}

float function ScaleRewardWithDifficultyExponent( int reward, float ex )
{
    float multiplier = 1.0
    return reward * pow(ex, roguelikeDifficulty)
}

void function OnNPCKilled_AddMoney( entity npc, entity attacker, var damageInfo )
{
    if ( attacker.IsPlayer() ) 
    {
        switch (npc.GetClassName())
        {
            case "npc_drone":
            case "npc_soldier":
                if (attacker.IsTitan())
                    AddMoney( attacker, int( ScaleRewardWithDifficulty(3, 0.2) ) );
                else AddMoney( attacker, int( ScaleRewardWithDifficulty(10, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 30, XP_PER_LEVEL_MULTIPLIER ) )
                break
            //case "npc_marvin":
            case "npc_titan":
                AddMoney( attacker, int( ScaleRewardWithDifficulty(25, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 100, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_spectre":
                if (attacker.IsTitan())
                    AddMoney( attacker, int( ScaleRewardWithDifficulty(5, 0.2) ) );
                else AddMoney( attacker, int( ScaleRewardWithDifficulty(15, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 40, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_super_spectre":
                AddMoney( attacker, int( ScaleRewardWithDifficulty(20, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 100, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_turret_mega":
            case "npc_turret_sentry":
            case "npc_stalker":
                if (attacker.IsTitan())
                    AddMoney( attacker, int( ScaleRewardWithDifficulty(6, 0.2) ) );
                else AddMoney( attacker, int( ScaleRewardWithDifficulty(20, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 70, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_prowler":
                if (attacker.IsTitan())
                    AddMoney( attacker, int( ScaleRewardWithDifficulty(8, 0.2) ) );
                else AddMoney( attacker, int( ScaleRewardWithDifficulty(25, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 25, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_frag_drone":
                AddMoney( attacker, int( ScaleRewardWithDifficulty(5, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 10, XP_PER_LEVEL_MULTIPLIER ) )
                break
            case "npc_marvin":
                AddMoney( attacker, int( ScaleRewardWithDifficulty(5, 0.2) ) );
                AddXP( ScaleRewardWithDifficulty( 75, XP_PER_LEVEL_MULTIPLIER ) )
        }
    }
}

void function AddMoney( entity player, int amount )
{
    if ( !player.IsPlayer() )
        return

    int curMoney = GetMoney( player )
    player.s.money <- curMoney + amount

    Remote_CallFunction_NonReplay( player, "ServerCallback_SetCashAmount", player.s.money )
}

void function RemoveMoney( entity player, int amount )
{
    if ( !player.IsPlayer() )
        return
    
    int curMoney = GetMoney( player )
    player.s.money <- curMoney - amount

    Remote_CallFunction_NonReplay( player, "ServerCallback_SetCashAmount", player.s.money )
}

bool function CC_BuyAmmo( entity player, array<string> args)
{
    if( args.len() != 1 )
    {
        return true
    }
    switch (args[0])
    {
        case "0":
            entity weapon = player.GetMainWeapons()[0]
            if (weapon.GetLifetimeShotsRemaining() != -1)
            {
                weapon.SetLifetimeShotsRemaining(weapon.GetWeaponSettingInt(eWeaponVar.lifetime_shots_default))
            }
            else
            {
                weapon.SetWeaponPrimaryAmmoCount(weapon.GetWeaponSettingInt(eWeaponVar.ammo_stockpile_max))
            }
            break;
        case "1":
            entity weapon = player.GetMainWeapons()[1]
            if (weapon.GetLifetimeShotsRemaining() != -1)
            {
                weapon.SetLifetimeShotsRemaining(weapon.GetWeaponSettingInt(eWeaponVar.lifetime_shots_default))
            }
            else
            {
                weapon.SetWeaponPrimaryAmmoCount(weapon.GetWeaponSettingInt(eWeaponVar.ammo_stockpile_max))
            }
            break;
    }
    return true
}

bool function CC_BuyItem( entity player, array<string> args )
{
    if( args.len() != 1 )
    {
        return true
    }
    int index = int( args[0] )

    if (index < file.itemsInShop.len() && file.itemsInShop[index] != "-")
    {
        CreateItem(file.itemsInShop[index], GetShopSpawnLocation() + <0,0,50>, <0,0,0> )
        file.itemsInShop[index] = "-"
        foreach (entity p in GetPlayerArray())
            ServerToClientStringCommand( p, "itembought " + index )
    }
    return true
}