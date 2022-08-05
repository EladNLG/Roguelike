globalize_all_functions


var function OnWeaponPrimaryAttack_debug_tool( entity weapon, WeaponPrimaryAttackParams params )
{
    entity player = weapon.GetOwner()

    vector angles = player.EyeAngles()
	vector forward = AnglesToForward( angles )
	vector origin = player.EyePosition()

	vector start = origin
	vector end = origin + forward * 50000
	TraceResults result = TraceLine( start, end )

    printt( "POSITION:", result.endPos )
    if (IsValid(result.hitEnt))
    {
        printt( "HIT ENT:", result.hitEnt )
        printt( "ENT MODEL:", result.hitEnt.GetModelName() )
    }
    else printt( "HIT ENT: NONE / NOT VALID")

    printt( "SURFACE NORMAL:", result.surfaceNormal )


    return 1
}