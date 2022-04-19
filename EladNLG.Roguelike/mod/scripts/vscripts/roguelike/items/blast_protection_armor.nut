global function BlastProtection_Init

void function BlastProtection_Init()
{
    AddCallback_OnDamageEvent( OnDamageEvent )
}

void function OnDamageEvent( entity victim, var damageInfo )
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