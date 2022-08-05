untyped

globalize_all_functions

global entity weaponDummy
global bool wasWeaponDummySet

global const array<string> allowedWeapons = [
	//ar
	"mp_weapon_rspn101",
	"mp_weapon_rspn101_og",
	"mp_weapon_vinson",
	"mp_weapon_g2",
	"mp_weapon_hemlok",
	// smg
	"mp_weapon_r97",
	"mp_weapon_car",
	"mp_weapon_hemlok_smg",
	"mp_weapon_alternator_smg",
	// lmg
	"mp_weapon_lmg",
	"mp_weapon_lstar",
	"mp_weapon_esaw",
	//sniper
	"mp_weapon_sniper",
	"mp_weapon_doubletake",
	"mp_weapon_dmr",
	//explosive
	"mp_weapon_epg",
	"mp_weapon_pulse_lmg",
	"mp_weapon_softball",
	"mp_weapon_smr",
	// shotguns
	"mp_weapon_shotgun",
	"mp_weapon_mastiff",
	//"mp_weapon_peacekraber",
	// ???
	"mp_weapon_arc_launcher",
	// PISTOL
	"mp_weapon_wingman",
	"mp_weapon_wingman_n",
	"mp_weapon_shotgun_pistol",
	"mp_weapon_semipistol",
	"mp_weapon_autopistol",
	//"mp_weapon_40mm",
	// grenades
	"mp_weapon_frag_grenade",
	"mp_weapon_thermite_grenade",
	"mp_weapon_grenade_gravity",
	"mp_weapon_grenade_emp",
	"mp_weapon_grenade_electric_smoke",
	"mp_weapon_grenade_sonar",
	"mp_weapon_satchel",
	// tacticals :flushed:
	"mp_ability_cloak",
	"mp_ability_heal",
	"mp_ability_shifter",
	"mp_ability_grapple",
	// at
	"mp_weapon_defender"
	//"mp_ability_holopilot",
]

void function PrecacheJack()
{
	//PrecacheWeapon( "mp_weapon_40mm" )
	//PrecacheWeapon( "mp_weapon_lstar_csgo" )
	//PrecacheWeapon( "mp_weapon_rspn101_csgo" )
	foreach ( string weaponName in allowedWeapons )
	{
		//print(weaponName)
		if (!WeaponIsPrecached(weaponName))
			PrecacheWeapon(weaponName);
	}
	
}

#if SP
bool function EntityHasWeapon(entity ent, string weaponName)
{
	if (IsWeaponOffhand(weaponName))
	{
		foreach (entity weapon in ent.GetOffhandWeapons())
			if (weapon.GetWeaponClassName() == weaponName) return true
	}
	else
	{
		foreach (entity weapon in ent.GetMainWeapons())
			if (weapon.GetWeaponClassName() == weaponName) return true
	}
	return false;
}
#endif