untyped
global function Shop_Spawn
global function Roguelike_GetStartPoint
global function RandomlyPlaceShop
global function GetShopSpawnLocation

global entity s2s_mover = null
// model to represent the interactable shop
const asset SHOP_INTERACTABLE_MODEL = $"models/beacon/crane_room_monitor_console.mdl"
const asset CHEST_INTERACTABLE_MODEL = $"models/containers/pelican_case_large.mdl"
const asset CHEST_INTERACTABLE_MODEL_OPEN = $"models/containers/pelican_case_large_open.mdl"
// placeholder for the shop, will be replaced by the above.
//const asset SHOP_INTERACTABLE_MODEL = $"models/humans/grunts/imc_grunt_rifle.mdl"


struct
{
    entity shop
} file

int function Roguelike_GetStartPoint()
{
    LevelTransitionStruct ornull trans = GetLevelTransitionStruct()
    if (trans != null)
    {
        expect LevelTransitionStruct( trans )
        return trans.startPointIndex
    }
    return GetConVarInt("sp_startpoint")
}

vector function GetShopSpawnLocation()
{
    switch (GetMapName())
    {
        case "sp_beacon":
            // chapter 2 completed flag.
            // we set buy menu interactable to inside the control room instead, to give the player access as usual.
            #if SP
            if (Roguelike_GetStartPoint() > 1)
            {
                return <12714.5, -2154.05, 84.0313>
            }
            else
            {
                return <13392.5, -10021.2, 1072.85>
            }
            #else
                return <13392.5, -10021.2, 1072.85>
            #endif
        case "sp_beacon_spoke0":
            return < -959.501, 1378.04, 392.031>
        case "sp_crashsite":
            // next to BT - the player will be able to access it 3 times (after 18 hour cutscene, getting first bat, and before entering BT.
            //
            return < -510.4, -292.529, 23.6106 >
        case "sp_sewers1":
            return < 10800, 6620, 784 >
        case "sp_training":
            return < -7083.85, -4625.5, -159.969 >
        case "sp_boomtown":
            return < -6927.13, 9099.54, 7424.03>

    }
    return <0,0,0>
}

vector function GetShopSpawnAngles()
{
    switch (GetMapName())
    {
        case "sp_beacon":
            // chapter 2 completed flag.
            #if SP
            if (Roguelike_GetStartPoint() > 1)
            {
                return <0,-90,0>
            }
            else
            {
                return <0,180,0>
            }
            #endif
            return <0,0,0>

            // we set buy menu interactable to inside the control room instead, to give the player access as usual.
            //if (Flag( "Spoke0Completed" ))
            //    return <12714.5, -2154.05, 84.0313>
            //else return <13392.5, -10021.2, 1072.85>

        case "sp_beacon_spoke0":
            return < 0, -90, 0>
        case "sp_crashsite":
            // next to BT - the player will be able to access it 3 times (after 18 hour cutscene, getting first bat, and before entering BT.
            //
            return < 0, 0, 0 >
        case "sp_training":
            return < 0, -45, 0 >
        case "sp_boomtown":
            return <0, 45, 0 >

        case "sp_sewers1":
            return <0,180,0>
    }
    return <0,0,0>
}

bool function Run( entity player, array<string> args )
{
    string cmd = ""
    for ( int i = 0; i < args.len(); i++ )
	{
		cmd = (cmd + args[i])

		if(args[i] == "'" || ((i+1) < args.len() && args[i+1] == "'")) {
			// don't add spaces inside strings
		} else {
			cmd = (cmd + " ")
		}
	}
    while (cmd.find("'") != null)
    {
        int i = expect int( cmd.find("'") )
        cmd = cmd.slice(0, i) + "\"" + cmd.slice(i+1, cmd.len())
    }
    try
    {
        //printt("Running:", cmd)
        compilestring( cmd )()
    }
    catch (ex)
    {
        //printt(ex)
    }

    return true
}

void function Shop_Spawn()
{
    if (IsLobby()) return
    SetConVarInt("sv_maxvelocity", 100000)
	//PrecacheWeapon( "debug_tool" )
    AddClientCommandCallback( "run", Run )
    AddClientCommandCallback( "give_weapon", Give )
    AddClientCommandCallback( "spawn_item", SpawnItem )
    PrecacheModel( SHOP_INTERACTABLE_MODEL )

    PrecacheModel( $"models/weapons/ammoboxes/ammobox_01.mdl" )
    PrecacheModel( $"models/weapons/ammoboxes/ammobox_bigbullet.mdl" )
    PrecacheModel( $"models/weapons/ammoboxes/ammobox_bigclip.mdl" )
    //PrecacheModel( $"models/weapons/ammoboxes/ammobox_missle.mdl" )
    PrecacheModel( $"models/weapons/ammoboxes/backpack_single.mdl" )
    PrecacheModel( $"models/weapons/ammoboxes/mags_cluster.mdl" )
    PrecacheModel( $"models/containers/pelican_case_large_open.mdl" )

    entity shop = CreatePropDynamic( SHOP_INTERACTABLE_MODEL, GetShopSpawnLocation(), GetShopSpawnAngles(), 6 )
    //shop.SetOrigin( GetShopSpawnLocation() + <0, 100, 0> )
    shop.SetUsable()
    shop.SetUsableByGroup( "pilot" )
    shop.SetUsePrompts( "Hold %use% to open the shop", "Press %use% to open the shop" )
    //DispatchSpawn( shop )
    Highlight_SetNeutralHighlight( shop, "interact_object_always_far" )
    file.shop = shop

    AddCallback_OnUseEntity( shop, OpenShopMenu )
    //foreach
    AddCallback_OnClientConnected( DispatchShop )
    ServerCommand("dof_enable 0")

    for (int i = 0; i < GetChestSpawnBanBounds().len(); i += 2)
    {
        Roguelike_DebugDrawBox( GetChestSpawnBanBounds()[i], GetChestSpawnBanBounds()[i+1], 255, 0, 0 )
    }

    Roguelike_DebugDrawBox( GetChestBounds()[0], GetChestBounds()[1], 0, 255, 0 )
    Roguelike_DebugDrawBox( GetChestBounds(1)[0], GetChestBounds(1)[1], 0, 255, 0 )

    if (GetChestSpawnBanBounds().len() % 2 > 0)
    {
        throw "???"
    }

    int attempts = 0
    int shopsPlaced = 0
    if (GetMapName() != "sp_s2s")
    {
        for (int i = 0; i < GetChestSpawnAmount(); attempts++)
        {
            if (RandomlyPlaceShop(i))
                i++
            //print("randomly place shop end")
        }
    }
}

bool function SpawnItem( entity player, array<string> args )
{
    if (!GetConVarBool("sv_cheats")) return false
    try
    {
        CreateItem( args[0], player.GetOrigin(), player.GetAngles() )
    }
    catch (ex)
    {
        //t(ex)
        //CodeWarning("Unknown Item.")
        //return false
    }
    return true
}

bool function Give( entity player, array<string> args)
{
    if (args.len() < 1)
    {
        return false
    }

    string weapon = args[0]

    int offhandSlot = -1
    if (args.len() >= 2)
    switch (args[1].tolower())
    {
        case "o":
        case "left":
        case "l":
        case "ordnance":
        case "0":
            offhandSlot = 0;
            break
        case "t":
        case "right":
        case "r":
        case "tactical":
        case "1":
            offhandSlot = 1;
            break
        case "u":
        case "middle":
        case "m":
        case "utility":
        case "2":
            offhandSlot = 2;
            break
        case "b":
            offhandSlot = 4;
            break
    }

    if (!WeaponIsPrecached(weapon))
    {
        CodeWarning("Weapon '" + weapon + "' is not precached or doesn't exist.")
        return true
    }

    if (HasWeapon(player, weapon) && player.GetActiveWeapon().GetWeaponClassName() != weapon)
    {
        CodeWarning("You already have this weapon.")
        return true
    }

    if (offhandSlot != -1)
    {
        if (IsValid(player.GetOffhandWeapon(offhandSlot)))
        {
            player.TakeOffhandWeapon(offhandSlot)
        }
        player.GiveOffhandWeapon(weapon, offhandSlot)
    }
    else
    {
        #if MP
        if (player.GetMainWeapons().len() >= 3)
        #else
        if (player.GetMainWeapons().len() >= 2)
        #endif
            player.TakeWeaponNow( player.GetActiveWeapon().GetWeaponClassName() )

        entity weapon = player.GiveWeapon( weapon )

        weapon.Highlight_SetCurrentContext( 0 )
        try
        {
            weapon.SetMods( args.slice(1, args.len()) )
        }
        catch (ex)
        {

        }
    }

    return true
}

function OpenShopMenu( shop, player )
{
    //printt("FUCKFUCKFUCKFUCK")
    expect entity( player )
    expect entity( shop )
    ServerToClientStringCommand( player, "shopitems " + GetItemArrayString(Roguelike_GetItemsInShop()))
    Remote_CallFunction_NonReplay(player, "ServerCallback_OpenShop")
}

string function GetItemArrayString( array<string> mods )
{
	string s = ""
	for (int i = 0; i < mods.len(); i++) {
		s += mods[i]
		if (i < mods.len() - 1) s += " "
	}
	return s
}

void function DispatchShop( entity player )
{
    //if (file.shop == null ) throw "the fuck"
    Remote_CallFunction_NonReplay( player, "ServerCallback_OnShopSpawned", file.shop.GetEncodedEHandle() )
}

// <0,0,0>
// <1,1,1>

// get

// <0,0,1>
// <1,1,0>

// <0,1,0>
// <1,0,1>

// <1,0,0>
// <0,1,1>
void function Roguelike_DebugDrawBox( vector mins, vector maxs, int r, int g, int b, bool drawThroughWorld = true, float duration = 9999.9 )
{
    vector minX = mins
    minX.x = maxs.x

    vector maxX = maxs
    maxX.x = mins.x

    vector minY = mins
    minY.y = maxs.y

    vector maxY = maxs
    maxY.y = mins.y

    vector minZ = mins
    minZ.z = maxs.z

    vector maxZ = maxs
    maxZ.z = mins.z

    // 12 edges
    DebugDrawLine(mins, minX, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(mins, minY, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(mins, minZ, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxs, maxX, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxs, maxY, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxs, maxZ, r, g, b, !drawThroughWorld, duration)

    DebugDrawLine(minX, maxY, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minX, maxZ, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minY, maxX, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minY, maxZ, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minZ, maxX, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minZ, maxY, r, g, b, !drawThroughWorld, duration)

    DebugDrawLine(mins, maxZ, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minX, maxs, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minY, maxs, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(minZ, maxs, r, g, b, !drawThroughWorld, duration)

    DebugDrawLine(maxs, minZ, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxX, mins, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxY, mins, r, g, b, !drawThroughWorld, duration)
    DebugDrawLine(maxZ, mins, r, g, b, !drawThroughWorld, duration)
}

bool function RandomlyPlaceShop(int s = 0, entity forceParent = null)
{
    //print("randomly place shop start")
    entity worldspawn = GetEnt( "worldspawn" )
    vector pos = <0,0,0>
    array<vector> bounds = GetChestBounds(s)
    if (GetMapName() == "sp_s2s")
    {
        foreach (vector v in bounds)
            v += s2s_mover.GetOrigin()
    }
    pos.x = xorshift_range( bounds[0].x, bounds[1].x, GetRoguelikeSeed() + 1 )
    pos.y = xorshift_range( bounds[0].y, bounds[1].y, GetRoguelikeSeed() + 1 )
    pos.z = xorshift_range( bounds[0].z, bounds[1].z, GetRoguelikeSeed() + 1 )

    // ooga booga shop trace
    vector endPos = pos - <0, 0, 200>

    //if (fabs(GetChestSpawnZBan() - pos.z) < 2000)
    //    return false

    if (bounds[0].z > endPos.z)
        endPos.z = bounds[0].z

    TraceResults tr = TraceHull( pos, endPos, < -31, -31, 0 >, < 31, 31, 53 >, null, TRACE_MASK_BLOCKLOS, TRACE_COLLISION_GROUP_NONE )

    if (tr.startSolid || tr.allSolid || tr.fraction <= 0.2 || tr.fraction >= 1.0) return false

    array<vector> chestBanBounds = GetChestSpawnBanBounds()
    for (int i = 0; i < chestBanBounds.len(); i += 2)
    {
        if (GetMapName() == "sp_s2s")
        {
            chestBanBounds[i] += s2s_mover.GetOrigin()
            chestBanBounds[i + 1] += s2s_mover.GetOrigin()
        }
        if (PointIsWithinBounds(tr.endPos, chestBanBounds[i], chestBanBounds[i + 1]))
        {
            //print("PointIsWithinBounds:\nEND POS:" + tr.endPos + "\nMINS:" + chestBanBounds[i] + "\nMAXS:" + chestBanBounds[i + 1] + "\n")
            return false
        }
    }

    //PrintTraceResults( tr )
    entity shop = CreateEntity( "prop_dynamic" )
    shop.SetModel( CHEST_INTERACTABLE_MODEL )
    shop.SetOrigin( tr.endPos )
    shop.SetAngles( <0, RandomFloatRange(0, 180), 0> )
    shop.kv.solid = 6
    if ( forceParent != null ) shop.SetParent(forceParent)
    else if (tr.hitEnt.GetClassName() != "worldspawn") 
    {
        if (tr.hitEnt.GetScriptName() == "roguelike_chest") return false
        shop.SetParent( tr.hitEnt )
    }
    //if (RandomFloat(1.0) < 0.1)
    shop.kv.rendercolor = "255 255 255"
    DispatchSpawn( shop )
    shop.SetUsable()
    shop.SetScriptName("roguelike_chest")
    //shop.SetUsableByGroup( "pilot" )
    float multiplier = 1
    string name = "Chest"
    if (xorshift_range( 0.0, 1.0, GetRoguelikeSeed() + 1 ) < 0.3333)
    {
        shop.s.weights <- {
            uncommon = 10.0, 
            legendary = 2.0}
        multiplier *= 2
        name = "Large Chest"
        Highlight_SetNeutralHighlight( shop, "roguelike_large_chest" )
    }
    else Highlight_SetNeutralHighlight( shop, "roguelike_chest" )
    shop.s.multiplier <- multiplier
    shop.SetUsePrompts( "Hold %use% to open " + name + " (" + GetChestCost(multiplier) + "$)", "Press %use% to open " + name + " (" + GetChestCost(multiplier) + "$)" )
    //DispatchSpawn( shop )
    //Highlight_SetNeutralHighlight( shop, "roguelike_chest" )

    AddCallback_OnUseEntity( shop, OpenChest )
    return true
}

function OpenChest( chest, player )
{
    expect entity( player )
    expect entity( chest )
    float multiplier = expect float( chest.s.multiplier )
    if (GetMoney( player ) < GetChestCost(multiplier))
    {
        EmitSoundOnEntity( player, "coop_sentrygun_deploymentdeniedbeep" )
        return
    }
    //print(chest.GetForwardVector())
    bool shouldReverseChest = DotProduct( player.GetViewForward(), AnglesToRight( chest.GetAngles() ) * -1 ) > 0
    if (shouldReverseChest)
    {
        chest.SetAngles( chest.GetAngles() + <0, 180, 0> )
    }
    RemoveMoney( player, GetChestCost(multiplier) )
    EmitSoundOnEntity( player, "Timeshift_Scr_StalkerPodOpen" )
    chest.UnsetUsable()
    //player.SetModel( CHEST_INTERACTABLE_MODEL_OPEN )
    chest.SetModel( CHEST_INTERACTABLE_MODEL_OPEN )
    string item = ""
    if ("weights" in chest.s)
    {
        table arr = expect table( chest.s.weights )
        table<string, float> arrF
        foreach (var k, var v in arr)
        {
            expect string(k)
            expect float(v)
            arrF[k] <- v
            //printt(v)
        }
        item = Roguelike_GetRandomItemWithCustomWeights( arrF )
    }
    else item = Roguelike_GetRandomItem()
    CreateItem( item, chest.GetOrigin() + <0, 0, 30>, <0,0,0> ).SetParent(chest)

    // nobody stays in an area for more than 2 minutes... right?
    thread DestroyAfterDelay(chest, 120)
}

array<vector> function GetChestBounds(int s = 0)
{
    switch (GetMapName())
    {
        case "sp_beacon":
            return [ < -16000, -10000, 0>, <13000, 10000, 2400> ]
        case "sp_beacon_spoke0":
            return [ < -7000,-600,-1500>, <4200,13000,1800> ]
        case "sp_training":
            return [ < -8000, -12000, -100>, <2000, 6000, 400>]
        case "sp_timeshift_spoke02":
            if (s % 2 == 0)
                return [ < 0, -6000, -800>, <13000, 6000, 900>]
            else return [ < 0, -6000, -800 + 11520>, <13000, 6000, 900 + 11520>]
        case "sp_sewers1":
            return [ < -11000, -14000, 0>, <11000, 9400, 3500>]
        case "sp_s2s":
            if (!IsValid(s2s_mover))
            {
                CodeWarning("S2S MOVER NOT VALID! NO CHEST SPAWNS WILL BE AVAILABLE!")
                break
            }
            return [< -2000, -8000, -2000>, <2000, 8000, 1000> ]
        case "sp_crashsite":
            return [ < -(1<<14) + 2000, -(1<<14) + 2000, 0 >, < (1<<14) - 2000, (1<<14) - 2000, 1500 > ]
        case "mp_thaw":
            return [ < -2900, -5650, -500>, <5000, 4400, 400> ]
    }

    return [ < -(1<<14) + 2000, -(1<<14) + 2000, -(1<<12) + 2000 >, < (1<<14) - 2000, (1<<14) - 2000, (1<<12) - 2000 > ]
}

int function GetChestSpawnAmount()
{
    switch (GetMapName())
    {
        case "sp_training":
            return 100
        case "sp_boomtown":
            return 100
        case "mp_thaw":
            return 100
    }
    return 250
}

float function GetChestSpawnZBan()
{
    switch (GetMapName())
    {
        case "sp_timeshift_spoke02":
            return 5000
    }
    return -99999
}

array<vector> function GetChestSpawnBanBounds()
{
    switch (GetMapName())
    {
        case "sp_training":
            return [ < -14000, -13000, -60>, < 14000, -7600, 300> ]
        case "sp_crashsite":
            return [ < -1350, -1600, 350>, <5000, 5000, 1500>,
                     < -3600, -8000, 0>, < -870, -1600, 2500>]
        case "sp_hub_timeshift":
        case "sp_timeshift_spoke02":
            return [ //< -MAX_WORLD_COORD,  -MAX_WORLD_COORD, 1000>, < MAX_WORLD_COORD, MAX_WORLD_COORD, 6000 >,
            //< -MAX_WORLD_COORD,  -MAX_WORLD_COORD, 1000 + 11520>, < MAX_WORLD_COORD, MAX_WORLD_COORD, 6000 + 11520 >,
            <3000, -3000, -700 + 11520>, <12000, 3000, -200 + 11520>,
            <3000, -3000, -700>, <12000, 3000, -200> ]
            break
        case "sp_s2s":
            return [
                < -2000, -4000, -2000>, <2000, 8000, -400>,
                < -2000, -8000, -8000>, <500, 0, 2000>,
                < -2000, -8000, -8000>, <1000, 0, -500>,
            ]
    }
    return [ <99990,99990,99990>, <99990,99990,99990> ]
}