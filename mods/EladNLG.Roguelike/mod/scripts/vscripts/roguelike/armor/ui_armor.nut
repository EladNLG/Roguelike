global function UpdateArmor

void function UpdateArmor( string strData )
{
    ArmorData data = StringToArmorData( strData )
    
    entity player = GetLocalClientPlayer()
    Roguelike_GiveEntityArmor( player, data )
}