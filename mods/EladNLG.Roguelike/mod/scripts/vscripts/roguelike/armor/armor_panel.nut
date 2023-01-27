untyped
global function Roguelike_SetStatBar
global function Roguelike_SetTotalBar

void function Roguelike_SetStatBar( var panel, string statName, int curValue, int newValue )
{
    var label = Hud_GetChild( panel, "Label" )
    var stat = Hud_GetChild( panel, "Stat" )
    var bar = Hud_GetChild( panel, "BarFill" )
    var diff = Hud_GetChild( panel, "BarDiff" )

    Hud_SetText( label, statName )
    Hud_SetText( stat, "+" + newValue )

    int min = 0
    int max = 40
    int range = max - min
    // max 30
    int maxSize = int(250 * GetScreenSize()[0] / 1920.0)
    Hud_SetWidth(bar, minint(minint( curValue - min, newValue - min ) * maxSize / range, maxSize) ) // / 30 * 250
    Hud_SetWidth(diff, minint(maxint( curValue - min, newValue - min ) * maxSize / range, maxSize) )

    if (curValue > newValue)
        diff.SetColor( 255, 65, 65, 60 )
    else diff.SetColor( 100, 255, 100, 255)
}
void function Roguelike_SetTotalBar( var panel, string statName, int curValue, int newValue )
{
    var label = Hud_GetChild( panel, "Label" )
    var stat = Hud_GetChild( panel, "Stat" )
    var bar = Hud_GetChild( panel, "BarFill" )
    var diff = Hud_GetChild( panel, "BarDiff" )

    Hud_SetText( label, statName )
    Hud_SetText( stat, newValue.tostring() )

    int min = 0
    int max = 100
    int range = max - min
    // max 30
    int maxSize = int(250 * GetScreenSize()[0] / 1920.0)
    Hud_SetWidth(bar, minint(minint( curValue - min, newValue - min ) * maxSize / range, maxSize) ) // / 30 * 250
    Hud_SetWidth(diff, minint(maxint( curValue - min, newValue - min ) * maxSize / range, maxSize) )

    if (curValue > newValue)
        diff.SetColor( 255, 65, 65, 60)
    else diff.SetColor( 100, 255, 100, 255)
}