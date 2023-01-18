global function WeaponDisplay_Init
global function DisplayWeapon
global function StopDisplay
global function PauseDisplay
global function ResumeDisplay

const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"
const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"

float[2]& screenSize = [1920, 1080]

array<vector> colors = [
	<0.3, 0.3, 0.3>,
	<0.15, 0.75, 0.15>,
	<0.15, 0.35, 0.75>,
	<0.55, 0.15, 0.75>,
	<0.55, 0.35, 0.05>,
	<0.75, 0.1, 0.1>
]

struct
{
	entity focusedEnt

	// PICKUP RUI
	var bgRui
	var weaponNameRui
	var weaponLevelRui
	var weaponLevelLabelRui
    var weaponFireRateRui
    var weaponFireRateLabelRui
    var weaponBGTopo
	var weaponModTopo
	int modCount
	bool shouldShowFlyout = true
	array<var> modNameRuis
	array<var> modDescRuis
	array<string> unregisteredMods
} file

void function WeaponDisplay_Init()
{
	screenSize = GetScreenSize()
    var topo = RuiTopology_CreatePlane( <screenSize[0] * 0.07, screenSize[1] - screenSize[1] * 0.25, 0>, <screenSize[0] * 0.3, 0, 0>, <0, screenSize[0] * 0.3 / 16.0 * 9.0, 0>, false )
	var bgTopo = RuiTopology_CreatePlane( <screenSize[0] * 0.07, screenSize[1] - screenSize[1] * 0.25, 0>, <screenSize[0] * 0.3, 0, 0>, <0, screenSize[0] * 0.3 / 16.0 * 9.0, 0>, false )

	float horzMultiplier = 9.0 / 16.0
    var rui = RuiCreate( $"ui/basic_image.rpak", bgTopo, RUI_DRAW_HUD, -5)

    RuiSetFloat3( rui, "basicImageColor", <0.0, 0.0, 0.0>   )
	RuiSetFloat( rui, "basicImageAlpha", 0.9)

	{
	
		rui = RuiCreate( RUI_TEXT_LEFT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <0.02 * horzMultiplier, -0.2, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "R-97" )
		RuiSetFloat( rui, "msgFontSize", 150.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.5 )
		file.weaponNameRui = rui

		rui = RuiCreate( RUI_TEXT_RIGHT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <1.0 - 0.02 * horzMultiplier, -0.15, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "15" )
		RuiSetFloat( rui, "msgFontSize", 150.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", 0 )
		file.weaponLevelRui = rui
	
		rui = RuiCreate( RUI_TEXT_RIGHT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <1.0 - 0.02 * horzMultiplier, -0.2, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "DAMAGE" )
		RuiSetFloat( rui, "msgFontSize", 90.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		file.weaponLevelLabelRui = rui
        
		rui = RuiCreate( RUI_TEXT_RIGHT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <1.0 - 0.45 * horzMultiplier, -0.15, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "4.0" )
		RuiSetFloat( rui, "msgFontSize", 150.0 )
		RuiSetFloat( rui, "msgAlpha", 1.0 )
		RuiSetFloat( rui, "thicken", 0 )
		file.weaponFireRateRui = rui
	
		rui = RuiCreate( RUI_TEXT_RIGHT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <1.0 - 0.45 * horzMultiplier, -0.2, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "FIRE RATE" )
		RuiSetFloat( rui, "msgFontSize", 90.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.0 )
		file.weaponFireRateLabelRui = rui
	}

	file.weaponModTopo = topo
    file.weaponBGTopo = bgTopo
	thread TrackWeaponPos( topo, bgTopo )
}

void function TrackWeaponPos( var topo, var bgTopo )
{
	while (true)
	{
		WaitFrame()
		if (!IsValid(file.focusedEnt) || !file.shouldShowFlyout)
		{
			RuiTopology_UpdatePos( topo, <screenSize[0], screenSize[1], 0>, 
            	<screenSize[0] * 0.2, 0, 0>, <0, screenSize[0] * 0.2 / 16.0 * 9.0, 0>)
			RuiTopology_UpdatePos( bgTopo, <screenSize[0], screenSize[1], 0>, 
           		<screenSize[0] * 0.2, 0, 0>, <0, screenSize[0] * 0.2 / 16.0 * 9.0, 0>)

			foreach (var rui in file.modNameRuis)
				RuiDestroy(rui)
			   
			file.modNameRuis.clear()
	
			continue
		}
		float bgTopoSize = float(file.modCount) / 5.0
		float vertOffset = screenSize[0] * 0.2 / 16.0 * 9.0
		vector pos = <50, screenSize[1] - 50, 0>
		
		float scale = 1.2
		RuiTopology_UpdatePos( topo, pos - <0, vertOffset, 0> * bgTopoSize, 
            <screenSize[0] * 0.2, 0, 0>, <0, vertOffset, 0>)
		RuiTopology_UpdatePos( bgTopo, pos - <0, vertOffset * bgTopoSize + vertOffset * 0.2, 0>, 
            <screenSize[0] * 0.2, 0, 0>, <0, vertOffset * bgTopoSize + vertOffset * 0.2, 0> )
	}
}

void function DisplayWeapon( entity weapon )
{
    file.focusedEnt = weapon
    file.shouldShowFlyout = true

    array<string> initMods = weapon.GetMods()
    array<string> mods
	foreach (string m in initMods)
	{
		if (ShopPrices_IsModRegistered(m))
		{
			mods.append(m)
			if (ShopData_GetModValue(m) == MODVALUE_PRESET)
			{
				mods = [ m ]
				break
			}
		}
		else 
		{
			if (!file.unregisteredMods.contains(m))
				file.unregisteredMods.append(m)
		}
	}
	file.modCount = mods.len()
	
	while (mods.len() > file.modNameRuis.len())
	{
		float horzMultiplier = 09.0 / 16.0
		var topo = file.weaponModTopo
		float offset = 0.2 * file.modNameRuis.len()
		var rui = RuiCreate( RUI_TEXT_LEFT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <0.02 * horzMultiplier, offset + 0.015, 0> )
		RuiSetFloat3( rui, "msgColor", <0.3, 0.3, 0.3> )
		RuiSetString( rui, "msgText", "Light Mag" )
		RuiSetFloat( rui, "msgFontSize", 90.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken",2 )
		file.modNameRuis.append(rui)
	
		/*rui = RuiCreate( RUI_TEXT_LEFT, topo, RUI_DRAW_HUD, -4 )
		RuiSetInt( rui, "maxLines", 1 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <0.02 * horzMultiplier, offset + 0.115, 0> )
		RuiSetFloat3( rui, "msgColor", <0.5, 0.5, 0.5> )
		RuiSetString( rui, "msgText", "+5%% movement speed, -20%% mag size" )
		RuiSetFloat( rui, "msgFontSize", 80.0 )
		RuiSetFloat( rui, "msgAlpha", 0.9 )
		RuiSetFloat( rui, "thicken", 0.5 )
		file.modDescRuis.append(rui)*/
	}


	if (!weapon.IsWeaponOffhand())
	{
		RuiSetString( file.weaponLevelRui, "msgText", AbbreviateNumber(ScaleDamageWithWeaponLevel(weapon)) )
		RuiSetString( file.weaponLevelLabelRui, "msgText", "DAMAGE" )
		RuiSetString( file.weaponFireRateLabelRui, "msgText", "FIRE RATE" )
		RuiSetString( file.weaponFireRateRui, "msgText", format("%.1f", weapon.GetWeaponSettingFloat(eWeaponVar.fire_rate)) )
	}
	else
	{
		RuiSetString( file.weaponFireRateLabelRui, "msgText", "" )
		RuiSetString( file.weaponFireRateRui, "msgText", "" )
		if (weapon.GetWeaponClassName() != "mp_ability_grapple")
		{
			try
			{
				RuiSetString( file.weaponLevelRui, "msgText", string(weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) / weapon.GetWeaponSettingInt( eWeaponVar.ammo_min_to_fire ))   )
			}
			catch (ex)
			{
				RuiSetString( file.weaponLevelRui, "msgText", "--" )
			}
			RuiSetString( file.weaponLevelLabelRui, "msgText", "CHARGES" )
		}
		else
		{
			try
			{
				RuiSetString( file.weaponLevelRui, "msgText", string(100 / int(weapon.GetWeaponSettingFloat(eWeaponVar.grapple_power_required))))
			}
			catch (ex)
			{
				RuiSetString( file.weaponLevelRui, "msgText", "--" )
			}
			RuiSetString( file.weaponLevelLabelRui, "msgText", "CHARGES" )
		}
	}
	RuiSetString( file.weaponNameRui, "msgText", GetWeaponInfoFileKeyField_GlobalString(weapon.GetWeaponClassName(), "shortprintname") )

	for (int i = 0; i < file.modNameRuis.len(); i++)
	{
		var nameRui = file.modNameRuis[i]
		//var descRui = file.modDescRuis[i]

		if (i >= mods.len())
		{
			RuiSetString( nameRui, "msgText", "" )
			//RuiSetString( descRui, "msgText", "" )
		}
		else
		{
			string m = mods[i]
			string desc = ShopData_GetModDesc(m)
			if (desc.find("\n") == null)
				desc = "\n" + desc
			RuiSetString( nameRui, "msgText", ShopData_GetModName(m) + ": `1" + desc )
			//RuiSetString( descRui, "msgText",  )
			RuiSetFloat3( nameRui, "msgColor", colors[ShopData_GetModValue(m)] )
		}
	}
}

void function StopDisplay()
{
    file.shouldShowFlyout = false
	file.focusedEnt = null
}

void function PauseDisplay()
{
    file.shouldShowFlyout = false
}

void function ResumeDisplay()
{
	file.shouldShowFlyout = true
}

string function GetArrayString( array<string> mods )
{
	string s = ""
	for (int i = 0; i < mods.len(); i++) {
		s += mods[i]
		if (i < mods.len() - 1) s += ", "
	}
	return s
}

float function ScaleDamageWithWeaponLevel( entity ent )
{
    float damageScale = 1 + 0.2 * max(-4, roguelikeLevel)

	return damageScale * ent.GetWeaponSettingInt( eWeaponVar.damage_near_value )
}

string function AbbreviateNumber( float num )
{
	float abs = fabs(num)
	if (abs < 1000)
		return format( "%.1f", num ) // 999.9
	else if (abs < 100000)
		return format( "%.1fK", num / 1000.0 ) // 99.9K
	else if (abs < 1000000)
		return format( "%.0fK", num / 1000.0 ) // 999K
	else if (abs < 100000000)
		return format( "%.1fM", num / 1000000.0 ) // 99.9M
	else if (abs < 1000000000)
		return format( "%.0fM", num / 1000000.0 ) // 999M
	else if (abs < 100000000000)
		return format( "%.1fB", num / 1000000000.0 ) // 99.9B
	
	return format( "%.1fB", num / 1000000.0 ) // 999B
}