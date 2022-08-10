globalize_all_functions

const RUI_TEXT_CENTER = $"ui/cockpit_console_text_center.rpak"
const RUI_TEXT_LEFT = $"ui/cockpit_console_text_top_left.rpak"
const RUI_TEXT_RIGHT = $"ui/cockpit_console_text_top_right.rpak"

struct
{
	var bgRui
	var noItemsRui
	table<string, var> playerItemRUIs
	var playerItemCountRUI
	var aspectRatioFixTopo
} file

void function Roguelike_InitScoreboard()
{
	float right = (GetScreenSize()[1] / 9.0) * 16.0
	float down = GetScreenSize()[1]
	float xOffset = (GetScreenSize()[0] - right) / 2
	file.aspectRatioFixTopo = RuiTopology_CreatePlane( <xOffset, 0, 0>, <right, 0, 0>, <0, down, 0>, false ) 
    var rui = RuiCreate( $"ui/basic_image.rpak", clGlobal.topoFullScreen, RUI_DRAW_HUD, 15 )
	RuiSetFloat( rui, "basicImageAlpha", 0.0 )
	RuiSetFloat3( rui, "basicImageColor", <0,0,0> )
	file.bgRui = rui

	rui = RuiCreate( RUI_TEXT_CENTER, GetAspectRatioFixTopo(), RUI_DRAW_HUD, 16 )
	RuiSetInt( rui, "maxLines", 1 )
	RuiSetInt( rui, "lineNum", 0 )
	RuiSetFloat2( rui, "msgPos", <0,0,0> )
	RuiSetFloat3( rui, "msgColor", <0.4, 0.4, 0.4> )
	RuiSetString( rui, "msgText", "You have no items!" )
	RuiSetFloat( rui, "msgFontSize", 32.0 )
	RuiSetFloat( rui, "msgAlpha", 0.0 )
	RuiSetFloat( rui, "thicken", 0.0 )
	file.noItemsRui = rui

	for (int i = file.playerItemRUIs.len(); i < Roguelike_GetAllRarities().len(); i++)
	{
		string rarity = Roguelike_GetAllRarities()[i]
		print(rarity)
		var rui = RuiCreate( RUI_TEXT_LEFT, GetAspectRatioFixTopo(), RUI_DRAW_HUD, 16 )
		RuiSetInt( rui, "maxLines", 25 )
		RuiSetInt( rui, "lineNum", 0 )
		RuiSetFloat2( rui, "msgPos", <0.1, 0.1 / 9.0 * 16.0, 0> )
		RuiSetFloat3( rui, "msgColor", Roguelike_GetRarityColor( rarity ) )
		RuiSetString( rui, "msgText", "Adrenaline Shot" )
		RuiSetFloat( rui, "msgFontSize", 32.0 )
		RuiSetFloat( rui, "msgAlpha", 0.0 )
		RuiSetFloat( rui, "thicken", 0.0 )
		file.playerItemRUIs[rarity] <- rui
		//print(i)
		// print(file.playerItemRUIs.len())
	}
	rui = RuiCreate( RUI_TEXT_LEFT, file.aspectRatioFixTopo, RUI_DRAW_HUD, 16 )
	RuiSetInt( rui, "maxLines", 25 )
	RuiSetInt( rui, "lineNum", 0 )
	RuiSetFloat2( rui, "msgPos", <0.07, 0.1 / 9.0 * 16.0, 0> )
	RuiSetFloat3( rui, "msgColor", <0.3, 0.3, 0.3> )
	RuiSetString( rui, "msgText", " x2" )
	RuiSetFloat( rui, "msgFontSize", 32.0 )
	RuiSetFloat( rui, "msgAlpha", 0.0 )
	RuiSetFloat( rui, "thicken", 0.0 )
	file.playerItemCountRUI = rui
}

void function Roguelike_ShowScoreboard()
{
	PauseDisplay()
	StopPickupPrompt()
    array<string> items = Roguelike_GetPlayerItems( GetLocalClientPlayer() )
	print(items.len())

	thread RuiSetFloatOverTime( file.bgRui, "basicImageAlpha", 0.0, 0.7, 0.1 )
	thread RuiSetFloatOverTime( file.noItemsRui, "msgAlpha", 0.0, 0.9, 0.1 )
	thread RuiSetFloatOverTime( file.playerItemCountRUI, "msgAlpha", 0.0, 0.9, 0.1 )
	
	
	foreach (string rarity in Roguelike_GetAllRarities())
	{
		print(rarity)
		var rui = file.playerItemRUIs[rarity]
		string result = ""
		foreach (int index, string item in items)
		{
			string id = items[index]
			string name = Roguelike_GetItemName( id )
			if (Roguelike_GetItemRarity( id ) == rarity)
			{
				result += name
				string amountStr = Roguelike_GetItemCount( GetLocalClientPlayer(), id ).tostring()
			}
			result += "\n"
			//print(name)
		}
		//WhitespaceString( name.len() ) + " x" + Roguelike_GetItemCount( GetLocalClientPlayer(), items[index] )
		RuiSetString( rui, "msgText", result )
	}
	var countRui = file.playerItemCountRUI
	string countResult = ""
	foreach (int index, string item in items)
	{
		string id = items[index]
		string amountStr = Roguelike_GetItemCount( GetLocalClientPlayer(), id ).tostring()
		countResult += WhitespaceString( maxint( 0, 3 - amountStr.len() - 1 ) ) + "x" + amountStr
		countResult += "\n"
		//print(name)
	}
	RuiSetString( countRui, "msgText", countResult )
	array<var> batch
	foreach (var rui in  file.playerItemRUIs)
		batch.append(rui)
	thread RuiBatchSetFloatOverTime( batch, "msgAlpha", 0.0, 0.9, 0.1)

}

void function Roguelike_HideScoreboard()
{
	ResumeDisplay()
	ResumePickupPrompt()
    array<string> items = Roguelike_GetPlayerItems( GetLocalClientPlayer() )

	thread RuiSetFloatOverTime( file.bgRui, "basicImageAlpha", 0.70, 0.0, 0.1 )
	thread RuiSetFloatOverTime( file.noItemsRui, "msgAlpha", 0.9, 0.0, 0.1 )
	thread RuiSetFloatOverTime( file.playerItemCountRUI, "msgAlpha", 0.9, 0.0, 0.1 )

	array<var> batch
	foreach (var rui in file.playerItemRUIs)
		batch.append(rui)
	print("=-=-=-=-=-=-=-=-=-=")
	thread RuiBatchSetFloatOverTime( batch, "msgAlpha", 0.9, 0.0, 0.1)
	//thread RuiBatchSetFloatOverTime( file.playerItemCountRUIs, "msgAlpha", 0.9, 0.0, 0.1)
}

void function RuiSetFloatOverTime( var rui, string param, float start, float end, float time )
{
	float startTime = Time()
	do 
	{
		WaitFrame()
		float t = clamp((Time() - startTime) / time, 0, 1)
		RuiSetFloat( rui, param, GraphCapped( t, 0, 1, start, end ) )
	}
	while (Time() - startTime < time)
}

void function RuiBatchSetFloatOverTime( array<var> ruis, string param, float start, float end, float time )
{
	float startTime = Time()
	print(ruis.len())
	foreach (int index, var rui in ruis)
		printt(index, rui)
	do 
	{
		WaitFrame()
		float t = clamp((Time() - startTime), 0, time) / time
		//print(GraphCapped( t, 0, 1, start, end ))
		foreach (int index, var rui in ruis)
		{
			RuiSetFloat( rui, param, GraphCapped( t, 0, 1, start, end ) )
		}
	}
	while (Time() - startTime < time)
}

string function WhitespaceString( int len )
{
	string result = ""
	for (int i = 0; i < len; i++)
	{
		result += " "
	}
	return result
}