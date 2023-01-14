"resource/ui/item.res"
{
    "ArmorTitleBG"
	{
		"ControlName"				"ImagePanel"
		"xpos"						"0"
		"ypos"						"0"
		//"pin_to_sibling"			"Screen2"
        "image"             "vgui/hud/white"
		"drawColor"			"50 150 50 240"
        "scaleImage"        "1"
		// "SegmentFill"				"2"
		"wide"						"512"
		"tall"						"75" // 288 + 75
		"visible"					"1"
		// image				vgui/hud/white
	}
	"ItemTitle"
	{
		ControlName				Label
		xpos					-15
		ypos					0
		wide					512
		tall					55
		visible					1
		enabled					1
		//auto_wide_tocontents	1
		labelText				"ADRENALINE SHOT"
		textAlignment			west
		//fgcolor_override 		"255 255 255 255"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumBold_43

		pin_to_sibling			ArmorTitleBG
		pin_corner_to_sibling	ItemTitleTOP_LEFT
		pin_to_sibling_corner	TOP_LEFT	
	}
	"ItemType"
	{
		ControlName				Label
		xpos					0
		ypos					-10
		wide					512
		tall					25
		visible					1
		enabled					1
		//auto_wide_tocontents	1
		labelText				"Item"
		textAlignment			west
		fgcolor_override 		"255 255 255 80"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_18

		pin_to_sibling			ItemTitle
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT	
	}

	"ItemPrompt"
	{
		ControlName				Label
		xpos					-10
		ypos					-10
		wide					512
		visible					1
		enabled					1
		auto_tall_tocontents	1
		labelText				"%+use%"
		textAlignment			east
		fgcolor_override 		"180 180 180 255"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27

		pin_to_sibling			ArmorTitleBG
		pin_corner_to_sibling	BOTTOM_RIGHT
		pin_to_sibling_corner	BOTTOM_RIGHT	
	}

	"ArmorPopup"
	{
		"ControlName"				"ImagePanel"
		//"xpos"						"100"
		//"ypos"						"100"
		"pin_to_sibling"			"ArmorTitleBG"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
		"fillColor"			"20 20 20 240"
		// "SegmentFill"				"2"
		"wide"						"512"
		"tall"						"126" // 288 + 75
		"visible"					"1"
		// image				vgui/hud/white
	}

	"ItemDesc"
	{
		ControlName				Label
		wide					492
		tall					95
		xpos					-10
		ypos					-10
		visible					1
		//enabled					1
		auto_tall_tocontents		1
		labelText				"^FFFFFF00On Kill: ^0Gain a speed boost for ^55CCFF000.5s^0."
		textAlignment			north-west 
		fgcolor_override 		"125 125 125 255"
		bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
        wrap                    1
		
		"pin_to_sibling"			"ArmorPopup"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_LEFT"
	}

    "Stat1"
    {
        "ControlName"		"CNestedPanel"
		xpos				0
		ypos				30
		wide				512
		tall				27
		visible				1
		enabled				1
		zpos				0
		pin_to_sibling ItemDesc
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT

        "class"                     "stat"
		controlSettingsFile	"resource/UI/ItemStat.res"
    }

    "Stat2"
    {
        "ControlName"		"CNestedPanel"
		xpos				0
		ypos				10
		wide				512
		tall				27
		visible				1
		enabled				1
		zpos				0
		pin_to_sibling Stat1
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT

        "class"                     "stat"
		controlSettingsFile	"resource/UI/ItemStat.res"
    }

    "Stat3"
    {
        "ControlName"		"CNestedPanel"
		xpos				0
		ypos				10
		wide				512
		tall				27
		visible				1
		enabled				1
		zpos				0
		pin_to_sibling Stat2
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT

        "class"                     "stat"
		controlSettingsFile	"resource/UI/ItemStat.res"
    }
    
    "Stat4"
    {
        "ControlName"		"CNestedPanel"
		xpos				0
		ypos				10
		wide				512
		tall				27
		visible				1
		enabled				1
		zpos				0
		pin_to_sibling Stat3
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT

        "class"                     "stat"
		controlSettingsFile	"resource/UI/ItemStat.res"
    }
}