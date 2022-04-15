untyped

globalize_all_functions

void function _Shop_Init()
{
    AddClientCommandCallback( "buyammo", CC_BuyAmmo )
    AddCallback_OnNPCKilled( OnNPCKilled_AddMoney )
}

void function OnNPCKilled_AddMoney( entity npc, entity attacker, var damageInfo )
{
    if ( attacker.IsPlayer() ) 
    {
        switch (npc.GetClassName())
        {
            case "npc_drone":
            case "npc_soldier":
                AddMoney( attacker, 10 );
                break
            case "npc_marvin":
            case "npc_titan":
                AddMoney( attacker, 50 );
                break
            case "npc_spectre":
                AddMoney( attacker, 15 );
                break
            case "npc_super_spectre":
                AddMoney( attacker, 20 );
                break
            case "npc_turret_mega":
            case "npc_turret_sentry":
            case "npc_stalker":
                AddMoney( attacker, 25 );
                break
            case "npc_prowler":
                AddMoney( attacker, 15 );
                break
            case "npc_frag_drone":
                AddMoney( attacker, 5 );
                break
        }
    }
}

void function AddMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        player.SetPlayerNetInt( "roguelikeCash", int(max(player.GetPlayerNetInt( "roguelikeCash" ) + amount, 0)) );
    }
}

void function RemoveMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        player.SetPlayerNetInt( "roguelikeCash", int(max(player.GetPlayerNetInt( "roguelikeCash" ) - amount, 0)) );
    }
}

bool function CC_BuyAmmo( entity player, array<string> args)
{
    if( args.len() != 1 )
    {
        return true
    }
    switch (args[0])
    {
        case "0":
            entity weapon = player.GetMainWeapons()[0]
            if (weapon.GetLifetimeShotsRemaining() != -1)
            {
                weapon.SetLifetimeShotsRemaining(weapon.GetWeaponSettingInt(eWeaponVar.lifetime_shots_default))
            }
            else
            {
                weapon.SetWeaponPrimaryAmmoCount(weapon.GetWeaponSettingInt(eWeaponVar.ammo_stockpile_max))
            }
            break;
        case "1":
            entity weapon = player.GetMainWeapons()[1]
            if (weapon.GetLifetimeShotsRemaining() != -1)
            {
                weapon.SetLifetimeShotsRemaining(weapon.GetWeaponSettingInt(eWeaponVar.lifetime_shots_default))
            }
            else
            {
                weapon.SetWeaponPrimaryAmmoCount(weapon.GetWeaponSettingInt(eWeaponVar.ammo_stockpile_max))
            }
            break;
    }
    return true
}