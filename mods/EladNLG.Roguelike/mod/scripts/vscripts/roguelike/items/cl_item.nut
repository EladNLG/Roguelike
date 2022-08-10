global function ClItem_Init
global function ReplaceWithSeries
global function ServerCallback_ObtainedItem
global function ServerCallback_SetItemAmount
global function ServerCallback_SetLoanAmount
global function CashAmountChanged

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
void function CashAmountChanged( entity player, int oldValue, int newValue, bool actuallyChanged )
{
    if (curCashAmount == GetMoney( player )) return
    if ( player != GetLocalViewPlayer() ) return
    lastTimeCashChanged = Time()
    lastCashAmount = curCashAmount
    curCashAmount = GetMoney( player )
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
        RuiSetString( file.moneyRUI, "msgText", int(GraphCapped(sqrt(Time()), sqrt(lastTimeCashChanged), sqrt(lastTimeCashChanged + 1), lastCashAmount, curCashAmount)) + "$")
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
    if (file.flyoutRUI != null)
    {
        RuiDestroyIfAlive(file.flyoutRUI)
        file.flyoutRUI = null
    }
    if (file.drawbackRUI != null)
    {
        RuiDestroyIfAlive(file.drawbackRUI)
        file.drawbackRUI = null
    }
    
    file.curItem = ent

    string itemId = ent.GetScriptName().slice( 10, ent.GetScriptName().len() )
    string rarity = Roguelike_GetItemRarity( itemId )
    int stacks = Roguelike_GetItemCount( GetLocalViewPlayer(), itemId )
    
    string drawbackPostfix = "\n\n"
    string descPostfix = "\n\n"
    int descLines = GetCharCount(Roguelike_GetItemDesc(itemId), '\n') + 1
    int drawbackDescLines = GetCharCount(Roguelike_GetItemDrawbackDesc(itemId), '\n') + 1

    print("descLines: " + descLines + " drawbackDescLines: " + drawbackDescLines)
    while (descLines != drawbackDescLines)
    {
        print("descLines: " + descLines + " drawbackDescLines: " + drawbackDescLines)
        if (descLines > drawbackDescLines)
        {
            print("drawbackDescLines++")
            drawbackPostfix += "\n"
            drawbackDescLines++
        }
        else
        {
            print("descLines++")
            descPostfix += "\n"
            descLines++
        }
    }

    for (int i = 0; i < Roguelike_GetItemStatCount(itemId); i++)
    {
        string statName = Roguelike_GetItemStatName(itemId, i)
        string statFormat = Roguelike_GetItemStatFormat(itemId, i)
        float functionref( int ) statFunc = Roguelike_GetItemStatFunc(itemId, i)
        bool functionref( int ) obsoleteFunc = Roguelike_GetItemStatObsoleteFunc( itemId, i )
        if (obsoleteFunc != null)
        {
            if (obsoleteFunc(stacks + 1))
                continue
        }
        string str = statName + ": " + format(statFormat, statFunc(stacks))
        if (statFunc(stacks + 1) != statFunc(stacks))
            str += " -> " + format(statFormat, statFunc(stacks + 1))
        if (Roguelike_GetIsItemStatDrawback(itemId, i))
        {
            drawbackPostfix += str + "\n"
            descPostfix += "\n"
        }
        else
        {
            descPostfix += str + "\n"
            drawbackPostfix += "\n"
        }
    }

    // CREATE RUI
    file.flyoutRUI = RuiCreate( $"ui/weapon_flyout.rpak", file.data.topoData[0].topo, RUI_DRAW_COCKPIT, -5 )

    RuiSetGameTime( file.flyoutRUI, "startTime", Time() - 0.5 )
	RuiSetFloat( file.flyoutRUI, "duration", 99999.9 )

    RuiTrackFloat3( file.flyoutRUI, "pos", ent, RUI_TRACK_OVERHEAD_FOLLOW )

    string postfix = ""
    if (stacks > 0)
        postfix = " (" + stacks + " -> " + (stacks + 1) + ")"
    RuiSetString( file.flyoutRUI, "titleText", "`2%use% " + Roguelike_GetItemName(itemId) + postfix )
    RuiSetString( file.flyoutRUI, "descriptionText", Roguelike_GetItemDesc(itemId) + descPostfix )

    RuiSetFloat3( file.flyoutRUI, "color", Roguelike_GetRarityColor( rarity ) )

    file.drawbackRUI = RuiCreate( $"ui/weapon_flyout.rpak", file.data.topoData[0].topo, RUI_DRAW_COCKPIT, -4 )

    RuiSetGameTime( file.drawbackRUI, "startTime", Time() - 0.5 )
    RuiSetFloat( file.drawbackRUI, "duration", 99999.9 )
    
    RuiSetFloat( file.drawbackRUI, "underlineHeight", 0.0 )
    RuiSetFloat( file.drawbackRUI, "underlineWidth", 0.0 )
    RuiSetFloat( file.flyoutRUI, "underlineHeight", 0.0 )
    RuiSetFloat( file.flyoutRUI, "underlineWidth", 0.0 )

    RuiTrackFloat3( file.drawbackRUI, "pos", ent, RUI_TRACK_OVERHEAD_FOLLOW )

    RuiSetString( file.drawbackRUI, "titleText", "" )
    RuiSetString( file.drawbackRUI, "descriptionText", Roguelike_GetItemDrawbackDesc(itemId) + drawbackPostfix )

    RuiSetFloat3( file.drawbackRUI, "color", Roguelike_GetRarityColor( RARITY_LEGENDARY ) )
    
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
    
    if (file.flyoutRUI != null)
    {
        RuiDestroyIfAlive(file.flyoutRUI)
        file.flyoutRUI = null
    }
    if (file.drawbackRUI != null)
    {
        RuiDestroyIfAlive(file.drawbackRUI)
        file.drawbackRUI = null
    }
    file.curItem = null
}

void function ServerCallback_ObtainedItem( int playerEHandle, int item )
{
    entity player = GetEntityFromEncodedEHandle( playerEHandle )
    if (!IsValid(player))
        throw "????"

    if (file.flyoutRUI != null)
    {
        RuiDestroyIfAlive(file.flyoutRUI)
        file.flyoutRUI = null
    }
    if (file.drawbackRUI != null)
    {
        RuiDestroyIfAlive(file.drawbackRUI)
        file.drawbackRUI = null
    }
    Roguelike_GiveEntityItem( player, Roguelike_GetItemFromNumericId(item) )
}

void function ServerCallback_SetItemAmount( int playerEHandle, int item, int amount )
{
    entity player = GetEntityFromEncodedEHandle( playerEHandle )
    if (!IsValid(player))
        throw "????"
    
    if (file.flyoutRUI != null)
    {
        RuiDestroyIfAlive(file.flyoutRUI)
        file.flyoutRUI = null
    }
    if (file.drawbackRUI != null)
    {
        RuiDestroyIfAlive(file.drawbackRUI)
        file.drawbackRUI = null
    }
    string item = Roguelike_GetItemFromNumericId(item)
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

int function CountReplacements( string str, array<string> replace )
{
    if (replace.len() == 0)
        return 0
    int replaced = 0
    for (int i = 0; i < replace.len(); i++)
    {
        if (str.find("%cs") == null)
            break
        
        int a = expect int( str.find("%cs") )

        if (a > 0 && str[a - 1] == '%') {
            str = str.slice( a + 3, str.len() )
            i--
            continue
        }
        replaced++
        str = str.slice(a + 3, str.len())
    }
    return replaced
}

int function GetCharCount(string str, int c)
{
    int count = 0
    for (int i = 0; i < str.len(); i++)
    {
        if (str[i] == c)
        {
            count++
        }
    }
    return count
}