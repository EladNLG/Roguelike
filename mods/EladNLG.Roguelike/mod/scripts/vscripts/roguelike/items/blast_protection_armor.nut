untyped

global function BlastProtection_Init

void function BlastProtection_Init()
{
    AddCallback_OnDamageEvent( BlastProc_OnDamageEvent )
    AddCallback_OnDamageEvent( Scorch_OnDamageEvent )
}

void function BlastProc_OnDamageEvent( entity victim, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    entity weapon = DamageInfo_GetWeapon( damageInfo )
    bool isExplosive = false
    if (!IsValid(weapon))
    {
        entity projectile = DamageInfo_GetInflictor( damageInfo )
        if (IsValid(projectile) && projectile.IsProjectile() && projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius ) > 0)
        {
            isExplosive = true
        }
    }
    else 
    {
        isExplosive = weapon.GetWeaponSettingFloat( eWeaponVar.explosionradius ) > 0
    }

    if (DamageInfo_GetCustomDamageType( damageInfo ) & DF_EXPLOSION || isExplosive)
    {
        //print("REDUCING EXPLOSIVE DAMAGE")
        int blastProcStacks = Roguelike_GetItemCount( victim, "blast_proc" )
        float damageReduction = Roguelike_HyperbolicChanceFunc( 8 )(blastProcStacks)

        DamageInfo_ScaleDamage( damageInfo, 1 - (damageReduction / 100) )
    }

    
}

void function Scorch_OnDamageEvent( entity victim, var damageInfo )
{
    entity attacker = DamageInfo_GetAttacker( damageInfo )

    int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )

    if (!("thermiteCount" in victim.s))
        victim.s.thermiteCount <- 0
    float duration = 0.1
    int offset = 0
    switch (damageSourceId)
    {
		case eDamageSourceId.mp_titanweapon_heat_shield:
        case eDamageSourceId.mp_titanweapon_meteor:
		case eDamageSourceId.mp_weapon_thermite_grenade:
            break
		case eDamageSourceId.mp_titancore_flame_wave:
            duration = 2.5
            break
		case eDamageSourceId.mp_titancore_flame_wave_secondary:
		case eDamageSourceId.mp_titanweapon_flame_wall:
		case eDamageSourceId.mp_titanability_slow_trap:
		case eDamageSourceId.mp_titanweapon_meteor_thermite:
            offset = 1
            break

        default:
            return
    }
    try
    {
        DamageInfo_ScaleDamage( damageInfo, 1 + 0.2 * (Roguelike_GetItemCount( attacker, "sticky_thermite" ) - offset) * expect int( victim.s.thermiteCount ) )
    }
    catch (ex)
    {
        DamageInfo_SetDamage( damageInfo, 524287 )
    }
    thread AddThermiteInstance( victim, duration )
}

void function AddThermiteInstance(entity victim, float duration)
{
    victim.s.thermiteCount++

    wait duration

    victim.s.thermiteCount--
}