////////////////////////
// SH_ITEM.NUT        //
// defines all items. //
////////////////////////
global function ShItems_Init
global function StringToCharArray
global function Roguelike_AddItemStat
global function Roguelike_DoesItemHaveModel
global function Roguelike_ExponentialChanceFunc
global function Roguelike_GetAllItems
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
global function Roguelike_GetRandomItem
global function Roguelike_GiveEntityItem
global function Roguelike_HyperbolicChanceFunc
global function Roguelike_LinearChanceFunc
global function Roguelike_Obsolete_And
global function Roguelike_Obsolete_IsGuranteed
global function Roguelike_Obsolete_Or
global function Roguelike_Obsolete_OutOfRange
global function Roguelike_Obsolete_WillNeverHappen
global function Roguelike_Obsolete_WithinRange
global function Roguelike_EntityHasItem
global function Roguelike_PrintPlayerInventory
global function Roguelike_RegisterItem
global function Roguelike_SetItemDrawbacks
global function Roguelike_RollForChanceFunc
global function Roguelike_RollStackingForChanceFunc

global const RARITY_COMMON = 0
global const RARITY_UNCOMMON = 1
global const RARITY_LEGENDARY = 2
global const RARITY_UMBRAL = 3
global const RARITY_TITAN = 4

global array<vector> roguelikeRarityColors = [<0.7, 0.7, 0.7>, // common
<0.1, 0.9, 0.1>, // uncommon
<0.9, 0.1, 0.1>, // legendary
<0.1, 0.1, 0.9>, // umbral
<0.8, 0.4, 0.1>] // titan

struct ItemStat
{
    string name
    float functionref( int ) chanceFunc
    string format
    bool isDrawback = false
    bool functionref( int ) obsoleteFunc = null
}

struct RoguelikeItem
{
    string id
    int numericId
    string name
    string description
    string drawbackDescription = ""
    int rarity
    asset model = $""
    float weight = 1.0
    table<int, string> chanceFormats
    array<ItemStat> stats
}

struct RoguelikeInventory
{
    table<string, int> items
}

struct
{
    table<string, RoguelikeItem> items
    array<float> rarityWeights = [35.0, 25.0, 5.0, 20, 12.5]
    table<entity, RoguelikeInventory> inventories
} file

void function ShItems_Init()
{
    float max = 0
    foreach (weight in file.rarityWeights)
    {
        max += weight
    }
    foreach (index, weight in file.rarityWeights)
    {
        printt("DROP CHANCE FOR RARITY", index, " - ", weight / max * 100.0)
    }

    // Ammo Pack
    Roguelike_RegisterItem( "ammo_pack", "Ammo Pack", "Upon kill:\n`215`0%% (`2+15`0%% per stack) chance to restore 10% of the magazine", RARITY_COMMON )
    float functionref( int ) func1 = Roguelike_LinearChanceFunc( 15, 15, 100 )
    float functionref( int ) func2 = Roguelike_LinearChanceFunc( 15, 15, 100, -100 )

    float functionref( int ) func3 = Roguelike_LinearChanceFunc( 15, 15, 100, -200 )
    int index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore 10%% Ammo", func1, "`2%.0f`0%%%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index, Roguelike_Obsolete_IsGuranteed( func2 ) )

    index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore 20%% Ammo", func2, "`2%.0f`0%%%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index, Roguelike_Obsolete_Or( Roguelike_Obsolete_IsGuranteed( func3 ), Roguelike_Obsolete_WithinRange( func1, -1, 100 ) ) )
    
    index = Roguelike_AddItemStat( "ammo_pack", "Chance to Restore a 30%% Ammo", func3, "`2%.0f`0%%%%" )
    Roguelike_SetStatObsoleteFunc( "ammo_pack", index,  Roguelike_Obsolete_WithinRange( func2, -1, 100 ) )

    // Health Generator

    Roguelike_RegisterItem( "heal_mod", "Health Generator", "+`210`0%% (+`210`0%% per stack) Regen Rate", RARITY_COMMON )

    func1 = Roguelike_LinearChanceFunc( 10, 10 )
    Roguelike_AddItemStat( "heal_mod", "Regen Rate", func1, "`2%+.0f`0%%%%" )

    Roguelike_RegisterItem( "emergency_soda", "Emergency Soda", "Upon taking lethal damage:\n\nHeal to full health. Consume 1 stack of this item. This will `1NOT`0 work on OoB zones.", RARITY_LEGENDARY )

    // adrenaline shot
    func1 = Roguelike_LinearChanceFunc( 0.5, 0.25 )
    Roguelike_RegisterItem( "adrenaline_shot", "Adrenaline Shot", "Upon kill:\nGain a 70%% speed boost for `20.5`0s (`2+0.25`0s per stack).\nAdditional kills refresh the duration.", RARITY_UNCOMMON )
    index = Roguelike_AddItemStat( "adrenaline_shot", "Boost Duration", func1, "`2%.2f`0s" )

    // send-back rounds
    func1 = Roguelike_LinearChanceFunc( 5, 5 )
    Roguelike_RegisterItem( "send_back_rounds", "Send-Back Rounds", "Upon hitting an headshot:\n`215`0%% (`2+15`0%% per stack) chance to restore a bullet.", RARITY_UNCOMMON )
    index = Roguelike_AddItemStat( "send_back_rounds", "Chance to Refill Mag", func1, "`2%.0f`0%%" )

    // Leeching Hands
    // +20Hp/s when wallrunning
    func1 = Roguelike_LinearChanceFunc( 20, 20 )
    Roguelike_RegisterItem( "leeching_hands", "Leeching Hands", "Heal for `220`0HP/s (`2+20`0HP/s per stack) while wallrunning.", RARITY_LEGENDARY )
    index = Roguelike_AddItemStat( "leeching_hands", "Regen Rate", func1, "`2%.0f`0HP/s" )
    
    // FRAGILE BIRD
    // +15% airAcceleration, -50 hp/s when wallrunning
    func1 = Roguelike_LinearChanceFunc( 20, 20 )
    func2 = Roguelike_LinearChanceFunc( 30, 30, 0, 0, true )
    Roguelike_RegisterItem( "fragile_bird", "Fragile Bird", "`2+15`0%% (`2+15`0%% per stack) air acceleration.", RARITY_UMBRAL )
    Roguelike_SetItemDrawbacks( "fragile_bird", "\nLose `220`0HP/s (`2+20`0%%HP/s per stack) when wallrunning." )
    index = Roguelike_AddItemStat( "fragile_bird", "Air Acceleration", func1, "`2%+.0f`0%%%%" )
    index = Roguelike_AddItemStat( "fragile_bird", "Health Loss while Wallrunning", func2, "`2%.0f`0HP/s", true )

    // 
    
    float amplifier = 50
    string chance = format("%.1f", Roguelike_HyperbolicChanceFunc( amplifier )(1) )

    Roguelike_RegisterItem( "overclock_mechanism", "Overclock Mechanism", "Upon killing a titan as BT:\n`2" + chance
         + "`0%% (`2" + chance + "`0%% per stack, hyperbolic) chance to overclock,\nresetting all cooldowns and refresh weapon ammo.", RARITY_TITAN )
    
    Roguelike_AddItemStat( "overclock_mechanism", "Overclock Chance", Roguelike_HyperbolicChanceFunc( amplifier ))
    //Roguelike_SetChanceFunctions( "overclock_mechanism", [ Roguelike_HyperbolicChanceFunc( amplifier, 0 ), Roguelike_HyperbolicChanceFunc( amplifier, 1 ) ] )
}

void function Roguelike_RegisterItem( string id, string name, string description, int rarity, float weight = 1.0, asset model = $"" )
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

int function Roguelike_GetItemRarity( string item )
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

string function Roguelike_GetRandomItem( int rarity = -1 )
{
    if (rarity == -1)
    {
        array<float> weights = file.rarityWeights

        rarity = GetRandomIndexFromWeightedArray( weights )
    }
    array<RoguelikeItem> items
    foreach ( item in file.items )
    {
        if ( item.rarity == rarity )
            items.append(item)
    }
    if ( items.len() == 0 )
        throw "No items exist for rarity " + rarity
    return items[GetRandomIndexFromWeightedItemArray( items )].id
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

    unreachable
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

    print( "Player " + player.GetPlayerName() + " has the following items:" )
    foreach ( item, count in file.inventories[player].items )
    {
        print( item + ": " + count )
    }
}

// NUMERIC IDS
// Used to call item obtain events on the client and 

void function Roguelike_GiveEntityItem( entity player, string item, int count = 1 )
{
    if ( !(player in file.inventories) )
    {
        RoguelikeInventory inventory
        file.inventories[player] <- inventory
    }
    if ( !(item in file.inventories[player].items) )
    {
        file.inventories[player].items[item] <- count
    }
    else file.inventories[player].items[item] += count

    if (player.IsPlayer())
        Roguelike_PrintPlayerInventory( player )
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

int function Roguelike_AddItemStat( string itemName, string statName, float functionref( int ) chanceFunc, string statFormat = "%.0f%%%%", bool isDrawback = false )
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

bool function Roguelike_RollForChanceFunc( float functionref( int ) chanceFunc, int stacks )
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

array<string> function Roguelike_GetAllItems( entity player )
{
    array<string> result = []
    if ( !( player in file.inventories ) )
        return []
    
    foreach ( key, value in file.inventories[player].items )
        result.append( key )

    return result
}

array<int> function StringToCharArray( string str )
{
    array<int> result = []
    for ( int i = 0; i < str.len(); i++ )
        result.append( expect int( str[i] ) )
    return result
}