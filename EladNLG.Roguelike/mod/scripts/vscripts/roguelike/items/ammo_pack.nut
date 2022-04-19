global function AmmoPack_Init

void function AmmoPack_Init()
{
    AddCallback_OnNPCKilled( AmmoPack_OnNPCKilled )
    AddCallback_OnPlayerKilled( AmmoPack_OnNPCKilled )
}

void function AmmoPack_OnNPCKilled( entity npc, entity attacker, var damageInfo )
{
    //print("npc killed, rolling ammo pack")
    if (!attacker.IsPlayer()) return

    entity weapon = DamageInfo_GetWeapon( damageInfo )
    //print(weapon)
    if (!IsValid(weapon)) 
    {
        entity projectile = DamageInfo_GetInflictor( damageInfo )
        if (!IsValid(projectile)) return
        if (!projectile.IsProjectile()) return

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
    if (!IsValid(weapon))
    {
        print("no weapon found")
        return
    }
    //print(weapon)

    // frags get this bonus too :)
    //if (weapon.IsWeaponOffhand()) return
    int stacks = Roguelike_GetItemCount( attacker, "ammo_pack" )
    int roll = Roguelike_RollStackingForChanceFunc(Roguelike_LinearChanceFunc(15, 15, 300), stacks)
    for (int i = 0; i < roll && i < 3; i++)
    {
        if (weapon.GetWeaponPrimaryClipCountMax() > 0)
            weapon.SetWeaponPrimaryClipCount( min( weapon.GetWeaponPrimaryClipCount() + max( weapon.GetWeaponPrimaryClipCountMax() / 10, 1 ),
                weapon.GetWeaponPrimaryClipCountMax() ) )
        else weapon.SetWeaponChargeFractionForced( max( 0, weapon.GetWeaponChargeFraction() - 0.1 ) )
    }
        
}