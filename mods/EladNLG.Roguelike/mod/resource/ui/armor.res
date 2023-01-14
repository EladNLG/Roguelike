"resource/ui/armor.res"
{
    "ArmorTitleBG"
	{
		"ControlName"				"ImagePanel"
		"xpos"						"0"
		"ypos"						"0"
		//"pin_to_sibling"			"Screen2"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"TOP_LEFT"
		"drawColor"			"100 50 150 240"
		"scaleImage"		"1"
		"image"				"vgui/hud/white"
		// "SegmentFill"				"2"
		"wide"						"480"
		"tall"						"75" // 288 + 75
		"visible"					"1"
		// image				vgui/hud/white
	}
	"ItemTitle"
	{
		ControlName				Label
		xpos					-15
		ypos					0
		wide					480
		tall					55
		visible					1
		enabled					1
		//auto_wide_tocontents	1
		labelText				"TEST ARMOR"
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
		wide					480
		tall					25
		visible					1
		enabled					1
		//auto_wide_tocontents	1
		labelText				"Red Armor"
		textAlignment			west
		fgcolor_override 		"255 255 255 80"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_18

		pin_to_sibling			ItemTitle
		pin_corner_to_sibling	TOP_LEFT
		pin_to_sibling_corner	BOTTOM_LEFT	
	}
	"SlotStripe"
	{
		"ControlName"				"ImagePanel"
		"xpos"						"0"
		"ypos"						"0"
		"pin_to_sibling"			"ArmorTitleBG"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
		"drawColor"			"150 50 50 240"
		"scaleImage"		"1"
		"image"				"vgui/hud/white"
		// "SegmentFill"				"2"
		"wide"						"480"
		"tall"						"8" // 288 + 75
		"visible"					"1"
	}

	"ArmorPopup"
	{
		"ControlName"				"ImagePanel"
		//"xpos"						"100"
		//"ypos"						"100"
		"pin_to_sibling"			"SlotStripe"
		"pin_corner_to_sibling"		"TOP_LEFT"
		"pin_to_sibling_corner"		"BOTTOM_LEFT"
		"fillColor"			"20 20 20 240"
		// "SegmentFill"				"2"
		"wide"						"480"
		"tall"						"358" // 288 + 75
		"visible"					"1"
		// image				vgui/hud/white
	}

	"Mobility"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				-15
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling ArmorPopup
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner TOP_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}
	
	"Recovery"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling Mobility
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}
	
	"Resilience"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling Recovery
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}
	
	"Strength"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling Resilience
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}
	
	"Discipline"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling 		Strength
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}

	"Intelligence"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling Discipline
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}
	
	
	"Total"
	{
		"ControlName"		"CNestedPanel"
		xpos				00
		ypos				10
		wide				480
		tall				27
		visible				1
		enabled				1
		pin_to_sibling Intelligence
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/StatBar.res"
	}

	"ExoticPerk"
	{
		ControlName				Label
		xpos					-15
		ypos					15
		visible					1
		wide					450
		enabled					1
		//auto_wide_tocontents	1
		labelText				"Run and Gun" // don't use &, causes weird shit with this font??
		textAlignment			north-west
		auto_wide_tocontents	0
		auto_tall_tocontents	1
		fgcolor_override 		"200 200 50 255"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumBold_27
		pin_to_sibling				Total
		pin_to_sibling_corner		BOTTOM_LEFT
		pin_corner_to_sibling		TOP_LEFT
	}
	
	"ExoticDesc"
	{
		ControlName				Label
		xpos					0
		ypos					0
		visible					1
		wide					450
		enabled					1
		//auto_wide_tocontents	1
		labelText				"Upon killing a titan, instantly regain a dash."
		textAlignment			north-west
		auto_wide_tocontents	0
		auto_tall_tocontents	1
		fgcolor_override 		"200 200 50 255"
		//bgcolor_override 		"0 0 0 200"
		font					OxaniumLight_27
		pin_to_sibling				ExoticPerk
		pin_to_sibling_corner		BOTTOM_LEFT
		pin_corner_to_sibling		TOP_LEFT
	}
}