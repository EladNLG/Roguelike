global function EmergencySoda_Init

void function EmergencySoda_Init()
{
    AddCallback_OnDamageEvent( OnDamageEvent )
}

void function OnDamageEvent( entity ent, var damageInfo )
{
    int sodaStacks = Roguelike_GetItemCount( ent, "emergency_soda" )
    int damageType = DamageInfo_GetCustomDamageType( damageInfo )
    bool isHeadShot = (damageType & DF_HEADSHOT) ? true : false

    entity attacker = DamageInfo_GetAttacker( damageInfo )
    entity weapon = DamageInfo_GetWeapon( damageInfo )
    entity projectile = DamageInfo_GetInflictor( damageInfo )
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
    if (isHeadShot && IsValid(weapon))
    {
        if (Roguelike_RollForChanceFunc(Roguelike_LinearChanceFunc( 15, 15 ), Roguelike_GetItemCount( attacker, "send_back_rounds" )))
        {
            weapon.SetWeaponPrimaryClipCount( min( weapon.GetWeaponPrimaryClipCountMax(), weapon.GetWeaponPrimaryClipCount() + 1 ) )
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
            if (!ent.IsPlayer()) return
            Chat_Impersonate( ent, format(
            "\x1b[38;2;150;150;150mUsed their %s%s\x1b[38;2;150;150;150m to save their life (%i remaining)", 
            ColorToEscapeCode(roguelikeChatRarityColors[RARITY_LEGENDARY]), Roguelike_GetItemName( "emergency_soda" ), Roguelike_GetItemCount(ent, "emergency_soda")), false )
        }
    }
}

string function ColorToEscapeCode( vector color )
{
    return "\x1b[38;2;" + int(color.x * 255) + ";" + int(color.y * 255) + ";" + int(color.z * 255) + "m"
}