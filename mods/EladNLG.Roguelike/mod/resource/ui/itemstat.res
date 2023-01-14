"resource/ui/itemstat.res"
{
    "Label"
	{
		ControlName				Label
		wide					290
		tall					27 
		xpos					0
		ypos					0
		visible					1
		//enabled					1
		labelText				"Duration"
		textAlignment			west 
		fgcolor_override 		"125 125 125 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
		
	}

	"OldVal"
	{
		ControlName				Label
		wide					80
		tall					27 
		xpos					10
		ypos					0
		visible					1
		enabled					1
		labelText				"0.5s"
		textAlignment			east 
		fgcolor_override 		"125 125 125 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
		
		"pin_to_sibling"			"Label"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_RIGHT"
	}
	"Arrow"
	{
		ControlName				Label
		wide					40
		tall					27 
		xpos					10
		ypos					0
		visible					1
		enabled					1
		labelText				">>"
		textAlignment			east
		auto_wide_tocontents	1 
		fgcolor_override 		"125 125 125 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
		
		"pin_to_sibling"			"OldVal"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_RIGHT"
	}
	
	"NewVal"
	{
		ControlName				Label
		wide					80
		tall					27 
		xpos					10
		ypos					0
		visible					1
		enabled					1
		//auto_wide_tocontents	1
		labelText				"0.75s"
		textAlignment			west 
		fgcolor_override 		"255 255 255 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumBold_27
		
		"pin_to_sibling"			"Arrow"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_RIGHT"
	}
}