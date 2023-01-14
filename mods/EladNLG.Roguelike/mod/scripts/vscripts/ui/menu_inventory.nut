untyped
global function Inventory_Init
global function OpenInventory

struct
{
    var menu
    GridMenuData gridData
    var buttonSelected
    int weaponNum = -1
    var weaponSelected
    int buttonNum = -1
} file
void function Inventory_Init()
{
    AddMenu( "Inventory", $"resource/ui/menus/inventory.menu", InventoryMenuInit, "Inventory" )
}

void function InventoryMenuInit()
{
    file.menu = GetMenu("Inventory")

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnMenuClosed )

    AddMenuFooterOption(file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )
    RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "ButtonPrimary") ), "buttonImage", 
        $"r2_ui/menus/loadout_icons/primary_weapon/primary_wingman_m" )
    RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "ButtonSecondary") ), "buttonImage", 
        $"r2_ui/menus/loadout_icons/primary_weapon/primary_r102" )
    RuiSetImage( Hud_GetRui( Hud_GetChild( file.menu, "StatBG") ), "buttonImage", 
        $"vgui/hud/empty" )

    Hud_SetText( Hud_GetChild( file.menu, "StatInfo" ), @"^2288FF00Pilot ^| ^FFAA0000Titan ^| Both
    
^00FFFF00Mobility^: ^2288FF00Increases your speed ^/ ^FFAA0000Reduces your dash cooldown^.

^FFFF5500Resilience^: ^Increases your base health.

^55FF5500Recovery^: Increases healing from ^2288FF00damage at close range ^/ ^FFAA0000Titan batteries^.

^FFAA7700Strength^: Reduces the cooldown of your ^2288FF00Ordnance ^/ ^FFAA0000Offensive^ ability.

^BB55FF00Intelligence^: Reduces the cooldown of your ^2288FF00Tactical ^/ ^FFAA0000Defensive^ ability.

^FF55FF00Discipline^: Reduces the cooldown of your ^2288FF00Dash ^/ ^FFAA0000Utility^ ability.")

    Hud_AddEventHandler( Hud_GetChild( file.menu, "ButtonPrimary"), UIE_CLICK, void function ( var button ) : () {
        Hud_SetSelected( button, !Hud_IsSelected( button ) )
        if (file.weaponSelected != null)
        {
            Hud_SetSelected( file.weaponSelected, false )
            if (file.weaponSelected == button)
            {
                file.weaponSelected = null
                file.weaponNum = -1
                return
            }
        }
        file.weaponSelected = button
        file.weaponNum = 1
        if (file.buttonSelected != null)
        {
            EmitUISound( "wpn_pickup_Rifle_1P" )
            printt("swap", WeaponNumToSlot(file.weaponNum), file.buttonNum)
            file.weaponNum = -1
            file.buttonNum = -1
            Hud_SetSelected( file.buttonSelected, false )
            file.buttonSelected = null
            Hud_SetSelected( file.weaponSelected, false )
            file.weaponSelected = null
        }
    })
    Hud_AddEventHandler( Hud_GetChild( file.menu, "ButtonSecondary"), UIE_CLICK, void function ( var button ) : () {
        Hud_SetSelected( button, !Hud_IsSelected( button ) )
        if (file.weaponSelected != null)
        {
            Hud_SetSelected( file.weaponSelected, false )
            if (file.weaponSelected == button)
            {
                file.weaponSelected = null
                file.weaponNum = -1
                return
            }
        }
        file.weaponSelected = button
        file.weaponNum = 1
        if (file.buttonSelected != null)
        {
            EmitUISound( "wpn_pickup_Rifle_1P" )
            printt("swap", WeaponNumToSlot(file.weaponNum), file.buttonNum)
            file.weaponNum = -1
            file.buttonNum = -1
            Hud_SetSelected( file.buttonSelected, false )
            file.buttonSelected = null
            Hud_SetSelected( file.weaponSelected, false )
            file.weaponSelected = null
        }
    })
        

    file.gridData.rows = 4
    file.gridData.columns = 4
    file.gridData.paddingVert = 8
    file.gridData.paddingHorz = 8
    file.gridData.numElements = 12
    file.gridData.tileWidth = 180
    print(file.gridData.tileWidth)
    file.gridData.tileHeight = 100
    print(file.gridData.tileHeight)
    file.gridData.pageType = eGridPageType.HORIZONTAL

    //file.gridData.tileHeight = minint( Grid_GetMaxHeightForSettings( menu, file.gridData ), int( tileHeight ) + 80 )
    file.gridData.initCallback = OnModButtonReady
    file.gridData.buttonFadeCallback = Grid_FadeDefaultElementChildren
    //file.gridData.getFocusCallback = SPButton_GetFocus
    file.gridData.clickCallback = ModButton_Click
    GridMenuInit( file.menu, file.gridData )

    thread UpdateTooltip( Hud_GetChild( file.menu, "ArmorUI" ) )
}

void function OnMenuOpened()
{
    entity player = GetLocalClientPlayer()

    Hud_SetText( Hud_GetChild( file.menu, "MobVal" ), string( Roguelike_GetEntityStat( player, "mobility" ) ) )
    Hud_SetText( Hud_GetChild( file.menu, "ResVal" ), string( Roguelike_GetEntityStat( player, "resilience" ) ) )
    Hud_SetText( Hud_GetChild( file.menu, "RecVal" ), string( Roguelike_GetEntityStat( player, "recovery" ) ) )
    Hud_SetText( Hud_GetChild( file.menu, "StrVal" ), string( Roguelike_GetEntityStat( player, "strength" ) ) )
    Hud_SetText( Hud_GetChild( file.menu, "IntVal" ), string( Roguelike_GetEntityStat( player, "intelligence" ) ) )
    Hud_SetText( Hud_GetChild( file.menu, "DisVal" ), string( Roguelike_GetEntityStat( player, "discipline" ) ) )
}

void function OnMenuClosed()
{

}

void function UpdateTooltip( var button )
{
    while (true)
    {
        WaitFrame()
        if (GetFocus() != null)
        {
            if (IsElementParent( button, GetFocus() ))
            {
                Hud_SetVisible( button, false )
                continue
            }
            var butPos = Hud_GetAbsPos( button )
            var focPos = Hud_GetAbsPos( GetFocus() )
            Hud_SetPos( button, Hud_GetAbsPos( GetFocus() )[0] + Hud_GetWidth( GetFocus() ) + 5, 
                Hud_GetAbsPos( GetFocus() )[1] + Hud_GetHeight( GetFocus() ) + 5 )
            //WaitFrame()
            
            Hud_SetVisible( button, true )
        }
        else
        {
            Hud_SetVisible( button, false )
        }
    }
}

bool function IsElementParent( var p, var child )
{
    child = Hud_GetParent(child)
    while (child != null)
    {
        if (child == p)
            return true
        child = Hud_GetParent(child)
    }
    return false
}

bool function OnModButtonReady( var button, int element )
{
    RuiSetImage( Hud_GetRui( button ), "buttonImage", 
        $"r2_ui/menus/loadout_icons/primary_weapon/primary_r102" )
    //Hud_SetSelected( button, true )
    return true
}

void function ModButton_Click( var button, int element )
{
    Hud_SetSelected( button, !Hud_IsSelected( button ) )

    if (file.buttonSelected != null)
    {
        Hud_SetSelected( file.buttonSelected, false )
        if (file.buttonSelected == button)
        {
            file.buttonSelected = null
            file.buttonNum = -1
            return
        }
    }
    file.buttonSelected = button
    file.buttonNum = element
    if (file.weaponSelected != null)
    {
        EmitUISound( "wpn_pickup_Rifle_1P" )
        printt("swap", WeaponNumToSlot(file.weaponNum), file.buttonNum)
        file.weaponNum = -1
        file.buttonNum = -1
        Hud_SetSelected( file.buttonSelected, false )
        file.buttonSelected = null
        Hud_SetSelected( file.weaponSelected, false )
        file.weaponSelected = null
    }
}

string function WeaponNumToSlot( int num )
{
    switch (num)
    {
        case 0:
            return "primary"
        case 1:
            return "secondary"
        case 2:
            return "at"
    }
    unreachable
}

void function OpenInventory()
{
    print("fuck")
    AdvanceMenu( GetMenu( "Inventory" ) )
}