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
    AddClientCommandCallback( "buyammo", CC_BuyAmmo )
    AddClientCommandCallback( "buyitem", CC_BuyItem )
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

int function ScaleRewardWithDifficulty( int reward )
{
    float multiplier = 1.0
    if (GetMapName() == "sp_crashsite" && Flag( "neural_link_complete" ) && !Flag( "spawn_final_enemies" ))
        multiplier *= 0.15
    return int( reward * (1 + 0.15 * roguelikeDifficulty) * multiplier)
}

void function OnNPCKilled_AddMoney( entity npc, entity attacker, var damageInfo )
{
    if ( attacker.IsPlayer() ) 
    {
        switch (npc.GetClassName())
        {
            case "npc_drone":
            case "npc_soldier":
                AddMoney( attacker, ScaleRewardWithDifficulty(15) );
                AddXP( 30 )
                break
            //case "npc_marvin":
            case "npc_titan":
                AddMoney( attacker, ScaleRewardWithDifficulty(35) );
                AddXP( 100 )
                break
            case "npc_spectre":
                AddMoney( attacker, ScaleRewardWithDifficulty(20) );
                AddXP( 40 )
                break
            case "npc_super_spectre":
                AddMoney( attacker, ScaleRewardWithDifficulty(50) );
                AddXP( 100 )
                break
            case "npc_turret_mega":
            case "npc_turret_sentry":
            case "npc_stalker":
                AddMoney( attacker, ScaleRewardWithDifficulty(35) );
                AddXP( 70 )
                break
            case "npc_prowler":
                AddMoney( attacker, ScaleRewardWithDifficulty(25) );
                AddXP( ScaleRewardWithDifficulty(25) )
                break
            case "npc_frag_drone":
                AddMoney( attacker, ScaleRewardWithDifficulty(5) );
                AddXP( 10 )
                break
            case "npc_marvin":
                AddMoney( attacker, ScaleRewardWithDifficulty(5) );
                AddXP( 75 )
        }
    }
}

void function AddMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        int curMoney = GetMoney( player )
        curMoney += amount
        if (curMoney < 0)
            curMoney = 0
        int cashStacks = curMoney / 1024
        int cashStacksStacks = cashStacks / 1024
        cashStacks = cashStacks % 1024
        curMoney = curMoney % 1024
        player.SetPlayerNetInt( "roguelikeCashStacks", cashStacks )
        player.SetPlayerNetInt( "roguelikeCashStacksStacks", int(min(cashStacksStacks, 1023)) )
        player.SetPlayerNetInt( "roguelikeCash", curMoney );
    }
    if (GetMoney( player ) == 69420)
        Roguelike_UnlockAchievement( player, "holyfuckingshit" )
}

void function RemoveMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        int curMoney = GetMoney( player )
        curMoney -= amount
        if (curMoney < 0)
            curMoney = 0
        int cashStacks = curMoney / 1024
        int cashStacksStacks = cashStacks / 1024
        cashStacks = cashStacks % 1024
        curMoney = curMoney % 1024
        player.SetPlayerNetInt( "roguelikeCashStacks", cashStacks )
        player.SetPlayerNetInt( "roguelikeCashStacksStacks", cashStacksStacks )
        player.SetPlayerNetInt( "roguelikeCash", curMoney );
    }
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