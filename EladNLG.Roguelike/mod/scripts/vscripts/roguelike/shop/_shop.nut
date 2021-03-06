untyped

globalize_all_functions

void function _Shop_Init()
{
    AddClientCommandCallback( "buyammo", CC_BuyAmmo )
    AddCallback_OnNPCKilled( OnNPCKilled_AddMoney )
    AddCallback_EntitiesDidLoad( AAAAAAAAEntitiesDidLoad )
}
void function AAAAAAAAEntitiesDidLoad()
{
    if (GetMapName() != "sp_s2s") return
	array<entity> pods = GetEntArrayByScriptName( "lifeboats_pods" )
    Highlight_SetNeutralHighlight( pods[0], "roguelike_chest" )
}

int function ScaleRewardWithDifficulty( int reward )
{
    print( "ScaleRewardWithDifficulty: " + pow(1.1, roguelikeDifficulty) )
    return int( reward * pow(1.1, roguelikeDifficulty) )
}

void function OnNPCKilled_AddMoney( entity npc, entity attacker, var damageInfo )
{
    if ( attacker.IsPlayer() ) 
    {
        switch (npc.GetClassName())
        {
            case "npc_drone":
            case "npc_soldier":
                if (GetMapName() == "sp_training")
                    AddMoney( attacker, ScaleRewardWithDifficulty(40) )
                AddMoney( attacker, ScaleRewardWithDifficulty(15) );
                AddXP( 30 )
                break
            case "npc_marvin":
            case "npc_titan":
                AddMoney( attacker, ScaleRewardWithDifficulty(75) );
                AddXP( 150 )
                break
            case "npc_spectre":
                AddMoney( attacker, ScaleRewardWithDifficulty(20) );
                AddXP( 40 )
                break
            case "npc_super_spectre":
                AddMoney( attacker, ScaleRewardWithDifficulty(50) );
                AddXP( 100 )
                break
            case "npc_turret_mega":
            case "npc_turret_sentry":
            case "npc_stalker":
                AddMoney( attacker, ScaleRewardWithDifficulty(35) );
                AddXP( 70 )
                break
            case "npc_prowler":
                AddMoney( attacker, ScaleRewardWithDifficulty(15) );
                AddXP( 25 )
                break
            case "npc_frag_drone":
                AddMoney( attacker, ScaleRewardWithDifficulty(5) );
                AddXP( 10 )
                break
        }
    }
}

void function AddMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        int curMoney = player.GetPlayerNetInt( "roguelikeCash" )
        curMoney += amount
        int cashStacks = player.GetPlayerNetInt( "roguelikeCashStacks" )
        int cashStacksStacks = player.GetPlayerNetInt( "roguelikeCashStacksStacks" )
        while (curMoney > 1023)
        {
            curMoney -= 1024
            cashStacks++
            while (cashStacks > 1023)
            {
                cashStacks -= 1024
                cashStacksStacks++
            }
            while (cashStacks < 0)
            {
                cashStacks += 1024
                cashStacksStacks--
            }
        }
        while (curMoney < 0)
        {
            curMoney += 1024
            cashStacks--
            while (cashStacks > 1023)
            {
                cashStacks -= 1024
                cashStacksStacks++
            }
            while (cashStacks < 0)
            {
                cashStacks += 1024
                cashStacksStacks--
            }
        }
        player.SetPlayerNetInt( "roguelikeCashStacks", cashStacks )
        player.SetPlayerNetInt( "roguelikeCashStacksStacks", cashStacksStacks )
        player.SetPlayerNetInt( "roguelikeCash", curMoney );
    }
}

void function RemoveMoney( entity player, int amount )
{
    if ( player.IsPlayer() )
    {
        int curMoney = player.GetPlayerNetInt( "roguelikeCash" )
        curMoney -= amount
        int cashStacks = player.GetPlayerNetInt( "roguelikeCashStacks" )
        int cashStacksStacks = player.GetPlayerNetInt( "roguelikeCashStacksStacks" )
        while (curMoney > 1023)
        {
            curMoney -= 1024
            cashStacks++
            while (cashStacks > 1023)
            {
                cashStacks -= 1024
                cashStacksStacks++
            }
            while (cashStacks < 0)
            {
                cashStacks += 1024
                cashStacksStacks--
            }
        }
        while (curMoney < 0)
        {
            curMoney += 1024
            cashStacks--
            while (cashStacks > 1023)
            {
                cashStacks -= 1024
                cashStacksStacks++
            }
            while (cashStacks < 0)
            {
                cashStacks += 1024
                cashStacksStacks--
            }
        }
        player.SetPlayerNetInt( "roguelikeCashStacks", cashStacks )
        player.SetPlayerNetInt( "roguelikeCashStacksStacks", cashStacksStacks )
        player.SetPlayerNetInt( "roguelikeCash", curMoney );
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