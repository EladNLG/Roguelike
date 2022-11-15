global function AmmoPack_Init

void function AmmoPack_Init()
{
    AddCallback_OnNPCKilled( AmmoPack_OnNPCKilled )
    AddCallback_OnPlayerKilled( AmmoPack_OnNPCKilled )
}

void function AmmoPack_OnNPCKilled( entity npc, entity attacker, var damageInfo )
{
    //print("npc killed, rolling ammo pack")
    
    //int healStacks = Roguelike_GetItemCount( attacker, "heal_on_kill" )
    //if (IsAlive(attacker) && healStacks > 0)
    //{
    //    attacker.SetHealth(int(min(attacker.GetHealth() + 0.02 * attacker.GetMaxHealth() * healStacks, attacker.GetMaxHealth())))
    //}

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
    int roll = Roguelike_RollStackingForChanceFunc(Roguelike_LinearChanceFunc(20, 20, 300), stacks)
    for (int i = 0; i < roll && i < 3; i++)
    {
        if (weapon.GetWeaponSettingInt( eWeaponVar.ammo_stockpile_max ) > 0)
            weapon.SetWeaponPrimaryAmmoCount( minint( weapon.GetWeaponPrimaryAmmoCount() + maxint( weapon.GetWeaponPrimaryClipCountMax() / 5, 1 ),
                weapon.GetWeaponSettingInt( eWeaponVar.ammo_stockpile_max ) ) )
    }
        
}