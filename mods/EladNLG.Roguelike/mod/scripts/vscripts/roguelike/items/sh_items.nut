global typedef INT int
global typedef FLOAT float

////////////////////////
// SH_ITEM.NUT        //
// defines all items. //
////////////////////////
global function ShItems_Init
global function StringToCharArray
global function Roguelike_AddItemStat
global function Roguelike_DoesItemHaveModel
global function Roguelike_EntityHasItem
global function Roguelike_ExponentialChanceFunc
global function Roguelike_GetAllItems
global function Roguelike_GetAllItemsOfRarity
global function Roguelike_GetEntityArmor
global function Roguelike_GetEntityStat
global function Roguelike_GetItemCount
global function Roguelike_GetItemDesc
global function Roguelike_GetItemDrawbackDesc
global function Roguelike_GetItemFromNumericId
global function Roguelike_GetItemModel
global function Roguelike_GetItemName
global function Roguelike_GetItemNumericId
global function Roguelike_GetItemRarity
global function Roguelike_GetItemStatCount
global function Roguelike_GetItemStatFormat
global function Roguelike_GetItemStatFunc
global function Roguelike_GetItemStatObsoleteFunc
global function Roguelike_GetItemStatName
global function Roguelike_GetIsItemStatDrawback
global function Roguelike_GetPlayerItems
global function Roguelike_GetRandomItem
global function Roguelike_GetRandomItemWithCustomWeights
global function Roguelike_GiveEntityArmor
global function Roguelike_GiveEntityItem
global function Roguelike_HyperbolicChanceFunc
global function Roguelike_LinearChanceFunc
global function Roguelike_Obsolete_And
global function Roguelike_Obsolete_IsGuranteed
global function Roguelike_Obsolete_Or
global function Roguelike_Obsolete_OutOfRange
global function Roguelike_Obsolete_WillNeverHappen
global function Roguelike_Obsolete_WithinRange
global function Roguelike_PrintPlayerInventory
global function Roguelike_RegisterItem
global function Roguelike_ReverseHyperbolicChanceFunc
global function Roguelike_SetItemDrawbacks
global function Roguelike_RegisterRarity
global function Roguelike_GetRarityColor
global function Roguelike_GetRarityChatColor
global function Roguelike_GetRarityPickupColor
global function Roguelike_GetAllRarities
#if !UI
global function Roguelike_RollForChanceFunc
global function Roguelike_RollStackingForChanceFunc
#endif
global function AddCallback_OnRoguelikeInventoryChanged
global function AddCallback_OnRoguelikeItemGained
global function GetRandomIndexFromWeightedArray

global const RARITY_COMMON = "common"
global const RARITY_UNCOMMON = "uncommon"
global const RARITY_RARE = "rare"
global const RARITY_LEGENDARY = "legendary"
global const RARITY_LEGENDARYARMOR = "legendarya"
global const RARITY_UMBRAL = "umbral"
global const RARITY_TITAN = "titan"
global const RARITY_EXOTIC = "exotic"
global const RARITY_CONTEXTUAL_ITEM = "contextual"

struct ItemStat
{
    string name
    float functionref( int ) chanceFunc
    string format
    bool isDrawback = false
    bool functionref( int ) obsoleteFunc = null
}

struct Rarity 
{
    string id
    vector color
    vector chatColor
    vector pickupColor
}

struct RoguelikeItem
{
    string id
    int numericId
    string name
    string description
    string drawbackDescription = ""
    string rarity
    asset model = $""
    float weight = 1.0
    table<int, string> chanceFormats
    array<ItemStat> stats
}

struct RoguelikeInventory
{
    table<string, int> items
    array<ArmorData> armor
}

struct
{
    table<string, RoguelikeItem> items
    table<string, float> rarityWeights = {
        common = 40.0, 
        uncommon = 5.0, 
        legendary = 1.0, 
        titan = 4.0
    }
    table<entity, RoguelikeInventory> inventories
    array<void functionref(entity)> inventoryCallbacks
    array<void functionref(entity, string, int, int)> itemGainedCallbacks
    table<string, Rarity> rarities
} file

void function ShItems_Init()
{
    float max = 0
    foreach (weight in file.rarityWeights)
    {
        max += weight
    }
    #if !UI
    foreach (index, weight in file.rarityWeights)
    {
        printt("DROP CHANCE FOR RARITY", index, "-", weight / max * 100.0, "%")
    }
    #endif
    
    Roguelike_RegisterRarity( RARITY_COMMON, <0.7, 0.7, 0.7>, <0.8, 0.8, 0.8>, <0.4, 0.4, 0.4> )
    Roguelike_RegisterRarity( RARITY_UNCOMMON, <0.1, 0.9, 0.1>, <0.3, 0.9, 0.3>, <0.2, 0.6, 0.2> )
    Roguelike_RegisterRarity( RARITY_RARE, <0.3, 0.5, 0.9>, <0.3, 0.5, 0.9>, <0.2, 0.3, 0.6> )
    Roguelike_RegisterRarity( RARITY_LEGENDARY, <0.9, 0.1, 0.1>, <0.9, 0.3, 0.3>, <0.6, 0.2, 0.2> )
    Roguelike_RegisterRarity( RARITY_LEGENDARYARMOR, <0.6, 0.3, 0.9>, <0.6, 0.3, 0.9>, <0.4, 0.2, 0.6> )
    Roguelike_RegisterRarity( RARITY_UMBRAL, <0.1, 0.1, 0.9>, <0.3, 0.3, 0.9>, <0.2, 0.2, 0.6> )
    Roguelike_RegisterRarity( RARITY_TITAN, <0.8, 0.4, 0.1>, <0.8, 0.4, 0.1>, <0.5, 0.3, 0.05> )
    Roguelike_RegisterRarity( RARITY_EXOTIC, <0.8, 0.8, 0.1>, <0.8, 0.8, 0.1>, <0.6, 0.6, 0.1> )
    Roguelike_RegisterRarity( RARITY_CONTEXTUAL_ITEM, <0.2, 0.2, 0.2>, <0.2, 0.2, 0.2>, <0.1, 0.1, 0.1> )


    // Ammo Pack
    Roguelike_RegisterItem( "ammo_pack", "Ammo Pack", "Upon kill:\n15% (+15% per stack) chance to restore 10% of the magazine", RARITY_COMMON )
    float functionref( int ) func1 = Roguelike_LinearChanceFunc( 20, 20, 100 )
    float functionref( int ) func2 = Roguelike_LinearChanceFunc( 20, 20, 100, -100 )

    float functionref( int ) func3 = Roguelike_LinearChanceFunc( 20, 20, 100, -200 )
    int index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore 20% Ammo", func1, "%.0f%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index, Roguelike_Obsolete_IsGuranteed( func2 ) )

    index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore 40% Ammo", func2, "%.0f%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index, Roguelike_Obsolete_Or( Roguelike_Obsolete_IsGuranteed( func3 ), Roguelike_Obsolete_WithinRange( func1, -1, 100 ) ) )

    index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore a 60% Ammo", func3, "%.0f%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index,  Roguelike_Obsolete_WithinRange( func2, -1, 100 ) )

    // Health Generator

    Roguelike_RegisterItem( "heal_mod", "Health Generator", "+25% (+50% per stack) Regen Rate", RARITY_COMMON )

    func1 = Roguelike_LinearChanceFunc( 25, 25 )
    Roguelike_AddItemStat( "heal_mod", "Regen Rate", func1, "%+.0f%%" )

    Roguelike_RegisterItem( "golden_shell", "Golden Shell", "Last bullet deals 15% (+15% per stack) more damage", RARITY_COMMON )

    func1 = Roguelike_LinearChanceFunc( 15, 15 )
    Roguelike_AddItemStat( "golden_shell", "Bonus Damage", func1, "%+.0f%%" )

    Roguelike_RegisterItem( "emergency_soda", "Emergency Soda", "^FFFFFF00Upon taking ^FF555500lethal^FFFFFF00 damage:\n^55FF5500Heal^0 to full health. ^FF555500Consume^0 1 stack of this item. This will NOT work on OoB zones.", RARITY_LEGENDARY )
    #if !UI
    Roguelike_SetItemAchievement( "emergency_soda", "dead" )
    #endif
    //

    // Blood Scavenger
    Roguelike_RegisterItem( "blood_scavenger", "Blood Scavenger", "Upon taking damage:\nAdd cash equivalent to 25% (+25% per stack) of the damage taken.", RARITY_UNCOMMON )

    // adrenaline shot
    func1 = Roguelike_LinearChanceFunc( 0.5, 0.25 )
    Roguelike_RegisterItem( "adrenaline_shot", "Adrenaline Shot", "Upon kill:\nGain a 70% speed boost for 0.5s (+0.25s per stack).\nAdditional kills refresh the duration.", RARITY_UNCOMMON )
    index = Roguelike_AddItemStat( "adrenaline_shot", "Boost Duration", func1, "%.2fs" )

    // send-back rounds
    func1 = Roguelike_LinearChanceFunc( 15, 15 )
    Roguelike_RegisterItem( "send_back_rounds", "Send-Back Rounds", "Upon hitting an headshot:\n15% (+15% per stack) chance to restore a bullet.", RARITY_UNCOMMON )
    index = Roguelike_AddItemStat( "send_back_rounds", "Chance", func1, "%.0f%%" )

    func1 = Roguelike_HyperbolicChanceFunc( 8 )
    float reduction = func1(1)
    float reduction2nd = func1(2) - reduction
    string res = format("%.1f%% (-%.1f%% per stack, hyperbolic)", reduction, reduction2nd)
    Roguelike_RegisterItem( "blast_proc", "Blast Protection IV", "-" + res + " explosive damage.", RARITY_UNCOMMON )
    index = Roguelike_AddItemStat( "blast_proc", "Damage Reduction", func1, "%.0f%%" )


    // Leeching Hands
    // +20Hp/s when wallrunning
    func1 = Roguelike_LinearChanceFunc( 20, 20 )
    Roguelike_RegisterItem( "leeching_hands", "Leeching Hands", "Heal for 20HP/s (+20HP/s per stack) while wallrunning.", RARITY_LEGENDARY )
    index = Roguelike_AddItemStat( "leeching_hands", "Regen Rate", func1, "%.0fHP/s" )

    // FRAGILE BIRD
    // +15% airAcceleration, -50 hp/s when wallrunning
    func1 = Roguelike_LinearChanceFunc( 20, 20 )
    func2 = Roguelike_LinearChanceFunc( 30, 30, 0, 0, true )
    Roguelike_RegisterItem( "fragile_bird", "Fragile Bird", "The air guides you. ^FF555500BUT the walls consume you.", RARITY_UMBRAL )
    //index = Roguelike_AddItemStat( "fragile_bird", "Air Acceleration", func1, "%+.0f%%" )
    //index = Roguelike_AddItemStat( "fragile_bird", "Health Loss while Wallrunning", func2, "%.0f%%HP/s", true )

    float amplifier = 25
    string chance = format("%.1f", Roguelike_HyperbolicChanceFunc( amplifier )(1) )

    Roguelike_RegisterItem( "overclock_mechanism", "Overclock Mechanism", "Upon killing a titan as BT:\n" + chance
         + "% (" + chance + "% per stack, hyperbolic) chance to overclock,\nresetting all cooldowns and refresh weapon ammo.", RARITY_TITAN )

    //Roguelike_AddItemStat( "overclock_mechanism", "Overclock Chance", Roguelike_HyperbolicChanceFunc( amplifier ))

    Roguelike_RegisterItem( "infinite_charge", "Railgun Heat Shield", "As Northstar: You're able to charge the railgun INFINITELY.\nCharging it too much will reset the charge. Slightly reduce bonus damage per level.", RARITY_TITAN )

    Roguelike_AddItemStat( "infinite_charge", "Damage Per Level Percentage", Roguelike_ReverseHyperbolicChanceFunc( 3 ), "%.0f%%" )
    Roguelike_AddItemStat( "infinite_charge", "Max Charge Level", Roguelike_LinearChanceFunc( 6, 1 ), "%.0f" )

    Roguelike_RegisterItem( "sticky_thermite", "Heat Combiner", "As Scorch:\nEach thermite instance deals 20% (+20% per stack) more damage than the last.", RARITY_TITAN )

    Roguelike_AddItemStat( "sticky_thermite", "Damage Bonus", Roguelike_LinearChanceFunc( 20, 20 ), "%.0f%%" )

    Roguelike_RegisterItem( "jumpkit_parts", "Elad's Jumpkit Parts", "+10% (+10% per stack) Movement Speed.", RARITY_COMMON)
    Roguelike_AddItemStat( "jumpkit_parts", "Movement Speed", Roguelike_LinearChanceFunc( 10, 10 ), "%+.0f%%" )
    #if !UI
    Roguelike_SetItemAchievement( "jumpkit_parts", "gauntlet_leaderboard" )
    #endif

    Roguelike_RegisterItem( "cockroach", "Acidic Cockroach", "+20% (+20% per stack) damage to titans, as a pilot.", RARITY_COMMON )
    Roguelike_AddItemStat( "cockroach", "Damage Bonus", Roguelike_LinearChanceFunc( 20, 20 ), "%+.0f%%" )

    Roguelike_RegisterItem( "unionizer", "Gun Unionizer", "+20% (+20% per stack) damage to bosses.", RARITY_UNCOMMON )
    Roguelike_AddItemStat( "unionizer", "Damage Bonus", Roguelike_LinearChanceFunc( 20, 20 ), "%+.0f%%" )

    Roguelike_RegisterItem( "ukulele", "Ukulele", "On Hit:\n25% chance for a hit to cause area of effect damage.", RARITY_UNCOMMON)
    Roguelike_AddItemStat( "ukulele", "Radius Multiplier", Roguelike_LinearChanceFunc( 100, 10 ), "%.0f%%" )

    // doesn't work for now
    //Roguelike_RegisterItem( "last_stand", "The Last Stand", "Their death comes quick...", RARITY_UMBRAL )
    //Roguelike_SetItemDrawbacks( "last_stand", "\nBUT it is delayed.")

    Roguelike_RegisterItem( "heal_on_kill", "Heart Pumper", "On Kill:\nHeal for 20HP.", RARITY_COMMON)
    func1 = Roguelike_LinearChanceFunc( 20, 20 )
    Roguelike_AddItemStat( "heal_on_kill", "Heal Amount", func1, "%.0f")

    Roguelike_RegisterItem( "loan", "Business Card", "Take a loan...", RARITY_UMBRAL)
    Roguelike_SetItemDrawbacks( "loan", "\n\nVERY HIGH INTEREST.\nNOTE: Your blood CAN AND WILL be sold to pay the loan, if needed." )
    #if !UI
    Roguelike_SetItemAchievement( "loan", "pickup_legendary" )
    #endif
    Roguelike_RegisterItem("fatigue", "Fatigue", "", RARITY_CONTEXTUAL_ITEM)
    Roguelike_SetItemDrawbacks("fatigue", "-20% Health & Movement Speed per stack.")

    Roguelike_RegisterItem( "max_hp", "Meat Armor", "+5% maximum health.", RARITY_COMMON )
    func1 = Roguelike_LinearChanceFunc( 10, 10 )
    Roguelike_AddItemStat( "max_hp", "Health Bonus", func1, "%.0f%%")

    Roguelike_RegisterItem( "shield", "Shield Generator", "Gain shield equivalent to 10% of your max health.", RARITY_TITAN )
    func1 = Roguelike_LinearChanceFunc( 10, 10 )
    Roguelike_AddItemStat( "shield", "Shield Bonus", func1, "%.0f%%")


    //Roguelike_RegisterItem( "self_dmg", "Ibuprofen", "Kills the pain at the beginning.", RARITY_UMBRAL )
    //Roguelike_SetItemDrawbacks( "self_dmg", "BUT it comes back worse.")
    //Roguelike_SetChanceFunctions( "overclock_mechanism", [ Roguelike_HyperbolicChanceFunc( amplifier, 0 ), Roguelike_HyperbolicChanceFunc( amplifier, 1 ) ] )
}

void function AddCallback_OnRoguelikeInventoryChanged( void functionref( entity ) callback )
{
    file.inventoryCallbacks.append( callback )
}
void function AddCallback_OnRoguelikeItemGained( void functionref( entity, string, int, int ) callback )
{
    file.itemGainedCallbacks.append( callback )
}

void function Roguelike_RegisterItem( string id, string name, string description, string rarity, float weight = 1.0, asset model = $"" )
{
    if (id in file.items)
        throw "This item already exists."
    RoguelikeItem item
    item.id = id
    item.name = name
    item.description = description
    item.model = model
    item.rarity = rarity
    item.numericId = file.items.len()
    file.items[id] <- item
}

string function Roguelike_GetItemName( string item )
{
    if ( !( item in file.items ))
        throw "Name was requested for unknown item \"" + item + "\""
    return file.items[item].name
}

void function Roguelike_SetItemDrawbacks( string item, string desc )
{
    if ( !( item in file.items ))
        throw "Drawbacks were requested to be set for unknown item \"" + item + "\""
    file.items[item].drawbackDescription = desc
}

string function Roguelike_GetItemDrawbackDesc( string item )
{
    if ( !( item in file.items ))
        throw "Drawback description was requested for unknown item \"" + item + "\""
    return file.items[item].drawbackDescription
}

string function Roguelike_GetItemRarity( string item )
{
    if ( !( item in file.items ))
        throw "Name was requested for unknown item \"" + item + "\""
    return file.items[item].rarity
}

string function Roguelike_GetItemDesc( string item )
{
    if ( !( item in file.items ))
        throw "Description was requested for unknown item \"" + item + "\""
    return file.items[item].description
}

bool function Roguelike_DoesItemHaveModel( string item )
{
    if ( !( item in file.items ))
        throw "Model check was requested for unknown item \"" + item + "\""
    return file.items[item].model != $""
}

string function Roguelike_GetRandomItemWithCustomWeights( table<string, float> weights )
{
    string rarity = GetRandomKeyFromWeightedTypedTable( weights )
    //print(rarity)
    return Roguelike_GetRandomItem( rarity )
}

string function Roguelike_GetRandomItem( string rarity = "" )
{
    if (rarity == "")
    {
        table<string, float> weights = file.rarityWeights

        rarity = GetRandomKeyFromWeightedTypedTable( weights )
    }
    array<RoguelikeItem> items
    foreach ( item in file.items )
    {
        #if !UI
        if ( item.rarity == rarity && !Roguelike_IsItemLocked(item.id) )
        #else
        if (item.rarity == rarity)
        #endif
            items.append(item)
    }
    if ( items.len() == 0 )
        throw "No items exist for rarity " + rarity
    return items[xorshift_range_int( 0, items.len(), GetRoguelikeSeed() + 3 )].id
}

string function GetRandomKeyFromWeightedTypedTable( table<string, float> weights )
{
    float total = 0.0
    foreach ( string key, float weight in weights )
        total += weight

    float random = xorshift_range( 0, total )
    float current = 0.0

    foreach ( key, item in weights )
    {
        current += item
        if ( current > random )
            return key
    }

    unreachable
}

int function GetRandomIndexFromWeightedArray( array<float> weights )
{
    float total = 0.0
    foreach ( float weight in weights )
        total += weight

    float random = xorshift_range( 0, total )
    float current = 0.0

    foreach ( index, item in weights )
    {
        current += item
        if ( current > random )
            return index
    }

    return -1
}

int function GetRandomIndexFromWeightedItemArray( array<RoguelikeItem> weights )
{
    float total = 0.0
    foreach ( RoguelikeItem weight in weights )
        total += weight.weight

    float random = xorshift_range( 0, total )
    float current = 0.0

    foreach ( index, item in weights )
    {
        current += item.weight
        if ( current > random )
            return index
    }

    return -1
}

asset function Roguelike_GetItemModel( string item )
{
    if ( !( item in file.items ))
        throw "Model check was requested for unknown item \"" + item + "\""

    return file.items[item].model
}

int function Roguelike_GetItemNumericId( string item )
{
    if ( !( item in file.items ))
        throw "Numeric ID was requested for unknown item \"" + item + "\""
    return file.items[item].numericId
}

bool function Roguelike_EntityHasItem( entity player, string item )
{
    if ( !(player in file.inventories) )
        return false
    return item in file.inventories[player].items
}

int function Roguelike_GetItemCount( entity player, string item )
{
    if ( !(player in file.inventories) )
        return 0 // player hasn't grabbed any item yet
    if ( !( item in file.inventories[player].items ) )
        return 0 // player doesn't have this item
    return file.inventories[player].items[item]
}

void function Roguelike_PrintPlayerInventory( entity player )
{
    if ( !(player in file.inventories) )
        return // player hasn't grabbed any item yet

    //print( "Player " + player.GetPlayerName() + " has the following items:" )
    //foreach ( item, count in file.inventories[player].items )
    //{
    //    print( item + ": " + count )
    //}
}

// NUMERIC IDS
// Used to call item obtain events on the client and

void function Roguelike_GiveEntityItem( entity player, string item, int count = 1 )
{
    if ( !(player in file.inventories) )
    {
        RoguelikeInventory inventory
        file.inventories[player] <- inventory
        for (int i = 0; i < 5; i++)
        {
            ArmorData data
            data.slot = i
            file.inventories[player].armor.append(data)
        }
    }
    if ( !(item in file.inventories[player].items) )
    {
        file.inventories[player].items[item] <- count
    }
    else file.inventories[player].items[item] += count

    if (file.inventories[player].items[item] == 0)
    {
        delete file.inventories[player].items[item]
        
        foreach ( callback in file.itemGainedCallbacks )
            callback( player, item, -count, 0 )
    }
    else foreach ( callback in file.itemGainedCallbacks )
        callback( player, item, file.inventories[player].items[item] - count, file.inventories[player].items[item] )

    foreach (callback in file.inventoryCallbacks)
        callback( player )
    #if !UI
    if (player.IsPlayer())
    #endif
        SetConVarString( "player_items", GetItemConVarValue( player ) )
}

string function GetItemConVarValue( entity player )
{
    string result = ""
    int len = Roguelike_GetPlayerItems(player).len()
    foreach ( index, item in Roguelike_GetPlayerItems(player))
    {
        int itemId = Roguelike_GetItemNumericId( item )
        int amount = Roguelike_GetItemCount( player, item )
        result += itemId + " " + amount
        if (index < len - 1) result += " "
    }
    return result
}

string function Roguelike_GetItemFromNumericId( int id )
{
    foreach ( item in file.items )
    {
        if ( item.numericId == id )
            return item.id
    }
    throw "No item exists with numeric ID " + id
    unreachable
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// CHANCE FUNCS                                                                                                                  //
// These are used to generate chance values for items.                                                                           //
// To get a chance for X stacks of an item with 10% chance and stacking is linear, do Roguelike_LinearChanceFunc( 0.1, 0.1 )(X). //
// Use offset to show the chance for the pickup the player is looking at.                                                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int function Roguelike_GetItemStatCount( string itemName )
{
    if ( !( itemName in file.items ))
        throw "Stat count was requested for unknown item \"" + itemName + "\""
    return file.items[itemName].stats.len()
}

string function Roguelike_GetItemStatName( string itemName, int index )
{
    if ( !( itemName in file.items ))
        throw "Stat name was requested for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat name was requested for item \"" + itemName + "\" with invalid index " + index
    return file.items[itemName].stats[index].name
}

float functionref( int ) function Roguelike_GetItemStatFunc( string itemName, int index )
{
    if ( !( itemName in file.items ))
        throw "Stat function was requested for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat function was requested for item \"" + itemName + "\" with invalid index " + index
    return file.items[itemName].stats[index].chanceFunc
}

bool function Roguelike_GetIsItemStatDrawback( string itemName, int index )
{
    if ( !( itemName in file.items ))
        throw "Stat is drawback was requested for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat is drawback was requested for item \"" + itemName + "\" with invalid index " + index
    return file.items[itemName].stats[index].isDrawback
}

string function Roguelike_GetItemStatFormat( string itemName, int index )
{
    if ( !( itemName in file.items ))
        throw "Stat format was requested for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat format was requested for item \"" + itemName + "\" with invalid index " + index
    return file.items[itemName].stats[index].format
}

int function Roguelike_AddItemStat( string itemName, string statName, float functionref( int ) chanceFunc, string statFormat = "%.0f%%", bool isDrawback = false )
{
    if ( !( itemName in file.items ))
        throw "Stat was requested to be set for unknown item \"" + itemName + "\""
    ItemStat stat
    stat.name = statName
    stat.chanceFunc = chanceFunc
    stat.format = statFormat
    stat.isDrawback = isDrawback

    file.items[itemName].stats.append( stat )
    return file.items[itemName].stats.len() - 1
}

void function Roguelike_SetStatObsoleteFunc( string itemName, int index, bool functionref( int ) obsoleteFunc )
{
    if ( !( itemName in file.items ))
        throw "Stat obsolete function was requested to be set for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat obsolete function was requested to be set for item \"" + itemName + "\" with invalid index " + index
    file.items[itemName].stats[index].obsoleteFunc = obsoleteFunc
}

float functionref ( int ) function Roguelike_LinearChanceFunc( float baseChance, float chancePerStack, float maxChance = 0, float offset = 0, bool allowNegative = false )
{
    return float function( int stacks ) : (baseChance, chancePerStack, maxChance, offset, allowNegative)
    {
        if (stacks <= 0) return 0.0
        float chance = baseChance + chancePerStack * (stacks - 1) + offset
        if (maxChance > 0) chance = min( chance, maxChance )
        if (!allowNegative) chance = max(chance, 0)
        return chance
    }
}

float functionref ( int ) function Roguelike_ExponentialChanceFunc( float baseChance, float chancePerStack, float maxChance = 0, float offset = 0, bool allowNegative = false )
{
    return float function( int stacks ) : (baseChance, chancePerStack, maxChance, offset, allowNegative)
    {
        if (stacks <= 0) return 0.0
        float chance = baseChance * pow( chancePerStack, stacks - 1 )
        if (maxChance > 0) chance = min( chance, maxChance )
        if (!allowNegative) chance = max(chance, 0)
        return chance
    }
}

float functionref( int ) function Roguelike_HyperbolicChanceFunc( float baseChance, float maxChance = 0, float offset = 0, bool allowNegative = false )
{
    return float function( int stacks ) : (baseChance, maxChance, offset, allowNegative)
    {
        if (stacks <= 0) return 0.0
        // 100 - (100 / 150) =
        float chance = 100.0 - (100.0 / (100.0 + (baseChance * stacks)) * 100)
        if (maxChance > 0) chance = min( chance, maxChance )
        if (!allowNegative) chance = max(chance, 0)
        return chance
    }
}

float functionref( int ) function Roguelike_ReverseHyperbolicChanceFunc( float baseChance, float maxChance = 0, float offset = 0, bool allowNegative = false )
{
    return float function( int stacks ) : (baseChance, maxChance, offset, allowNegative)
    {
        if (stacks <= 0) return 100.0
        // 100 - (100 / 150) =
        float chance = (100.0 / (100.0 + (baseChance * stacks)) * 100)
        if (maxChance > 0) chance = min( chance, maxChance )
        if (!allowNegative) chance = max(chance, 0)
        return chance
    }
}

#if !UI
bool function Roguelike_RollForChanceFunc( float functionref( int ) chanceFunc, int stacks, int damageSourceId = eDamageSourceId.invalid )
{
    float chance = chanceFunc( stacks )
    return RandomFloat( 100 ) < chance
}

// Rolls for a chance function.
// If the chance is more than 100%, return the amount of guranteed rolls + a roll of the remaining chance
// So - if the chance is 280%, it will return 2 20% of the time, and 80% of the time it will return 3.
int function Roguelike_RollStackingForChanceFunc( float functionref( int ) chanceFunc, int stacks )
{
    float chance = chanceFunc( stacks )
    int stackedRolls = int( chance ) / 100
    return stackedRolls + (RandomFloat( 100 ) < chance % 100 ? 1 : 0)
}
#endif

bool functionref( int ) function Roguelike_GetItemStatObsoleteFunc( string itemName, int index )
{
    if ( !( itemName in file.items ))
        throw "Stat obsolete function was requested for unknown item \"" + itemName + "\""
    if ( index < 0 || index >= file.items[itemName].stats.len() )
        throw "Stat obsolete function was requested for item \"" + itemName + "\" with invalid index " + index
    return file.items[itemName].stats[index].obsoleteFunc
}

bool functionref( int ) function Roguelike_Obsolete_OutOfRange( float functionref( int ) func, float min, float max )
{
    return bool function( int stacks ) : (func, min, max)
    {
        return func( stacks ) < min || func( stacks ) > max
    }
}

bool functionref( int ) function Roguelike_Obsolete_WithinRange( float functionref( int ) func, float min, float max )
{
    return bool function( int stacks ) : (func, min, max)
    {
        return func( stacks ) > min && func( stacks ) < max
    }
}

bool functionref( int ) function Roguelike_Obsolete_IsGuranteed( float functionref( int ) func )
{
    return bool function( int stacks ) : (func)
    {
        return func( stacks ) >= 100
    }
}

bool functionref( int ) function Roguelike_Obsolete_WillNeverHappen( float functionref( int ) func )
{
    return bool function( int stacks ) : (func)
    {
        return func( stacks ) <= 0
    }
}

bool functionref( int ) function Roguelike_Obsolete_And( bool functionref( int ) func1, bool functionref( int ) func2 )
{
    return bool function( int stacks ) : (func1, func2)
    {
        return func1( stacks ) && func2( stacks )
    }
}

bool functionref( int ) function Roguelike_Obsolete_Or( bool functionref( int ) func1, bool functionref( int ) func2 )
{
    return bool function( int stacks ) : (func1, func2)
    {
        return func1( stacks ) || func2( stacks )
    }
}

array<string> function Roguelike_GetPlayerItems( entity player )
{
    array<string> result = []
    if ( !( player in file.inventories ) )
        return []

    foreach ( key, value in file.inventories[player].items )
        result.append( key )

    return result
}

array<string> function Roguelike_GetAllItems()
{
    array<string> result = []
    foreach ( key, value in file.items )
        result.append( key )

    return result
}


array<string> function Roguelike_GetAllItemsOfRarity( string rarity )
{
    array<string> result = []
    foreach ( key, value in file.items )
        if (value.rarity == rarity) result.append( key )

    return result
}

array<int> function StringToCharArray( string str )
{
    array<int> result = []
    for ( int i = 0; i < str.len(); i++ )
        result.append( expect int( str[i] ) )
    return result
}

void function Roguelike_RegisterRarity( string id, vector color, vector chatColor, vector pickupColor )
{
    Rarity rarity

    rarity.id = id
    rarity.color = color
    rarity.chatColor = chatColor
    rarity.pickupColor = pickupColor

    file.rarities[id] <- rarity
}

vector function Roguelike_GetRarityColor( string id )
{
    if (!(id in file.rarities))
        throw "Requested color for unknown rarity '" + id + "'"

    return file.rarities[id].color
}

vector function Roguelike_GetRarityChatColor( string id )
{
    if (!(id in file.rarities))
        throw "Requested color for unknown rarity '" + id + "'"

    return file.rarities[id].chatColor
}

vector function Roguelike_GetRarityPickupColor( string id )
{
    if (!(id in file.rarities))
        throw "Requested color for unknown rarity '" + id + "'"

    return file.rarities[id].pickupColor
}

array<string> function Roguelike_GetAllRarities()
{
    array<string> result
    foreach ( string key, Rarity val in file.rarities)
        result.append(key)

    return result
}

ArmorData function Roguelike_GiveEntityArmor( entity player, ArmorData data )
{
    if ( !(player in file.inventories) )
    {
        RoguelikeInventory inventory
        file.inventories[player] <- inventory
        for (int i = 0; i < 5; i++)
        {
            ArmorData data
            data.slot = i
            file.inventories[player].armor.append(data)
        }
    }

    ArmorData prev = file.inventories[player].armor[data.slot]
    file.inventories[player].armor[data.slot] = data
    
    foreach (callback in file.inventoryCallbacks)
        callback( player )

    #if SERVER
    if (player.IsPlayer())
        ServerToClientStringCommand( player, "UpdateArmor " + ArmorDataToString(data) )
    #elseif CLIENT
    if (player == GetLocalClientPlayer())
        SetConVarString( "player_armor", ArmorDataToString(Roguelike_GetEntityArmor(player, 0)) + "{"
        + ArmorDataToString(Roguelike_GetEntityArmor(player, 1)) + "{"
        + ArmorDataToString(Roguelike_GetEntityArmor(player, 2)) + "{"
        + ArmorDataToString(Roguelike_GetEntityArmor(player, 3)) + "{"
        + ArmorDataToString(Roguelike_GetEntityArmor(player, 4)) )
    #endif

    return prev
}

int function Roguelike_GetEntityStat( entity player, string stat )
{
    if ( !(player in file.inventories) )
        return 0
    
    int result = 0
    foreach (ArmorData armor in file.inventories[player].armor)
        result += GetArmorStat( armor, stat )
    
    return result
}

ArmorData function Roguelike_GetEntityArmor( entity player, int slot )
{
    if ( !(player in file.inventories) )
    {
        RoguelikeInventory inventory
        file.inventories[player] <- inventory
        for (int i = 0; i < 5; i++)
        {
            ArmorData data
            data.slot = i
            file.inventories[player].armor.append(data)
        }
    }
    
    return file.inventories[player].armor[slot]
}