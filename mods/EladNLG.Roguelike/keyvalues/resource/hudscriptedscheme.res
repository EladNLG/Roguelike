///////////////////////////////////////////////////////////
// Tracker scheme resource file
//
// sections:
//		Colors			- all the colors used by the scheme
//		BaseSettings	- contains settings for app to use to draw controls
//		Fonts			- list of all the fonts used by app
//		Borders			- description of all the borders
//
///////////////////////////////////////////////////////////
Scheme
{
	InheritableProperties
	{
		BoxBorder
		{
			border					BoxBorder
		}
	}
	Fonts
	{

		OxaniumLight_43
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			43
				dropshadow 		1
			}
		}

		OxaniumBold_56
		{
			isproportional only
			1
			{
				name			OxaniumBold
				tall			56
				antialias 		1
				dropshadow			1
			}
		}

		OxaniumBold_43_DropShadow
		{
			isproportional only
			1
			{
				name			OxaniumBold
				tall			43
				antialias 		1
				dropshadow		1
			}
		}

		OxaniumBold_43_Italic
		{
			isproportional only
			1
			{
				name			OxaniumBold
				tall			43
				antialias 		1
				italic			1
			}
		}

		OxaniumBold_43
		{
			isproportional only
			1
			{
				name			OxaniumBold
				tall			43
				antialias 		1
			}
		}

		OxaniumBold_27
		{
			isproportional only
			1
			{
				name			OxaniumBold
				tall			27
				antialias 		1
			}
		}

		OxaniumLight_32
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			32
				antialias 		1
			}
		}

		OxaniumLight_27
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			27
				antialias 		1
			}
		}
		
		OxaniumLight_27_ShadowGlow
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			27
				antialias 		1
				shadowglow		7
			}
		}
		
		OxaniumLight_27_Italic
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			27
				antialias 		1
				italic			1
			}
		}

		OxaniumLight_18
		{
			isproportional only
			1
			{
				name			OxaniumLight
				tall			18
				antialias 		1
			}
		}
	}

	//////////////////// BORDERS //////////////////////////////
	// describes all the border types
	Borders
	{
		BoxBorder
		{
			inset 	"32 32 32 32"
			bordertype				scalable_image
			//backgroundtype			2

			image					"ui/box"
			src_corner_height		32				// pixels inside the image
			src_corner_width		32
			draw_corner_width		32				// screen size of the corners ( and sides ), proportional
			draw_corner_height 		32
		}
	}
}
