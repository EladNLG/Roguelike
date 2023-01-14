untyped
global function ClItem_Init
global function ReplaceWithSeries
global function ServerCallback_ObtainedItem
global function ServerCallback_SetItemAmount
global function ServerCallback_SetLoanAmount
global function ServerCallback_SetCashAmount
global bool isPaused = false

const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"

array<string> deathMessages = [
    "%cs died.",
    "%cs will be forgotten.",
    "%cs was a good gunman.\nBut not good enough.",
    "%cs confused r/titanfall for this. He didn't come out alive.",
    "%cs thought this was gonna be a breeze.",
    "\"I'm fine\" -%cs, 2022.",
    "Long live the king, %cs.",
    "Tip: Death is (kinda) permanent. I think %cs forgot that.",
    "%cs thought religion worked here. It does not."
]
array<string> youDiedMessages = [
    "You died.",
    "You will be forgotten.",
    "You were a good gunman, until you weren't.",
    "L",
    "You thought this was gonna be a breeze.",
    "You should reduce the difficulty.\nOh wait, you can't.",
    "\"I'm fine\" -%cs, 2022.",
    "Long live the king.",
    "Tip: Death is (kinda) permanent. Maybe you should take it seriously.",
    "You're funny.",
    "You thought religion worked here. It does not.",
    "There are only so many death messages. You're so bad I ran out."
]

struct 
{
    entity curItem
    var flyoutRUI
    var drawbackRUI
    var moneyRUI
    var loanRUI
    int requiredToPay = 0
    BarTopoData& data
    array<string> items
    float lastItemPickupTime = -500
    string curItemDisplay = ""
    bool isFocused = true
    bool isArmorInFocus = false
} file

void function ClItem_Init()
{
    if (IsLobby()) return

    
    AddCallback_UseEntGainFocus( OnEntGainedFocus )
    AddCallback_UseEntLoseFocus( OnEntLostFocus )
    AddCallback_OnPlayerLifeStateChanged( OnPlayerLifeStateChanged )
    AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )

    RegisterSignal( "ChestLostFocus" )
}

void function OnEntitiesDidLoad()
{
    var rui = RuiCreate( RUI_TEXT_LEFT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.05, 0.1, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.55, 0.0> )
    RuiSetString( rui, "msgText", "0$" )
    RuiSetFloat( rui, "msgFontSize", 60.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.5 )
    file.moneyRUI = rui
    rui = RuiCreate( RUI_TEXT_LEFT, clGlobal.topoCockpitHud, RUI_DRAW_COCKPIT, 0 )
    RuiSetInt( rui, "maxLines", 1 )
    RuiSetInt( rui, "lineNum", 0 )
    RuiSetFloat2( rui, "msgPos", <0.05, 0.15, 0> )
    RuiSetFloat3( rui, "msgColor", <0.9, 0.55, 0.0> )
     RuiSetString( rui, "msgText", "" )
    RuiSetFloat( rui, "msgFontSize", 30.0 )
    RuiSetFloat( rui, "msgAlpha", 0.9 )
    RuiSetFloat( rui, "thicken", 0.0 )
    file.loanRUI = rui

    file.data = BasicImageBar_CreateRuiTopo( <0,0,0>, < -0.055, -0.2, 0>, 1, 1, eDirection.right, false )
    thread MoneyRUI_Update()
}

float lastTimeCashChanged = 0
int lastCashAmount = 0
int curCashAmount = 0
void function ServerCallback_SetCashAmount( int newValue )
{
    if (newValue == GetMoney( GetLocalViewPlayer() )) return
    lastCashAmount = int(GraphCapped(pow(Time() - lastTimeCashChanged, 0.5), 0, pow(1, 0.5), lastCashAmount, curCashAmount))
    lastTimeCashChanged = Time()
    curCashAmount = newValue
    GetLocalViewPlayer().s.money <- newValue
}

void function MoneyRUI_Update()
{
    if (IsLobby()) return
    if (!IsNewThread()) throw "MoneyRUI_Update() must be called from a new thread."

    float lastTSLDC = 0
    while (true)
    {
        if (file.requiredToPay > 0)
            RuiSetString( file.loanRUI, "msgText", "REQUIRED TO PAY LOAN: " + file.requiredToPay)
        else RuiSetString( file.loanRUI, "msgText", "" )
        RuiSetString( file.moneyRUI, "msgText", int(GraphCapped(pow(Time() - lastTimeCashChanged, 0.5), 0, pow(1, 0.5), lastCashAmount, curCashAmount)) + "$")
        Hud_SetVisible( HudElement("ItemUI"), file.curItem != null || (!file.isArmorInFocus && Time() - file.lastItemPickupTime <= 5.0 && file.items.len() > 0) )
        if (file.curItem == null && !file.isArmorInFocus)
        {
            Hud_SetText( Hud_GetChild(HudElement("ItemUI"), "ItemPrompt"), "Picked Up" )
            if (file.items.len() > 0 && file.curItemDisplay != file.items[0])
            {
                SetItemDisplay( file.items[0], Roguelike_GetItemCount( GetLocalClientPlayer(), file.items[0] ) - 1 )
            }
            if (Time() - file.lastItemPickupTime >= 5.0 && file.items.len() > 0)
            {
                file.items.remove(0)
                if (file.items.len() > 0)
                {
                    file.lastItemPickupTime = Time()
                    SetItemDisplay( file.items[0], Roguelike_GetItemCount( GetLocalClientPlayer(), file.items[0] ) - 1 )
                }
            }
        }
        else Hud_SetText( Hud_GetChild(HudElement("ItemUI"), "ItemPrompt"), "%+use%" )
        WaitFrame()
    }
}

void function RestartUpdateWhenHUDOn()
{
    if (!IsNewThread()) throw "This needs be in new thread"

    clGlobal.levelEnt.WaitSignal( "MainHud_TurnOn" )

    thread MoneyRUI_Update()
}

/// DEATH MESSAGE
void function OnPlayerLifeStateChanged( entity player, int oldLifeState, int newLifeState )
{
    if( newLifeState == LIFE_DEAD && oldLifeState == LIFE_ALIVE )
    {
        string playerName = player.GetPlayerName()
        if (player == GetLocalClientPlayer())
        {
            Chat_GameWriteLine( "\x1b[112m" + ReplaceWithSeries( youDiedMessages.getrandom(), [ playerName, playerName ] ))
        }
        else Chat_GameWriteLine( "\x1b[112m" + ReplaceWithSeries( deathMessages.getrandom(), [ playerName, playerName ] ) )
    }
}

void function OnEntGainedFocus( entity ent )
{
    if ( StartsWith( ent.GetScriptName(), "item_drop_" ) )
        ItemDropGainedFocus( ent )
    else if (StartsWith( ent.GetScriptName(), "armor_" ))
    {
        ArmorDropGainedFocus( ent )
        file.isArmorInFocus = true
    }
    
    if ( ent.GetScriptName() == "roguelike_chest" )
        thread ChestGainedFocus( ent )
    //RuiSetResolutionToScreenSize( file.flyoutRUI )
}

void function ChestGainedFocus( entity ent )
{
    OnThreadEnd( function () : (){
        RuiSetFloat3( file.moneyRUI, "msgColor", <0.9, 0.55, 0.0> )
    } )

    clGlobal.levelEnt.EndSignal( "ChestLostFocus" )

    while (true)
    {
        float g = GraphCapped( sin(Time() * 4) / 2 + 0.5, 0, 1, 0.55, 0.1 )
        RuiSetFloat3( file.moneyRUI, "msgColor", <0.9, g, 0.0> )
        WaitFrame()
    }
}

void function ItemDropGainedFocus( entity ent )
{
    file.curItem = ent

    string item = ent.GetScriptName().slice( 10, ent.GetScriptName().len() )
    SetItemDisplay( item, Roguelike_GetItemCount( GetLocalClientPlayer(), item ) )
}

void function SetItemDisplay( string item, int stacks )
{
    string rarity = Roguelike_GetItemRarity( item )
    int stacks = stacks

    int statCount = Roguelike_GetItemStatCount( item )
    
    var itemUI = HudElement("ItemUI") 
    Hud_SetVisible( itemUI, true )
    Hud_EnableKeyBindingIcons( Hud_GetChild( itemUI, "ItemPrompt") )
    var popupBG = Hud_GetChild(itemUI, "ArmorPopup")

    Hud_SetText( Hud_GetChild(itemUI, "ItemDesc"), Roguelike_GetItemDesc(item) )
    Hud_SetText( Hud_GetChild(itemUI, "ItemTitle"), Roguelike_GetItemName(item).toupper() )
    Hud_SetColor( Hud_GetChild(itemUI, "ArmorTitleBG"), 
        ColorVectorToArray(Roguelike_GetRarityPickupColor(rarity)) )
    SetStatUI( Hud_GetChild(itemUI, "Stat1"), "Count", (stacks + 1).tostring(), true, stacks.tostring())

    int visibleStats = 0
    array<var> panels = [ Hud_GetChild(itemUI, "Stat2"), Hud_GetChild(itemUI, "Stat3"), Hud_GetChild(itemUI, "Stat4") ]
    foreach ( var panel in panels )
    {
        Hud_SetVisible( panel, false )
    }
    for ( int i = 0; i < statCount && visibleStats < panels.len(); i++ )
    {
        var panel = panels[visibleStats]
        Hud_SetVisible( panel, true )
        string statName = Roguelike_GetItemStatName(item, i)
        string statFormat = Roguelike_GetItemStatFormat(item, i)
        float functionref( int ) statFunc = Roguelike_GetItemStatFunc(item, i)
        bool functionref( int ) obsoleteFunc = Roguelike_GetItemStatObsoleteFunc( item, i )
        if (obsoleteFunc != null)
        {
            if (obsoleteFunc(stacks + 1))
            {
                Hud_SetVisible( panel, false )
                continue
            }
        }
        visibleStats++
        string newVal = format(statFormat, statFunc(stacks + 1))
        string oldVal = format(statFormat, statFunc(stacks))
        bool hasChange = statFunc(stacks + 1) != statFunc(stacks)
        SetStatUI( panel, statName, newVal, hasChange, oldVal )
    }
    Hud_SetHeight( popupBG, Hud_GetHeight(Hud_GetChild(itemUI, "ItemDesc") ) + ( (40 + 37 * (visibleStats + 1)) * GetScreenSize()[1] / 1080 ) )
    file.curItemDisplay = item
}

array<int> function ColorVectorToArray( vector v ) 
{
    return [ int( v.x * 255 ), int( v.y * 255 ), int( v.z * 255 ), 240 ]
}

void function SetStatUI( var panel, string statName, string newVal, bool hasChange, string oldVal = "" )
{
    var label = Hud_GetChild(panel, "Label")
    var oldLabel = Hud_GetChild(panel, "OldVal")
    var newLabel = Hud_GetChild(panel, "NewVal")
    var arrow = Hud_GetChild(panel, "Arrow")

    Hud_SetVisible( oldLabel, hasChange )
    Hud_SetVisible( arrow, hasChange )
    if (hasChange)
        Hud_SetText( oldLabel, oldVal )
    Hud_SetText( newLabel, newVal )
    Hud_SetText( label, statName )
}

void function ServerCallback_SetLoanAmount( int amount )
{
    file.requiredToPay = amount
}

void function OnEntLostFocus( entity ent )
{
    clGlobal.levelEnt.Signal( "ChestLostFocus" )
    //if (file.curItem != ent)
    //    return
    //Hud_SetVisible( HudElement("ItemUI"), false )
    if (file.isArmorInFocus)
    {
        ArmorDropLostFocus( ent )
        file.lastItemPickupTime = Time()
        file.isArmorInFocus = false
    }
    file.curItem = null
}

void function ServerCallback_ObtainedItem( int playerEHandle, int item )
{
    entity player = GetEntityFromEncodedEHandle( playerEHandle )
    if (!IsValid(player))
        throw "????"

    //Hud_SetVisible( HudElement("ItemUI"), false )
    Roguelike_GiveEntityItem( player, Roguelike_GetItemFromNumericId(item) )
}

void function ServerCallback_SetItemAmount( int item, int amount, bool isPickup )
{
    entity player = GetLocalClientPlayer()
    if (!IsValid(player))
        throw "????"
    
    string item = Roguelike_GetItemFromNumericId(item)
    if (isPickup)
    {
        file.lastItemPickupTime = Time()
        file.items.push(item)
    }
    //Hud_SetVisible( HudElement("ItemUI"), false )
    //print( "SETTING ITEM AMOUNT: " + item + " amount: " + amount )
    //print( "CURRENT ITEM " + item + " AMOUNT: " + amount )
    Roguelike_GiveEntityItem( player, item, amount - Roguelike_GetItemCount( player, item ) )
}

// fucking util functions >:(
vector function RotateVector( vector vec, vector rotateAngles )
{
	return vec.x * AnglesToForward( rotateAngles ) + vec.y * -1.0 * AnglesToRight( rotateAngles ) + vec.z * AnglesToUp( rotateAngles )
}

string function ReplaceWithSeries( string str, array<string> replace )
{
    string newStr = ""
    if (replace.len() == 0)
        return str
    for (int i = 0; i < replace.len(); i++)
    {
        if (str.find("%cs") == null)
            break
        int a = expect int( str.find("%cs") )
        if (a > 0 && str[a - 1] == '%') {
            newStr += str.slice( 0, a + 3 )
            str = str.slice( a + 3, str.len() )
            i--
            continue
        }
        //print( "Replacing \"%cs\" with \"" + replace[i] + "\"")
        newStr = newStr + str.slice(0, a) + replace[i]
        str = str.slice(a + 3, str.len())
    }
    newStr += str
    return newStr
}

void function Roguelike_SetPaused( bool paused )
{
    isPaused = paused
    Hud_SetVisible( HudElement("ItemUI"), !paused )
}