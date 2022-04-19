globalize_all_functions

struct ModData
{
    string className // name of the mod on the weapon (e.g. extended_ammo)
    string displayName // display name of the mod (e.g. Extended Ammo)
    int value // price of the mod (e.g. 100)
}

struct 
{
    array<ModData> mods
} file

void function ShopPrices_Init()
{
    AddCallback_OnRegisteringHighlights(RegisterRoguelikeHighlight)

    ShopPrices_AddMod("extended_ammo", "Extended Ammo", 50)
    ShopPrices_AddMod("pas_fast_reload", "Fast Reload", 25)
    // it makes snipers viable, but otherwise useless.
    ShopPrices_AddMod("pas_fast_reload", "Fast ADS", 20)
    ShopPrices_AddMod("pas_fast_reload", "Fast Swap", 15)
}

void function RegisterRoguelikeHighlight()
{
    HighlightContext h = RegisterHighlight( "roguelike_item" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 2000 )
	HighlightContext_SetRadius( h, 8 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.ALWAYS )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <1,1,1>)
    HighlightContext_SetParam(h, 1, <1,1,1>)
	HighlightContext_SetAfterPostProcess( h, true )

    h = RegisterHighlight( "roguelike_chest" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 5000 )
	HighlightContext_SetRadius( h, 8 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.ALWAYS )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, HIGHLIGHT_COLOR_FRIENDLY)
    HighlightContext_SetParam(h, 1, HIGHLIGHT_COLOR_FRIENDLY)
	HighlightContext_SetAfterPostProcess( h, true )
    
    h = RegisterHighlight( "roguelike_bounds" )
    HighlightContext_SetADSFade( h, false )
    HighlightContext_SetFarFadeDistance( h, 60000 )
	HighlightContext_SetRadius( h, 8 )
    HighlightContext_SetOutline( h, HIGHLIGHT_OUTLINE_CUSTOM_COLOR )
    HighlightContext_SetFill( h, HIGHLIGHT_FILL_CUSTOM_COLOR_FADED )
    HighlightContext_SetDrawFunc( h, eHighlightDrawFunc.ALWAYS )
	HighlightContext_SetADSFade( h, false )
    HighlightContext_SetEntityVisible(h, true)
    HighlightContext_SetParam(h, 0, <1,0,0>)
    HighlightContext_SetParam(h, 1, <1,0,0>)
	HighlightContext_SetAfterPostProcess( h, true )
}

void function ShopPrices_AddMod(string name, string displayName, int value)
{
    ModData data

    data.className = name
    data.displayName = displayName
    data.value = value

    file.mods.append(data)
}

int function GetMoney( entity player )
{
    return player.GetPlayerNetInt( "roguelikeCash" ) + player.GetPlayerNetInt( "roguelikeCashStacks" ) * 1024
}