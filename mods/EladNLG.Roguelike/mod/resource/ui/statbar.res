"Resource/UI/StatBar.res"
{
    "Label"
	{
		ControlName				Label
		wide					145
		tall					27 
		visible					1
		enabled					1
		labelText				"Mobility"
		textAlignment			east 
		fgcolor_override 		"125 125 125 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
	}
	"Bar"
	{
		"ControlName"				"ImagePanel"
		pin_to_sibling			Label
		"xpos"							"10"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_RIGHT"
		"fillColor"			"50 50 50 170"
		"wide"						"250"
		"tall"						"27"
		"visible"					"1"
	}
	"Stat"
	{
		"ControlName"				"Label"
		"wide"					"50"
		"tall"					"27" 
		"xpos"					"10"
		"visible"					"1"
		"enabled"					"1"
		"labelText"				"100"
		"textAlignment"			"right" 
		"bgcolor_override" 		"0 0 0 200"
		"font"					"OxaniumBold_27"

		"pin_to_sibling"			"Bar"
		"pin_corner_to_sibling"	"TOP_LEFT"
		"pin_to_sibling_corner"	"TOP_RIGHT"
	}

	"BarDiff"
	{
		"ControlName"				"ImagePanel"
		pin_to_sibling			Bar
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_LEFT"
		"image"						"vgui/hud/white"
		"drawColor"					"255 65 65 255"
			scaleImage 1
		"wide"						"65"
		"tall"						"27"
		"visible"					"1"
	}
	"BarFill"
	{
		"ControlName"				"ImagePanel"
		"xpos"						"0"
		"ypos"						"0"
		pin_to_sibling			Bar
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_LEFT"
		"fillColor"			"255 255 255 255"
		// "SegmentFill"				"2"
		"wide"						"50"
		"tall"						"27"
		"visible"					"1"
	}
}