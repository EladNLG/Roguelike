global function EmergencySoda_Init

void function EmergencySoda_Init()
{
    AddCallback_OnDamageEvent( OnDamageEvent )
}

const float TITAN_TOP_HAT_RADIUS = 700
const float PILOT_TOP_HAT_RADIUS = 150

void function OnDamageEvent( entity ent, var damageInfo )
{
    int sodaStacks = Roguelike_GetItemCount( ent, "emergency_soda" )
    int damageType = DamageInfo_GetCustomDamageType( damageInfo )
    bool isHeadShot = (damageType & DF_HEADSHOT) ? true : false

    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity projectile = DamageInfo_GetInflictor( damageInfo )

    if (ent.IsPlayer())
    {
        int scavStacks = Roguelike_GetItemCount( ent, "blood_scavenger" )
        AddMoney( ent, int(scavStacks * DamageInfo_GetDamage( damageInfo ) * 0.25) )
    }

    if (!IsValid(weapon) && IsValid(attacker) && IsValid(projectile) && projectile.IsProjectile() && (attacker.IsNPC() || attacker.IsPlayer()))
    {
        array<entity> weapons = attacker.GetMainWeapons()
        weapons.extend( attacker.GetOffhandWeapons() )
        string className = projectile.ProjectileGetWeaponClassName()

        int damageType = DamageInfo_GetCustomDamageType( damageInfo )
        if (damageType & DF_VORTEX_REFIRE) className = "mp_titanweapon_vortex_shield"

        foreach ( w in weapons )
        {
            if ( w.GetWeaponClassName() == className || w.GetWeaponClassName() == className + "_ion" )
                { weapon = w; break }
        }

    }

    if (IsValid(weapon))
    {
        int ammo = weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) <= 0 ? weapon.GetWeaponPrimaryAmmoCount() : weapon.GetWeaponPrimaryClipCount()
        //thread ResetAttackTime( weapon )
        if (isHeadShot && Roguelike_RollForChanceFunc(Roguelike_LinearChanceFunc( 15, 15 ), Roguelike_GetItemCount( attacker, "send_back_rounds" )))
        {
            if (weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size ) <= 0) 
            weapon.SetWeaponPrimaryAmmoCount( min( weapon.GetWeaponSettingInt( eWeaponVar.ammo_stockpile_max ), ammo + 1 ) )
            else weapon.SetWeaponPrimaryClipCount( min( weapon.GetWeaponPrimaryClipCountMax(), ammo + 1 ) )
        }
        if (weapon.GetWeaponPrimaryClipCount() <= 1)
        {
            int goldenShells = Roguelike_GetItemCount( attacker, "golden_shell" )

            try
            {
                DamageInfo_ScaleDamage( damageInfo, 1.0 + goldenShells * 0.15 )
            }
            catch (ex)
            {
                DamageInfo_SetDamage( damageInfo, 524287 )
            }
        }
    }
    
    //if (DamageInfo_GetForceKill(damageInfo)) return

    if (sodaStacks > 0 && !ent.IsTitan())
    {
        if (DamageInfo_GetDamage(damageInfo) > ent.GetHealth())
        {
            DamageInfo_SetDamage( damageInfo, 1 )
            ent.SetHealth(ent.GetMaxHealth())
            Roguelike_GiveEntityItem( ent, "emergency_soda", -1 )
            if (!ent.IsPlayer()) {
                Chat_ServerBroadcast( format(
                    "\x1b[38;2;150;150;150mUsed their %s%s\x1b[38;2;150;150;150m to save their life (%i remaining)", 
                    ColorToEscapeCode(Roguelike_GetRarityChatColor(RARITY_LEGENDARY)), Roguelike_GetItemName( "emergency_soda" ), Roguelike_GetItemCount(ent, "emergency_soda")) )
            }
            else Chat_Impersonate( ent, format(
            "\x1b[38;2;150;150;150mUsed their %s%s\x1b[38;2;150;150;150m to save their life (%i remaining)", 
            ColorToEscapeCode(Roguelike_GetRarityChatColor(RARITY_LEGENDARY)), Roguelike_GetItemName( "emergency_soda" ), Roguelike_GetItemCount(ent, "emergency_soda")), false )
        }
    }

    if (!attacker.IsTitan() && ent.IsTitan())
    {
        try
        {
            DamageInfo_ScaleDamage( damageInfo, 1.0 + 0.2 * Roguelike_GetItemCount( attacker, "cockroach" ) )
        }
        catch (ex)
        {
            DamageInfo_SetDamage( damageInfo, 524287 )
        }
    }

    switch (ent.GetTitle())
    {
        case "#BOSSNAME_ASH":
        case "#BOSSNAME_RICHTER":
        case "#BOSSNAME_SLONE":
        case "#BOSSNAME_BLISK":
        case "#BOSSNAME_KANE":
        case "#BOSSNAME_VIPER":
            try
            {
                DamageInfo_ScaleDamage( damageInfo, 1.0 + 0.2 * Roguelike_GetItemCount( attacker, "unionizer" ) )
            }
            catch (ex)
            {        
                DamageInfo_SetDamage( damageInfo, 524287 )
            }
            break
    }

    int hatStacks = Roguelike_GetItemCount( attacker, "ukulele" )
    if (hatStacks > 0 && RandomFloat(1) < 0.2)
    {
        float outerRadius = attacker.IsTitan() ? TITAN_TOP_HAT_RADIUS : PILOT_TOP_HAT_RADIUS
        outerRadius *= 1.0 + 0.1 * (hatStacks - 1)
        float innerRadius = outerRadius * 1
        RadiusDamage(
			ent.GetOrigin(),															// center
			attacker,							
            						// attacker
			DamageInfo_GetInflictor( damageInfo ),													// inflictor
			DamageInfo_GetDamage( damageInfo ) * 0.8,																// damage
			DamageInfo_GetDamage( damageInfo ) * 0.8,																// damageHeavyArmor
			innerRadius,											// innerRadius
			outerRadius,											// outerRadius
			SF_ENVEXPLOSION_MASK_BRUSHONLY,	// flags
			0.0,																	// distanceFromAttacker
			0.0,																	// explosionForce
			DF_NO_SELF_DAMAGE | DF_ELECTRICAL,											// scriptDamageFlags
			eDamageSourceId.invalid )												// scriptDamageSourceIdentifier
    }
}

void function ResetAttackTime( entity weapon )
{
    float dur = Time() + 1.0
    while (Time() < dur)
    {
        weapon.SetNextAttackAllowedTime( Time() + 0.01 )
        WaitFrame()
    }
}