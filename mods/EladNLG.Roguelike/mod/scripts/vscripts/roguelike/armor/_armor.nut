untyped
global function SpawnArmor
global function PickupArmor
global function _Armor_Init

struct {
    table< entity, array<float> > cooldownTimes
} file

const asset ARMOR_MODEL = $"models/humans/heroes/mlt_hero_jack_helmet_static.mdl"
const asset CHEST_INTERACTABLE_MODEL_OPEN = $"models/containers/pelican_case_large_open.mdl"

void function _Armor_Init()
{
    PrecacheModel( ARMOR_MODEL )
    AddClientCommandCallback( "SpawnArmor", CC_SpawnArmor )
    AddCallback_OnClientConnected( UpdateArmor )

    thread UpdateCooldownsThread()
}

void function UpdateArmor( entity player )
{
    array<string> armorDataStr = split( player.GetUserInfoString( "player_armor" ), "{" )
    foreach (int index, string str in armorDataStr)
    {
        Roguelike_GiveEntityArmor( player, StringToArmorData(str) )
    }
}

void function UpdateCooldownsThread()
{
    while (true)
    {
        foreach ( entity player in GetPlayerArray() )
        {
            if (!(player in file.cooldownTimes))
                file.cooldownTimes[player] <- [0.0,0.0,0.0]
            UpdateCooldowns( player )
        }
        wait 0.09
    }
}

function SpawnArmor( var chest, var player )
{
    expect entity( player )
    expect entity( chest )
    float multiplier = ARMOR_CHEST_MULTIPLIER
    print(GetChestCost(multiplier))
    print(GetMoney( player ))
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
    
    string crarity = RARITY_LEGENDARYARMOR
    string rrarity = RARITY_EXOTIC
    switch (levelCount)
    {
        case 0:
            crarity = RARITY_COMMON
            rrarity = RARITY_UNCOMMON
            break
        case 1:
            crarity = RARITY_UNCOMMON
            rrarity = RARITY_RARE
            break
        case 2:
            crarity = RARITY_RARE
            rrarity = RARITY_LEGENDARYARMOR
    }

    ArmorData data = Armor_Create( "HELMET", xorshift_range_int(0, 5, GetRoguelikeSeed() + 3) == 0 ? rrarity : crarity )
    CreateArmor( data, chest.GetOrigin() + <0, 0, 30>, chest.GetAngles() + < -30, 90, 0> ).SetParent(chest)

    // nobody stays in an area for more than 2 minutes... right?
    thread DestroyAfterDelay(chest, 120)
}

function PickupArmor( armor, player )
{
    expect entity( player )
    expect entity( armor )

    ArmorData prev = Roguelike_GiveEntityArmor(player, StringToArmorData(expect string( armor.s.armor ) ) )

    CreateArmor( prev, armor.GetOrigin(), armor.GetAngles() )

    armor.Destroy()
}

entity function CreateArmor( ArmorData data, vector origin, vector angles )
{
    entity prop_dynamic = CreateEntity( "prop_dynamic" )
	prop_dynamic.SetValueForModelKey( ARMOR_MODEL )
	prop_dynamic.kv.fadedist = 2000
	prop_dynamic.kv.renderamt = 255
	prop_dynamic.kv.rendercolor = "255 255 255"
	prop_dynamic.kv.solid = 6

    DispatchSpawn(prop_dynamic)

    prop_dynamic.SetOrigin( origin )
    prop_dynamic.SetAngles( angles )

    prop_dynamic.s.armor <- ArmorDataToString(data)
    prop_dynamic.SetScriptName( "armor_" + ArmorDataToString(data) )

	prop_dynamic.SetUsable()
	//prop_dynamic.SetUsableByGroup( "pilot" )
    //prop_dynamic.SetUsePrompts( "Hold %use% to pick up " + Roguelike_GetItemName( item ), "Press %use% to pick up " + Roguelike_GetItemName( item ) )

    AddCallback_OnUseEntity( prop_dynamic, PickupArmor )
    foreach (entity player in GetPlayerArray())
    {
        Roguelike_SyncPlayer( player )
    }

    SetOutline( prop_dynamic, Roguelike_GetRarityColor( data.rarity ), 6.5 )

    // doesn't cause pop-up to be removed, also can be fustrating
    //thread DestroyAfterDelay(prop_dynamic, 30)

    return prop_dynamic
}

void function SetOutline( entity ent, vector color, float radius )
{
    Highlight_SetNeutralHighlight( ent, "roguelike_item" )
    ent.Highlight_SetParam( 0, 0, color )
    //ent.Highlight_SetNearFadeDist(700)
    //ent.Highlight_SetFarFadeDist(1000)
	//ent.Highlight_SetFlag( HIGHLIGHT_FLAG_ADS_FADE, highlight.adsFade )
}

int a = 0
bool function CC_SpawnArmor( entity player, array<string> args )
{
    if (!GetConVarBool("sv_cheats"))
        return false

    string crarity = RARITY_LEGENDARYARMOR
    string rrarity = RARITY_EXOTIC
    switch (levelCount)
    {
        case 0:
            crarity = RARITY_COMMON
            rrarity = RARITY_UNCOMMON
            break
        case 1:
            crarity = RARITY_UNCOMMON
            rrarity = RARITY_RARE
            break
        case 2:
            crarity = RARITY_RARE
            rrarity = RARITY_LEGENDARYARMOR
    }

    ArmorData data = Armor_Create( "HELMET", xorshift_range_int(0, 5, GetRoguelikeSeed() + 3) == 0 ? rrarity : crarity )
    CreateArmor( data, player.GetOrigin(), <0, player.GetAngles().y, 0> )
    return true
}


void function UpdateCooldowns( entity player )
{
    array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_TITAN_CENTER, OFFHAND_RIGHT ]
    foreach ( index in offhandIndices )
	{
		float lastUseTime = player.p.lastPilotOffhandUseTime[ index ]
		float lastChargeFrac = player.p.lastPilotOffhandChargeFrac[ index ]

		if ( lastUseTime >= 0.0 )
		{
			entity weapon = player.GetOffhandWeapon( index )
            if (!IsValid( weapon ))
                return
            int curAmmo = weapon.GetWeaponPrimaryClipCount()
			if ( !IsValid( weapon ) )
				continue

			string weaponClassName = weapon.GetWeaponClassName()

			switch ( GetWeaponInfoFileKeyField_Global( weaponClassName, "cooldown_type" ) )
			{
				case "grapple":
					// GetPlayerSettingsField isn't working for moddable fields? - Bug 129567
					float powerRequired = 100.0 // GetPlayerSettingsField( "grapple_power_required" )
					float regenRefillDelay = 3.0 // GetPlayerSettingsField( "grapple_power_regen_delay" )
					float regenRefillRate = 5.0 * 0.01 * Roguelike_GetEntityStat( player, "intelligence" ) // GetPlayerSettingsField( "grapple_power_regen_rate" )
					float suitPowerToRestore = powerRequired - player.p.lastSuitPower
					float regenRefillTime = suitPowerToRestore / regenRefillRate

					float regenStartTime = lastUseTime + regenRefillDelay

                    float newSuitPower = player.GetSuitGrapplePower()
                    if (Time() > regenStartTime)
                    {
                        newSuitPower += regenRefillRate * 0.1
                    }

					player.SetSuitGrapplePower( newSuitPower )
					break

                
				case "ammo":
				case "ammo_instant":
				case "ammo_deployed":
				case "ammo_timed":
					int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
					float fireDuration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
					float regenRefillDelay = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_start_delay )
                    string stat = ""
                    switch (index)
                    {
                        case OFFHAND_LEFT:
                            stat = "intelligence"
                            break
                        case OFFHAND_RIGHT:
                            stat = "strength"
                            break
                        case OFFHAND_TITAN_CENTER:
                            stat = "discipline"
                            break
                    }
					float regenRefillRate = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate ) 
                        * 0.01 * Roguelike_GetEntityStat( player, stat )
					int startingClipCount = curAmmo
					int ammoToRestore = maxAmmo - startingClipCount
					float regenRefillTime = ammoToRestore / regenRefillRate

					float regenStartTime = lastUseTime + fireDuration + regenRefillDelay

					int newAmmo = weapon.GetWeaponPrimaryClipCount()
                    if (Time() > regenStartTime)
                    {
                        file.cooldownTimes[player][index] += 0.1
                        while (file.cooldownTimes[player][index] >= 1.0 / regenRefillRate)
                        {
                            file.cooldownTimes[player][index] -= 1.0 / regenRefillRate
                            newAmmo += 1
                        }
                    }

					weapon.SetWeaponPrimaryClipCountNoRegenReset( minint( weapon.GetWeaponPrimaryClipCountMax(), newAmmo ) )
					break

                case "charged_shot":
				case "chargeFrac":
                    print("fuck")
					float chargeCooldownDelay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
					float chargeCooldownTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_time )
					float regenStartTime = lastUseTime + chargeCooldownDelay

                    string stat = ""
                    switch (index)
                    {
                        case OFFHAND_LEFT:
                            stat = "intelligence"
                            break
                        case OFFHAND_RIGHT:
                            stat = "strength"
                            break
                        case OFFHAND_TITAN_CENTER:
                            stat = "discipline"
                            break
                    }
					float regenRefillTime = weapon.GetWeaponChargeFraction() * chargeCooldownTime
                        * 0.01 * Roguelike_GetEntityStat( player, stat )
                    print(regenRefillTime)

					float newCharge = weapon.GetWeaponChargeFraction()
                    
                    if (Time() > regenStartTime)
                    {
                        newCharge -= (1.0 / chargeCooldownTime) * 0.1
                    }

					weapon.SetWeaponChargeFraction( newCharge )
					break
                default:
					printt( weaponClassName + " needs to be updated to support cooldown_type setting" )
                    break
			}
		}
	}
}