untyped
globalize_all_functions

global const MODVALUE_COMMON = 0
global const MODVALUE_UNCOMMON = 1
global const MODVALUE_RARE = 2
global const MODVALUE_EPIC = 3
global const MODVALUE_LEGENDARY = 4
global const MODVALUE_PRESET = 5

struct ModData
{
    string className // name of the mod on the weapon (e.g. extended_ammo)
    string displayName // display name of the mod (e.g. Extended Ammo)
    int value // price of the mod (e.g. 100)
    string desc
    array<string> presetMods = []// For preset mods, these are the mods that will be included in the weapon.
    table<string, float> weaponOverrides
}

struct 
{
    array<ModData> mods
} file

void function ShopPrices_Init()
{
    #if SERVER || CLIENT
    AddCallback_OnRegisteringHighlights(RegisterRoguelikeHighlight)
    #endif

    ShopPrices_AddMod("light_mag", "Light Mag", "+5%% movement speed, -20%% mag size", MODVALUE_COMMON)
    ShopPrices_AddMod("heavy_mag", "Heavy Mag", "+50%% mag size, x2 recoil randomness.", MODVALUE_COMMON)
    ShopPrices_AddMod("knockback", "Shockwave Rounds", "Fly through the air when firing near a surface.", MODVALUE_RARE)
    ShopPrices_AddMod("ricochet", "Ricochet", "Projectiles bounce off of walls.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("jump_kit", "Jump Kit", "Fly through the air when firing near a surface.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("belt_fed", "Belt Fed", "Ammo is taken directly from the\nstockpile.", MODVALUE_EPIC)
    ShopPrices_AddMod("extended_ammo", "Extended Ammo", "Base Mag size increased.", MODVALUE_RARE)
    ShopPrices_AddMod("pas_fast_reload", "Fast Reload", "-30% reload time.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("pas_run_and_gun", "Run & Gun", "Shoot while sprinting.", MODVALUE_COMMON)
    ShopPrices_AddMod("pas_fast_swap", "Fast Swap", "25%% swap time.", MODVALUE_COMMON)
    ShopPrices_AddMod("pas_fast_ads", "Fast ADS", "Zoom in time halved.", MODVALUE_COMMON)
    ShopPrices_AddMod("choked", "Choked", "Spread decreased, better damage falloff.", MODVALUE_RARE)
    ShopPrices_AddMod("one_mag_or_die", "One Mag Or Die", "Mag `2halved`1. Damage\n`2doubled`1.", MODVALUE_EPIC)
    ShopPrices_AddMod("old_kick", "Old Kick", "Recoil is...weird.", MODVALUE_EPIC)
    ShopPrices_AddMod("ar_trajectory", "Natrual Granedier", "Grenade trajectory visible from hipfire.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("slowProjectile", "Reduced Propellent", "Reduced projectile speed... `2Big boom`0.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("rampdown", "Rampdown", "Emit revo `2sesaerced`1 etar erif.\nEtar erif esab hgih.", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("rocket_arena", "ROCKET ARENA!", "Fun for the whole family!", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("one_in_the_chamber", "VERY HIGH CALIBER™", "`2One shot, one kill.`0", MODVALUE_PRESET)
    // it makes snipers viable, but otherwise useless.
    ShopPrices_AddMod("half_zoom", "Half Zoom", "weapon maginification is halved.", MODVALUE_COMMON)
    ShopPrices_AddMod("sub_mini_gun", "Submini-gun", "+50%% Fire rate & mag. -20%%\ndamage.", MODVALUE_EPIC)

    ShopPrices_AddMod("doom_shotgun", "eternally broken", "All it's missing is one more barrel...", MODVALUE_PRESET)
    ShopPrices_SetPresetMods( "doom_shotgun", ["knockback", "pas_fast_reload", "condensed_gunpowder"])

    ShopPrices_AddMod("condensed_gunpowder", "Condensed Gunpowder", "Proj. speed & damage increased. x2 recoil\nrandomness.", MODVALUE_UNCOMMON)

    ShopPrices_AddMod("it_never_ends", "it never ends", "FASTER, AND `0FASTER`1, AND `2FASTER!`1", MODVALUE_PRESET)
    ShopPrices_SetPresetMods( "it_never_ends", ["heavy_mag", "belt_fed", "burn_mod_esaw", "pas_fast_swap", "aog"])

    ShopPrices_AddMod("pm0", "Upgrade 1", "An upgraded,\nunreleased version of this tactical.", MODVALUE_RARE)
    ShopPrices_AddMod("pm1", "Upgrade 2", "An upgraded,\nunreleased version of this tactical.", MODVALUE_EPIC)
    ShopPrices_AddMod("pm2", "Upgrade 3", "An upgraded,\nunreleased version of this tactical.", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("ap_rounds", "Armor Piercing Rounds", "x2 damage against\ntitans. No crit required.", MODVALUE_RARE)
    ShopPrices_AddMod("bc_long_stim1", "Extended Stim", "x1.5 duration.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("bc_long_stim2", "XL Stim", "x2 duration.", MODVALUE_RARE)
    ShopPrices_AddMod("bc_long_cloak1", "Extended Cloak", "x1.5 duration.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("bc_long_cloak2", "XL Cloak", "x2 duration.", MODVALUE_RARE)
    ShopPrices_AddMod("bc_super_stim", "Super Stim", "x2 duation.", MODVALUE_EPIC)
    ShopPrices_AddMod("time_is_damage", "Time Is Damage", "The longer the bullet flies, the higher the damage.", MODVALUE_EPIC)
    ShopPrices_AddMod("long_last_shifter", "Long Shift", "x2 duration in phase.", MODVALUE_RARE)
    ShopPrices_AddMod("long_last_shifter", "Long Shift", "x2 duration in phase.", MODVALUE_RARE)

    ShopPrices_AddMod("pas_power_cell", "Power Cell", "-26% cooldown.", MODVALUE_RARE)
    ShopPrices_SetModWeightOverride("pas_power_cell", "mp_ability_grapple", 0.0)

    ShopPrices_AddMod("amped_tacticals", "Amped Tactical", "+1 charge.", MODVALUE_RARE)
    ShopPrices_SetModWeightOverride("amped_tacticals", "mp_ability_grapple", 0.0)
    ShopPrices_SetModWeightOverride("amped_tacticals", "mp_ability_cloak", 0.0)

    ShopPrices_AddMod("delayed_shot", "Delayed Shot", "Projectile starts slow and then ignites for bonus damage.", MODVALUE_LEGENDARY)
    ShopPrices_SetModWeightOverride("delayed_shot", "mp_weapon_epg", 0.0)

    ShopPrices_AddMod("reloadanimtest", "Alt reload anim", "An alternative, faster reload animation.", MODVALUE_EPIC)

    ShopPrices_AddMod("quick_charge", "Quick Charge", "Reduced charge time & reduced damage.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("long_charge", "Long Charge", "Increased charge time for `2triple`1 damage.", MODVALUE_UNCOMMON)
    ShopPrices_AddMod("short_charge", "Short Charge", "`2half`0 charge time for slightly reduced damage.", MODVALUE_UNCOMMON)

    ShopPrices_AddMod("rcee", "RCEE", ":3", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("burst_orientation_3", "Burst Orientation x3", "Fires in a burst of\n3. Increased damage.", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("burst_orientation_4", "Burst Orientation x4", "Fires in a burst of\n4. Increased damage.", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("mag_dump", "Mag Dump", "Fires the mag in one burst.\nIncreased damage.", MODVALUE_LEGENDARY)
    ShopPrices_AddMod("rcee", "RCEE", ":3", MODVALUE_LEGENDARY)

    ShopPrices_AddMod("wide", "W I D E", "Adds more projectiles to\nthe spread pattern.", MODVALUE_EPIC)
    ShopPrices_AddMod("mass_destruction", "Ricoshart", "What's that? Ricochet's a bad mod?", MODVALUE_PRESET)
    ShopPrices_SetPresetMods("mass_destruction",  ["wide", "extended_ammo"])


    ShopPrices_AddMod("all_grapple", "Amped Tactical", "+1 charge.", MODVALUE_RARE)
    //ShopPrices_AddMod("pas_fast_reload", "Fast Swap", "", 15)
}

#if CLIENT || SERVER
void function RegisterRoguelikeHighlight()
{
    HighlightContext h = RegisterHighlight( "roguelike_item" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 2000 )
	HighlightContext_SetRadius( h, 8 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.ALWAYS )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <1,1,1>)
    HighlightContext_SetParam(h, 1, <1,1,1>)
	HighlightContext_SetAfterPostProcess( h, true )

    h = RegisterHighlight( "roguelike_chest" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 5000 )
	HighlightContext_SetRadius( h, 8 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.LOS_LINE )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <1, 1, 1>)
    HighlightContext_SetParam(h, 1, <1, 1, 1>)
	HighlightContext_SetAfterPostProcess( h, true )
    
    h = RegisterHighlight( "roguelike_large_chest" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 5000 )
	HighlightContext_SetRadius( h, 4 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.LOS_LINE )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <0, 0.4, 0>)
    HighlightContext_SetParam(h, 1, <0, 0.4, 0>)
    
    h = RegisterHighlight( "roguelike_armor_chest" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 5000 )
	HighlightContext_SetRadius( h, 4 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.LOS_LINE )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <0.2, 0, 0.4>)
    HighlightContext_SetParam(h, 1, <0.2, 0, 0.4>)
}
#endif

void function ShopPrices_SetPresetMods(string className, array<string> mods)
{
    for (int i = 0; i < file.mods.len(); i++)
    {
        if (file.mods[i].className == className)
        {
            file.mods[i].presetMods = mods;
            return;
        }
    }
    throw "That mod does not exist."
}

bool function ShopPrices_IsModRegistered(string mod)
{
	if (mod.find("burn_mod") != null) return true
    for (int i = 0; i < file.mods.len(); i++)
    {
        if (file.mods[i].className == mod)
        {
            return true;
        }
    }
    return false
}

array<string> function ShopPrices_GetPresetMods(string className)
{
    for (int i = 0; i < file.mods.len(); i++)
    {
        if (file.mods[i].className == className)
        {
            return file.mods[i].presetMods;
        }
    }
    unreachable
}

void function ShopPrices_AddMod(string name, string displayName, string description, int value)
{
    ModData data

    data.className = name
    data.displayName = displayName
    data.value = value
    data.desc = description
    data.weaponOverrides[""] <- -1.0

    file.mods.append(data)
}

#if CLIENT || SERVER
int function GetMoney( entity player )
{
    if (!("money" in player.s))
        return 0
    return expect int( player.s.money )
}
#endif

string function ShopData_GetModName(string mod)
{
	if (mod.find("burn_mod") != null) return "Amped Weapon"
    foreach (ModData m in file.mods)
    {
        if (m.className == mod)
        {
            return m.displayName
        }
    }
    unreachable
}

string function ShopData_GetModDesc(string m)
{
	if (m.find("burn_mod") != null) return "Extra weapon damage."
    foreach (ModData mod in file.mods)
    {
        if (mod.className == m)
        {
            return mod.desc
        }
    }
    unreachable
}

int function ShopData_GetModValue(string m)
{
	if (m.find("burn_mod") != null) return MODVALUE_UNCOMMON
    foreach (ModData mod in file.mods)
    {
        if (mod.className == m)
        {
            return mod.value
        }
    }
    unreachable
}

float function GetModWeight( string modName, string weaponName )
{
	switch (modName)
	{
		// All weapons should have jump kit if possible.
		// It's generally more fun.
		case "jump_kit":
			return 1000.0;
			break;
            
	    case "mag_dump":
            return 0.1666
		// disable smart lock.. cause it doesn't work
		case "smart_lock":
		// same problem with this mod.
		case "tactical_cdr_on_kill":
		// I want NPCs to fire as much as possible.
		case "less_npc_burst":
		// disable vanilla mods
		case "silencer":
		case "pro_screen":
		// sprinting disabled
        case "pas_run_and_gun":
		//case "pas_fast_aim":
        //case "pas_fast_reload":
		//case "extended_ammo":
        case "pro_screenextended_ammo": // don't know why this exists...?
        case "alt_spread": // does nothing
        case "econ":
        case "training_low_ammo_disable":
        case "sns":
        case "pas_ordnance_pack":
        case "dev_mod_low_recharge": 
        case "quick_charge":   
			return 0.0;
		// don't disable ricochet cause it's like the only thing that isn't a pure upgrade
	}
	if (modName.find("burst_orientation") != null) return 0.1666
	if (modName.find("burn_mod") != null) return 1.0
	if (modName.find("spree_lvl") != null) return 0.0
	if (modName.find("sp_s2s_settings") != null) return 0.0
    if (regexp( "bc_\\w+_refill" ).match(modName)) return 0.0
    if (regexp( "bc_fast_cooldown_\\w+" ).match(modName)) return 0.0
	if (ShopPrices_IsModRegistered(modName)) {
        float weightOverride = ShopPrices_GetModWeightOverride( modName, weaponName )
        if (weightOverride != -1.0) return weightOverride
        switch (ShopData_GetModValue(modName))
        {
            case MODVALUE_COMMON:
                return 1.0
            case MODVALUE_UNCOMMON:
                return 1.0
            case MODVALUE_RARE:
                return 0.8
            case MODVALUE_EPIC:
                return 0.65
            case MODVALUE_LEGENDARY:
                return 0.5
            case MODVALUE_PRESET:
                return 0.05
        }
    }

    return 1.0
}

float function ShopPrices_GetModWeightOverride( string className, string weaponName )
{ 
    for (int i = 0; i < file.mods.len(); i++)
    {
        if (file.mods[i].className == className)
        {
            if (weaponName in file.mods[i].weaponOverrides)
                return file.mods[i].weaponOverrides[weaponName]
            else return file.mods[i].weaponOverrides[""]
        }
    }

    unreachable
}

void function ShopPrices_SetModWeightOverride( string className, string weaponName, float val )
{ 
    for (int i = 0; i < file.mods.len(); i++)
    {
        if (file.mods[i].className == className)
        {
            file.mods[i].weaponOverrides[weaponName] <- val
            return
        }
    }

    throw ("Class name " + className + " does not exist!")
}