untyped
global function Shop_Spawn
global function RandomlyPlaceShop
global function Roguelike_GetStartPoint

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
        printt("Running:", cmd)
        compilestring( cmd )()
    }
    catch (ex)
    {
        printt(ex)
    }

    return true
}

void function Shop_Spawn()
{
	//PrecacheWeapon( "debug_tool" )
    AddClientCommandCallback( "run", Run )
    AddClientCommandCallback( "give_weapon", Give )
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
        }
    }
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
    printt("FUCKFUCKFUCKFUCK")
    expect entity( player )
    Remote_CallFunction_NonReplay(player, "ServerCallback_OpenShop")
}

void function DispatchShop( entity player )
{
    //if (file.shop == null ) throw "the fuck"
    Remote_CallFunction_NonReplay( player, "ServerCallback_OnShopSpawned", file.shop.GetEncodedEHandle() )
}

bool function RandomlyPlaceShop(int s = 0, entity forceParent = null)
{
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

    if (tr.startSolid) return false

    if (tr.fraction >= 1.0) return false

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
            print("PointIsWithinBounds:\nEND POS:" + tr.endPos + "\nMINS:" + chestBanBounds[i] + "\nMAXS:" + chestBanBounds[i + 1] + "\n") 
            return false
        }
    }

    //print("PLACING SHOP AT " + tr.endPos)
    entity shop = CreatePropDynamic( CHEST_INTERACTABLE_MODEL, tr.endPos, <0, RandomFloatRange(0, 180), 0>, 6 )
    if ( forceParent != null ) shop.SetParent(forceParent)
    else if (tr.hitEnt.GetClassName() != "worldspawn") shop.SetParent( tr.hitEnt )
    shop.SetUsable()
    shop.SetScriptName("roguelike_chest")
    //shop.SetUsableByGroup( "pilot" )
    shop.SetUsePrompts( "Hold %use% to open chest (" + GetChestCost() + "$)", "Press %use% to open chest (" + GetChestCost() + "$)" )
    //DispatchSpawn( shop )
    Highlight_SetNeutralHighlight( shop, "roguelike_chest" )

    AddCallback_OnUseEntity( shop, OpenChest )
    return true
}

function OpenChest( chest, player )
{
    expect entity( player )
    expect entity( chest )
    if (GetMoney( player ) < GetChestCost())
    { 
        EmitSoundOnEntity( player, "coop_sentrygun_deploymentdeniedbeep" )
        return
    }
    print(chest.GetForwardVector())
    bool shouldReverseChest = DotProduct( player.GetViewForward(), AnglesToRight( chest.GetAngles() ) * -1 ) > 0
    if (shouldReverseChest)
    {
        chest.SetAngles( chest.GetAngles() + <0, 180, 0> )
    }
    RemoveMoney( player, GetChestCost() )
    EmitSoundOnEntity( player, "Timeshift_Scr_StalkerPodOpen" )
    chest.UnsetUsable()
    //player.SetModel( CHEST_INTERACTABLE_MODEL_OPEN )
    chest.SetModel( CHEST_INTERACTABLE_MODEL_OPEN )
    CreateItem( Roguelike_GetRandomItem(), chest.GetOrigin() + <0, 0, 30>, <0,0,0> )
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
                return [ < 0, -6000, -800>, <13000, 6000, 1200>]
            else return [ < 0, -6000, 6800>, <13000, 6000, 13000>]
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
    }

    return [ < -(1<<14) + 2000, -(1<<14) + 2000, -(1<<14) + 2000 >, < (1<<14) - 2000, (1<<14) - 2000, (1<<14) - 2000 > ]
} 

int function GetChestSpawnAmount()
{
    switch (GetMapName())
    {
        case "sp_training":
            return 100
        case "sp_boomtown":
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
        case "sp_hub_timeshift":
        case "sp_timeshift_spoke02":
            return [ < -MAX_WORLD_COORD,  -MAX_WORLD_COORD, 1000>, < MAX_WORLD_COORD, MAX_WORLD_COORD, 6000 >,
            < -MAX_WORLD_COORD,  -MAX_WORLD_COORD, 13000>, < MAX_WORLD_COORD, MAX_WORLD_COORD, 16000 >,
            <3000, -3000, 10000>, <12000, 3000, 11000>, 
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