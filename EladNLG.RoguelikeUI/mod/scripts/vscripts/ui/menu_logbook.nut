untyped
global function AddLogbookMenu
global function AddLogbookEntry

const int BUTTONS_PER_PAGE = 15
const string SETTING_ITEM_TEXT = "                        " // this is long enough to be the same size as the textentry field

struct LogbookEntry {
	string name
    string description
    string logbookEntry
}

struct {
	var menu
	int scrollOffset = 0
	bool updatingList = false

	array<LogbookEntry> itemList
	// if people use searches - i hate them but it'll do :)
	array<LogbookEntry> filteredList
	string filterText = ""
	table< int, int > enumRealValues
	array<var> modPanels
} file

struct {
	int deltaX = 0
	int deltaY = 0
} mouseDeltaBuffer

void function AddLogbookMenu()
{
    print("\n\n\n\n\n\n\n\n\n\n\n\nPAIN\n\n\n\n\n\n\n\n")
	AddMenu( "Logbook", $"resource/ui/menus/logbook.menu", InitLogbook )
}

void function InitLogbook()
{
	file.menu = GetMenu( "Logbook" )
	AddMenuFooterOption( file.menu, BUTTON_B, "#B_BUTTON_BACK", "#BACK" )

    // test
    AddLogbookEntry( "Ammo Pack", "10% chance to restore 10% ammo to your weapon each kill.", 
    "[DELIVERY 52314]\n\nYou said you needed a self-feeding mechanism.\nAlright... Inside this pack should be an attachment you can" + 
    " connect to your gun that should deliver the ammo automatically. Though it's malfunctioning sometimes, it never did something wrong..." )
    AddLogbookEntry( "Adrenaline Shot", "Per kill, 70% speed boost for 0.5s (+0.25s per stack).", 
    "[DELIVERY 64175]\n\nManagement has noted your recent addiction to...certain materials, so I've been asked to send you a...less potent version. Sorry." )
    AddLogbookEntry( "Overclock Mechanism", "10% chance to refresh abilities and ammo.", "[TRANSCRIPTION - 2586-5-31]\n\nMechanic: Are you sure you want to do this? If the Titan goes unstable, he could explode, killing you in the process...\n\n???: Yes. I'm gonna die in battle either way, no?\n\nMechanic: I guess..." )
    AddLogbookEntry( "Leeching Hands", "Heal for 20HP/s when wallrunning.", "[TRANSCRIPTION - 2552-7-3]\n\nShopkeeper: Are we closing?\n\nManager: Yup. You're free to go.\n\nThe shopkeeper rises up from his chair, grabs his stuff and walks towards the exit.\n\nThen, [REDACTED] enters the shop.\n\nThe rest of this transcription has been removed.\nReason: puked in bucket. also technically classified but mostly cause puked in bucket." )
    AddLogbookEntry( "Fragile Bird", "+50%% Air Acceleration. Take 20HP/s of damage whilst wallrunning.", "" )
	AddLogbookEntry( "Golden Shell", "The last bullet (or 2 with projectile weapons) deals 15% more damage.", "")
	AddLogbookEntry( "Emergency Soda", "When taking lethal damage (does not include OoB damage), heal to full instead. Consumes upon use.", "-------------------------------\n\nthis is a transcription of what happened please don't touch I beg you please\n\n-------------------------------\n\nSoldier 1: Why are you taking your soda again?\n\nSoldier 2: I get lucky when I'm drunk.\n\nSoldier 1: THAT CONTAINS ALCOHOL?!\n\nSoldier 2: uhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhhh")
	// Nuke weird rui on filter switch :D
	//RuiSetString( Hud_GetRui( Hud_GetChild( file.menu, "SwtBtnShowFilter")), "buttonText", "")

	file.modPanels = GetElementsByClassname( file.menu, "ModButton" )

	AddMenuEventHandler( file.menu, eUIEvent.MENU_OPEN, OnModMenuOpened )
	AddMenuEventHandler( file.menu, eUIEvent.MENU_CLOSE, OnModMenuClosed )

	int len = file.modPanels.len()
	print(len)	
	for (int i = 0; i < len; i++)
	{
		//AddButtonEventHandler( button, UIE_CHANGE, OnSettingButtonPressed  )
		// get panel
		var panel = file.modPanels[i]


		// reset to default nav
		var child = Hud_GetChild( panel, "BtnMod" )

		child.SetNavUp( Hud_GetChild( file.modPanels[ GetIndex( i - 1, len ) ], "BtnMod" ) )
		child.SetNavDown( Hud_GetChild( file.modPanels[ GetIndex( i + 1, len ) ], "BtnMod" ) )

		AddButtonEventHandler( child, UIE_GET_FOCUS, OnLogbookButtonFocused )
	}

	//Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnModsSearch" ), UIE_LOSE_FOCUS, OnFilterTextPanelChanged )
	Hud_AddEventHandler( Hud_GetChild( file.menu, "BtnFiltersClear" ), UIE_CLICK, OnClearButtonPressed )
	// mouse delta 
	AddMouseMovementCaptureHandler( file.menu, UpdateMouseDeltaBuffer )

	thread SearchBarUpdate()
}

void function OnLogbookButtonFocused( var button )
{
	LogbookEntry entry = file.filteredList[ int ( Hud_GetScriptID( Hud_GetParent( button ) ) ) + file.scrollOffset ]

    var rui = Hud_GetRui( Hud_GetChild( file.menu, "LabelDetails" ) )
	
	RuiSetGameTime( rui, "startTime", -99999.99 ) // make sure it skips the whole animation for showing this
	RuiSetString( rui, "headerText", entry.name )
    RuiSetString( rui, "messageText", entry.description + "\n\n" + (entry.logbookEntry == "" ? "" : "LOGBOOK ENTRY:\n\n" + entry.logbookEntry) )
}

void function SearchBarUpdate()
{
	while (true)
	{
		if (file.filterText != Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) ) )
		{
			file.filterText = Hud_GetUTF8Text( Hud_GetChild( file.menu, "BtnModsSearch" ) )
			OnFiltersChange(0)
		}
		WaitFrame()
	}
}

int function GetIndex( int index, int length )
{
	if (index < 0)
		return (length - 1) - (-index - 1) % length
	return index % length
}

////////////////////////
// slider
////////////////////////
void function UpdateMouseDeltaBuffer(int x, int y)
{
	mouseDeltaBuffer.deltaX += x
	mouseDeltaBuffer.deltaY += y

	SliderBarUpdate()
}

void function FlushMouseDeltaBuffer()
{
	mouseDeltaBuffer.deltaX = 0
	mouseDeltaBuffer.deltaY = 0
}


void function SliderBarUpdate()
{
	if ( file.filteredList.len() <= 15 )
	{
		FlushMouseDeltaBuffer()
		return
	}

	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )

	Hud_SetFocused(sliderButton)

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float maxHeight = 604.0  * (GetScreenSize()[1] / 1080.0)
	float maxYPos = minYPos - (maxHeight - Hud_GetHeight( sliderPanel ))
	float useableSpace = (maxHeight - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( float( file.filteredList.len())))

	// got local from official respaw scripts, without untyped throws an error
	local pos =	Hud_GetPos(sliderButton)[1]
	local newPos = pos - mouseDeltaBuffer.deltaY
	FlushMouseDeltaBuffer()

	if ( newPos < maxYPos ) newPos = maxYPos
	if ( newPos > minYPos ) newPos = minYPos

	Hud_SetPos( sliderButton , 2, newPos )
	Hud_SetPos( sliderPanel , 2, newPos )
	Hud_SetPos( movementCapture , 2, newPos )

	file.scrollOffset = -int( ( (newPos - minYPos) / useableSpace ) * ( file.filteredList.len() - BUTTONS_PER_PAGE) )
	UpdateList()
}

void function UpdateListSliderHeight()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.filteredList.len() )

	float maxHeight = 604.0 * (GetScreenSize()[1] / 1080.0)
	float minHeight = 80.0 * (GetScreenSize()[1] / 1080.0)

	float height = maxHeight * ( float( BUTTONS_PER_PAGE ) / mods )

	if ( height > maxHeight ) height = maxHeight
	if ( height < minHeight ) height = minHeight

	Hud_SetHeight( sliderButton , height )
	Hud_SetHeight( sliderPanel , height )
	Hud_SetHeight( movementCapture , height )
}

void function UpdateList()
{
	Hud_SetFocused(Hud_GetChild(file.menu, "BtnModsSearch"))
	file.updatingList = true

	array<LogbookEntry> filteredList = []

	string lastModNameInFilter = ""
	LogbookEntry curModConVar = file.itemList[0]
	for (int i = 0; i < file.itemList.len(); i++)
	{
		LogbookEntry c = file.itemList[i]
        string displayName = c.name

		if (file.filterText == "" || displayName.tolower().find(file.filterText.tolower()) != null)
		{
            filteredList.append(c)
		}
	}

	file.filteredList = filteredList

	int j = int( min( file.filteredList.len() + file.scrollOffset, 15 ) )

	for ( int i = 0; i < 15; i++ )
	{
		Hud_SetEnabled( file.modPanels[ i ], i < j )
		Hud_SetVisible( file.modPanels[ i ], i < j )
		
		if (i < j)
			SetModMenuNameText( file.modPanels[ i ] )
	}
	file.updatingList = false
}

void function SetModMenuNameText( var button )
{
	LogbookEntry entry = file.filteredList[ int ( Hud_GetScriptID( button ) ) + file.scrollOffset ]

	var panel = file.modPanels[ int ( Hud_GetScriptID( button ) ) ]

	var label = Hud_GetChild( panel, "BtnMod" )
    Hud_SetText(label, entry.name)
}

void function OnScrollDown( var button )
{
	if ( file.filteredList.len() <= BUTTONS_PER_PAGE ) return
	file.scrollOffset += 5
	if (file.scrollOffset + BUTTONS_PER_PAGE > file.filteredList.len()) {
		file.scrollOffset = file.filteredList.len() - BUTTONS_PER_PAGE
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function OnScrollUp( var button )
{
	file.scrollOffset -= 5
	if (file.scrollOffset < 0) {
		file.scrollOffset = 0
	}
	UpdateList()
	UpdateListSliderPosition()
}

void function UpdateListSliderPosition()
{
	var sliderButton = Hud_GetChild( file.menu , "BtnModListSlider" )
	var sliderPanel = Hud_GetChild( file.menu , "BtnModListSliderPanel" )
	var movementCapture = Hud_GetChild( file.menu , "MouseMovementCapture" )
	
	float mods = float ( file.filteredList.len() )

	float minYPos = -40.0 * (GetScreenSize()[1] / 1080.0)
	float useableSpace = (604.0 * (GetScreenSize()[1] / 1080.0) - Hud_GetHeight( sliderPanel ))

	float jump = minYPos - (useableSpace / ( mods - float( BUTTONS_PER_PAGE ) ) * file.scrollOffset)

	//jump = jump * (GetScreenSize()[1] / 1080.0)

	if ( jump > minYPos ) jump = minYPos

	Hud_SetPos( sliderButton , 2, jump )
	Hud_SetPos( sliderPanel , 2, jump )
	Hud_SetPos( movementCapture , 2, jump )
}

void function OnModMenuOpened()
{
	file.scrollOffset = 0
	file.filterText = ""
	
	RegisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
	RegisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	
	
	OnFiltersChange(0)
}

void function OnFiltersChange( var n )
{
	file.scrollOffset = 0
	
	//HideAllButtons()
	
	//RefreshModsArray()
	
	UpdateList()
	
	UpdateListSliderHeight()
}

void function OnModMenuClosed()
{
	try
	{
		DeregisterButtonPressedCallback(MOUSE_WHEEL_UP , OnScrollUp)
		DeregisterButtonPressedCallback(MOUSE_WHEEL_DOWN , OnScrollDown)
	}
	catch ( ex ) {}
}

void function AddLogbookEntry( string name, string description, string logbookEntry )
{
	LogbookEntry data

	data.name = name
	data.description = description
	data.logbookEntry = logbookEntry

	file.itemList.append(data)
}

void function OnClearButtonPressed( var button )
{
	file.filterText = ""

	Hud_SetText( Hud_GetChild( file.menu, "BtnModsSearch" ), "" )

	OnFiltersChange(0)
}