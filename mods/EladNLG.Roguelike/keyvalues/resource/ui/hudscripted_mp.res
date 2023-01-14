
Resource/UI/HudScripted_mp.res
{
	
	"ArmorUI"
	{
		"ControlName"		"CNestedPanel"
		xpos				r600
		ypos				r600
		wide				600
		tall				600
		visible				0
		enabled				1
		zpos				0
		///pin_to_sibling Resilience
		pin_corner_to_sibling TOP_LEFT
		pin_to_sibling_corner BOTTOM_LEFT


		controlSettingsFile	"resource/UI/Armor.res"
	}

	"ItemUI"
	{
		"ControlName"		"CNestedPanel"
		xpos				r600
		ypos				r600
		wide				512
		tall				363
		visible				0
		enabled				1
		zpos				0


		controlSettingsFile	"resource/UI/Item.res"
	}
}
