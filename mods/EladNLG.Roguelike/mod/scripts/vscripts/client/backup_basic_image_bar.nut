untyped

int x = 0

#if !PLAYER_HAS_HUD_REVAMP
// copy pasted from hud revamp to disconnect dependency

global enum eDirection 
{
    down, 
    up,
    left,
    right
}

global struct TopoData {
    vector position = Vector( 0.0, 0.0, 0.0 )
    vector size = Vector( 0.0, 0.0, 0.0 )
    vector angles = Vector( 0.0, 0.0, 0.0 )
    var topo
}

global struct BarTopoData {
    vector position = Vector( 0.0, 0.0, 0.0 )
    vector size = Vector( 0.0, 0.0, 0.0 )
    vector angles = Vector( 0.0, 0.0, 0.0 )
    int segments = 1
	float segmentDistance
    array<var> imageRuis
    array<TopoData> topoData
    int direction
	float fill
}

global function BasicImageBar_CreateRuiTopo
global function BasicImageBar_UpdateSegmentCount
global function BasicImageBar_SetFillFrac
global function GetConVarFloat2
global function GetConVarFloat3
global function CreateWorldTopo

bool enableVerbosePrinting = false

vector function GetConVarFloat2(string convar)
{
    array<string> value = split( GetConVarString(convar), " " )
    try {
        return Vector( value[0].tofloat(), value[1].tofloat(), 0.0 ) 
    }
    catch (ex)
    {
        throw "Invalid convar " + convar + "! make sure it is a float2 and formatted as \"X Y\""
    }
    unreachable
}

vector function GetConVarFloat3(string convar)
{
    array<string> value = split( GetConVarString(convar), " " )
    try {
        return Vector( value[0].tofloat(), value[1].tofloat(), value[2].tofloat() ) 
    }
    catch (ex)
    {
        throw "Invalid convar " + convar + "! make sure it is a float3 and formatted as \"X Y Z\""
    }
    unreachable
}

BarTopoData function BasicImageBar_CreateRuiTopo(vector posOffset, vector angles, float hudWidth, float hudHeight, int direction = eDirection.right, bool createRui = true, int order = -1)
{
    if (hudWidth < 0 || hudHeight < 0)
    {
        throw "hudWidth and hudHeight must be positive! They were " + hudWidth + " and " + hudHeight
    }
    float height = COCKPIT_RUI_HEIGHT * hudHeight
    float width = COCKPIT_RUI_WIDTH * hudWidth
    // we keep roll as-is in case we want a bar that goes down/up or right to left.
    vector _angles = Vector( angles.y * COCKPIT_RUI_HEIGHT, -angles.x * COCKPIT_RUI_WIDTH, angles.z )

    var topo = CreateBar( posOffset, _angles, width, height )

    BarTopoData data
    data.position = posOffset
    data.size = Vector( width, height, 0.0 )
    data.angles = _angles

    TopoData topoData
    topoData.position = posOffset
    topoData.size = Vector( width, height, 0.0 )
    topoData.angles = _angles
    topoData.topo = topo
    data.direction = direction 

    data.topoData = [ topoData ]
    data.fill = 1

    if (createRui)
    {
        var rui = RuiCreate( $"ui/basic_image.rpak", data.topoData[0].topo, RUI_DRAW_COCKPIT, order )
        data.imageRuis.append(rui)
    }

    return data
}

void function BasicImageBar_UpdateSegmentCount( BarTopoData data, int segmentCount, float segDistance )
{
    foreach (var image in data.imageRuis )
    {
        RuiDestroy( image )
    }
    foreach (TopoData topoData in data.topoData )
    {
        RuiTopology_Destroy( topoData.topo )
    }

    float segmentDistance = segDistance / data.size.x
    //printt("UPDATING SEGMENTS: " + segmentCount + "\nDIRECTION:" + data.direction)
    if (data.direction == eDirection.down || data.direction == eDirection.up)
        segmentDistance = segDistance / data.size.y
    
    data.segmentDistance = segDistance

    data.topoData.clear()
    data.imageRuis.clear()

    data.segments = segmentCount

    // data.size.x -  total size of topo
    // (segmentCount - 1) * segmentDistance - total size taken up by distances
    // data.size.x - totalGaps - total size taken up by actual segments
    // totalFill 
    // 30deg, 15seg, 1dis
    // 2deg/seg, 1 dis
    // 1 / 15
    // 2 - (1/15)
    array<float> starts
    array<float> ends
    starts.append(0)
    for (int i = 0; i < segmentCount; i++)
    {
        ends.append(float(i + 1) / segmentCount - segmentDistance / 2)
        starts.append(float(i + 1) / segmentCount + segmentDistance / 2)
    }
    float scale = 1 / ends[segmentCount - 1]
    for (int i = 0; i < segmentCount; i++)
    {
        ends[i] *= scale
        // don't need to do the first one since 0 * anything = 0, and we have segmentCount + 1 values in the array.
        starts[i + 1] *= scale
    }

    // 5seg, 5deg
    // 0, 1, 2, 3, 4

    switch (data.direction)
    {
        case eDirection.left:
        case eDirection.right:
            for (int i = 0; i < segmentCount; i++)
            {
                TopoData topoData

                topoData.position = data.position
                topoData.angles = data.angles + <0, starts[i] * data.size.x + (ends[i] - starts[i]) * data.size.x / 2 - data.size.x / 2, 0>
                topoData.size = <(ends[i] - starts[i]) * data.size.x, data.size.y, 0>

                topoData.topo = CreateBar( topoData.position, 
                    topoData.angles, 
                    topoData.size.x, 
                    topoData.size.y )
                //printt("CREATED TOPO: " + topoData.angles + " " + topoData.size)

                data.topoData.append(topoData)
            }
            break
        case eDirection.up:
        case eDirection.down:
            if (data.topoData.len() > 0)
                throw "??????????"
            for (int i = 0; i < segmentCount; i++)
            {
                TopoData topoData

                topoData.position = data.position
                topoData.angles = data.angles + <starts[i] * data.size.y + (ends[i] - starts[i]) * data.size.y / 2 - data.size.y / 2, 0, 0>
                topoData.size = <data.size.x, (ends[i] - starts[i]) * data.size.y, 0>

                topoData.topo = CreateBar(topoData.position, 
                    topoData.angles, 
                    topoData.size.x, 
                    topoData.size.y )
                
                data.topoData.append(topoData)
            }
    }

    for (int i = 0; i < segmentCount; i++)
    {
        var rui = RuiCreate( $"ui/basic_image.rpak", data.topoData[i].topo, RUI_DRAW_COCKPIT, -1 )
        data.imageRuis.append(rui)
    }
}

// fucking util functions >:(
vector function RotateVector( vector vec, vector rotateAngles )
{
	return vec.x * AnglesToForward( rotateAngles ) + vec.y * -1.0 * AnglesToRight( rotateAngles ) + vec.z * AnglesToUp( rotateAngles )
}

var function CreateBar( vector posOffset, vector angles, float hudWidth, float hudHeight )
{
    if (hudWidth < 0 || hudHeight < 0)
    {
        throw "hudWidth and hudHeight must be positive! They were " + hudWidth + " and " + hudHeight
    }
    if (enableVerbosePrinting)
    {
        printt("Creating bar at " + posOffset + " with angles " + angles + " and size " + hudWidth + "x" + hudHeight)
    }
    return RuiTopology_CreateSphere( 
        COCKPIT_RUI_OFFSET + posOffset, // 
        AnglesToRight( angles ), // right
        AnglesToUp( angles ) * -1, // down 
        COCKPIT_RUI_RADIUS, 
        hudWidth, 
        hudHeight, 
        COCKPIT_RUI_SUBDIV // 3.5
    )
}

var function CreateWorldTopo( vector org, vector ang, float width, float height )
{
	// adjust so the RUI is drawn with the org as its center point
	org += ( (AnglesToRight( ang )*-1) * (width*0.5) )
	org += ( AnglesToUp( ang ) * (height*0.5) )

	// right and down vectors that get added to base org to create the display size
	vector right = ( AnglesToRight( ang ) * width )
	vector down = ( (AnglesToUp( ang )*-1) * height )

	//DebugDrawAngles( org, ang, 10000 )
	//DebugDrawAngles( org + right, ang, 10000 )
	//DebugDrawAngles( org + down, ang, 10000 )

	var topo = RuiTopology_CreatePlane( org, right, down, false )
	return topo
}

var function BasicImageBar_SetFillFrac(BarTopoData barData, float progress)
{

    // want to make it update anyways cause of real-time settings updating
    //if (barData.fill == progress)
    //    return
    barData.fill = progress
    switch (barData.direction)
    {
        case eDirection.right:
            float yPos = barData.topoData[0].size.y
            for (int i = barData.segments - 1; i >= 0; i--)
            {
                TopoData data = barData.topoData[i]
                // RuiTopology_UpdatePos( clGlobal.topoCockpitHudPermanent, < COCKPIT_RUI_OFFSET.x, COCKPIT_RUI_OFFSET.y, COCKPIT_RUI_OFFSET.z + 200.0 >, <0, -1, 0>, <0, 0, -1> )
                //  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
                //  0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9
                float minProgress = float(barData.segments - i - 1) / barData.segments
                float maxProgress = minProgress + (1.0 / barData.segments)
                float segProgress = Graph( progress, minProgress, maxProgress, 0.0, 1.0 )
                if (yPos != data.size.y)
                {
                    //throw "???????"
                }
                // this segment is supposed to be full
                if (progress >= maxProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles ), AnglesToUp( data.angles ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y, 3 )
                }
                else if (progress > minProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles - <0, data.size.x * segProgress / 2 - data.size.x / 2, 0> ), AnglesToUp( data.angles - <0, data.size.x * segProgress / 2 - data.size.x / 2, 0> ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x * segProgress, data.size.y, 3 )
                }
                else 
                {
                    // no need to update position since we update it then we "unhide" the topo, just set width to 0.
                    RuiTopology_UpdateSphereArcs( data.topo, 0, 0, 3 )
                }
            }
            break
        case eDirection.left:
            for (int i = 0; i < barData.segments; i++)
            {
                TopoData data = barData.topoData[i]
                // RuiTopology_UpdatePos( clGlobal.topoCockpitHudPermanent, < COCKPIT_RUI_OFFSET.x, COCKPIT_RUI_OFFSET.y, COCKPIT_RUI_OFFSET.z + 200.0 >, <0, -1, 0>, <0, 0, -1> )
                //  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
                //  0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9
                float minProgress = float(i) / barData.segments
                float maxProgress = minProgress + (1.0 / barData.segments)
                float segProgress = Graph( progress, minProgress, maxProgress, 0.0, 1.0 )
                // this segment is supposed to be full
                if (progress >= maxProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles ), AnglesToUp( data.angles ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y, 3 )
                }
                else if (progress > minProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles + <0, data.size.x * segProgress / 2 - data.size.x / 2, 0> ), AnglesToUp( data.angles + <0, data.size.x * segProgress / 2 - data.size.x / 2, 0> ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x * segProgress, data.size.y, 3 )
                }
                else 
                {
                    // no need to update position since we update it then we "unhide" the topo, just set width to 0.
                    RuiTopology_UpdateSphereArcs( data.topo, 0, 0, 3 )
                }
            }
            break
        case eDirection.up:
            for (int i = barData.segments - 1; i >= 0; i--)
            {
                TopoData data = barData.topoData[i]
                // RuiTopology_UpdatePos( clGlobal.topoCockpitHudPermanent, < COCKPIT_RUI_OFFSET.x, COCKPIT_RUI_OFFSET.y, COCKPIT_RUI_OFFSET.z + 200.0 >, <0, -1, 0>, <0, 0, -1> )
                //  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
                //  0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9
                float minProgress = float(barData.segments - i - 1) / barData.segments
                float maxProgress = minProgress + (1.0 / barData.segments)
                float segProgress = Graph( progress, minProgress, maxProgress, 0.0, 1.0 )
                // this segment is supposed to be full
                if (progress >= maxProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles ), AnglesToUp( data.angles ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y, 3 )
                }
                else if (progress > minProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles - <data.size.y * segProgress / 2 - data.size.y / 2, 0, 0> ), AnglesToUp( data.angles - <data.size.y * segProgress / 2 - data.size.y / 2, 0, 0> ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y * segProgress, 3 )
                }
                else 
                {
                    // no need to update position since we update it then we "unhide" the topo, just set width to 0.
                    RuiTopology_UpdateSphereArcs( data.topo, 0, 0, 3 )
                }
            }
            break

        case eDirection.down:
            for (int i = 0; i < barData.segments; i++)
            {
                TopoData data = barData.topoData[i]
                // RuiTopology_UpdatePos( clGlobal.topoCockpitHudPermanent, < COCKPIT_RUI_OFFSET.x, COCKPIT_RUI_OFFSET.y, COCKPIT_RUI_OFFSET.z + 200.0 >, <0, -1, 0>, <0, 0, -1> )
                //  9,  8,  7,  6,  5,  4,  3,  2,  1,  0
                //  0.0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9
                float minProgress = float(i) / barData.segments
                float maxProgress = minProgress + (1.0 / barData.segments)
                float segProgress = Graph( progress, minProgress, maxProgress, 0.0, 1.0 )
                // this segment is supposed to be full
                if (progress >= maxProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles ), AnglesToUp( data.angles ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y, 3 )
                }
                else if (progress > minProgress)
                {
                    RuiTopology_UpdatePos( data.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles + <data.size.y * segProgress / 2 - data.size.y / 2, 0, 0> ), AnglesToUp( data.angles + <data.size.y * segProgress / 2 - data.size.y / 2, 0, 0> ) * -1 )
                    RuiTopology_UpdateSphereArcs( data.topo, data.size.x, data.size.y * segProgress, 3 )
                }
                else 
                {
                    // no need to update position since we update it then we "unhide" the topo, just set width to 0.
                    RuiTopology_UpdateSphereArcs( data.topo, 0, 0, 3 )
                }
            }
            break
    }
}

void function BasicImageBar_ChangePosition(BarTopoData data, vector newPos)
{

}

// Updates the position and topo, for topologies that don't get updated much
BarTopoData function BasicImageBar_UpdatePosition( BarTopoData data, vector newPos, float newXSize, float newYSize )
{
    
    //printt("ok", newPos, newXSize, newYSize) 
    float height = COCKPIT_RUI_HEIGHT * newYSize
    float width = COCKPIT_RUI_WIDTH * newXSize

    if (newPos == data.position && width == data.size.x && height == data.size.y)
        return data
    
    vector _angles = Vector( newPos.y * COCKPIT_RUI_HEIGHT, -newPos.x * COCKPIT_RUI_WIDTH, newPos.z )

    data.size = Vector( width, height, 0.0 )
    data.angles = _angles

    if (data.segments > 1)
    {
        // data.size.x -  total size of topo
        // (segmentCount - 1) * segmentDistance - total size taken up by distances
        // data.size.x - totalGaps - total size taken up by actual segments
        // totalFill 
        // 30deg, 15seg, 1dis
        // 2deg/seg, 1 dis
        // 1 / 15
        // 2 - (1/15)
        //printt(data.segmentDistance)
        float segmentDistance = data.segmentDistance / data.size.x
        if (data.direction == eDirection.down || data.direction == eDirection.up)
            segmentDistance = data.segmentDistance / data.size.y

        array<float> starts
        array<float> ends
        starts.append(0)
        for (int i = 0; i < data.segments; i++)
        {
            ends.append(float(i + 1) / data.segments - segmentDistance / 2)
            starts.append(float(i + 1) / data.segments + segmentDistance / 2)
        }


        float scale = 1 / ends[data.segments - 1]

        for (int i = 0; i < data.segments; i++)
        {
            ends[i] *= scale
            // don't need to do the first one since 0 * anything = 0, and we have segmentCount + 1 values in the array.
            starts[i + 1] *= scale
        }
        for (int i = 0; i < ends.len(); i++)
            printt("Start:", starts[i], "End:", ends[i])

        // 5seg, 5deg
        // 0, 1, 2, 3, 4

        switch (data.direction)
        {
            case eDirection.left:
            case eDirection.right:
                for (int i = 0; i < data.segments; i++)
                {
                    data.topoData[i].position = data.position
                    data.topoData[i].angles = data.angles + <0, starts[i] * data.size.x + (ends[i] - starts[i]) * data.size.x / 2 - data.size.x / 2, 0>
                    data.topoData[i].size = <(ends[i] - starts[i]) * data.size.x, data.size.y, 0>
                    TopoData topoData = data.topoData[i]

                    RuiTopology_UpdatePos( topoData.topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( topoData.angles ), AnglesToUp( topoData.angles ) * -1)
                    
                    RuiTopology_UpdateSphereArcs( topoData.topo, topoData.size.x, topoData.size.y, 3 )
                }
                break
            case eDirection.up:
            case eDirection.down:
                for (int i = 0; i < data.segments; i++)
                {
                    
                    data.topoData[i].position = data.position
                    data.topoData[i].angles = data.angles + <starts[i] * data.size.y + (ends[i] - starts[i]) * data.size.y / 2 - data.size.y / 2, 0, 0>
                    data.topoData[i].size = <data.size.x, (ends[i] - starts[i]) * data.size.y, 0>
                    TopoData topoData = data.topoData[i]
                    
                    RuiTopology_UpdatePos( topoData.topo, COCKPIT_RUI_OFFSET + topoData.position, AnglesToRight( topoData.angles ), 
                        AnglesToUp( topoData.angles ) * -1)
                        
                    RuiTopology_UpdateSphereArcs( topoData.topo, topoData.size.x, topoData.size.y, 3 )
                
                }
        }
    }
    else
    {
        data.size = Vector( width, height, 0.0 )
        data.angles = _angles
        data.topoData[0].size = Vector( width, height, 0.0 )
        data.topoData[0].angles = _angles

        RuiTopology_UpdatePos( data.topoData[0].topo, COCKPIT_RUI_OFFSET + data.position, AnglesToRight( data.angles ), 
                        AnglesToUp( data.angles ) * -1)
                        
        RuiTopology_UpdateSphereArcs( data.topoData[0].topo, data.size.x, data.size.y, 3 )
    }
    return data
}

// Updates the position without updating the topo, if the topo is getting updated every frame anyways.
BarTopoData function BasicImageBar_UpdatePosition_NoUpdateTopo( BarTopoData data, vector newPos, float newXSize, float newYSize )
{
    float height = COCKPIT_RUI_HEIGHT * newYSize
    float width = COCKPIT_RUI_WIDTH * newXSize

    if (newPos == data.position && width == data.size.x && height == data.size.y)
        return data
    
    vector _angles = Vector( newPos.y * COCKPIT_RUI_HEIGHT, -newPos.x * COCKPIT_RUI_WIDTH, newPos.z )

    //data.position = posOffset
    data.size = Vector( width, height, 0.0 )
    data.angles = _angles

    if (data.segments > 1)
    {
        // data.size.x -  total size of topo
        // (segmentCount - 1) * segmentDistance - total size taken up by distances
        // data.size.x - totalGaps - total size taken up by actual segments
        // totalFill 
        // 30deg, 15seg, 1dis
        // 2deg/seg, 1 dis
        // 1 / 15
        // 2 - (1/15)
        float segmentDistance = data.segmentDistance / data.size.x
        if (data.direction == eDirection.down || data.direction == eDirection.up)
            segmentDistance = data.segmentDistance / data.size.y

        array<float> starts
        array<float> ends
        starts.append(0)
        for (int i = 0; i < data.segments; i++)
        {
            ends.append(float(i + 1) / data.segments - segmentDistance / 2)
            starts.append(float(i + 1) / data.segments + segmentDistance / 2)
        }

        float scale = 1 / ends[data.segments - 1]

        for (int i = 0; i < data.segments; i++)
        {
            ends[i] *= scale
            // don't need to do the first one since 0 * anything = 0, and we have segmentCount + 1 values in the array.
            starts[i + 1] *= scale
        }

        // 5seg, 5deg
        // 0, 1, 2, 3, 4

        switch (data.direction)
        {
            case eDirection.left:
            case eDirection.right:
                for (int i = 0; i < data.segments; i++)
                {
                    data.topoData[i].position = data.position
                    data.topoData[i].angles = data.angles + <0, starts[i] * data.size.x + (ends[i] - starts[i]) * data.size.x / 2 - data.size.x / 2, 0>
                    data.topoData[i].size = <(ends[i] - starts[i]) * data.size.x, data.size.y, 0>
                }
                break
            case eDirection.up:
            case eDirection.down:
                for (int i = 0; i < data.segments; i++)
                {
                    data.topoData[i].position = data.position
                    data.topoData[i].angles = data.angles + <starts[i] * data.size.y + (ends[i] - starts[i]) * data.size.y / 2 - data.size.y / 2, 0, 0>
                    data.topoData[i].size = <data.size.x, (ends[i] - starts[i]) * data.size.y, 0>
                }
        }
    }
    else
    {
        data.topoData[0].size = Vector( width, height, 0.0 )
        data.topoData[0].angles = _angles
    }
    return data
}

void function UpdateBar( var topo, vector posOffset, vector angles, float hudWidth, float hudHeight )
{
    if (hudWidth < 0 || hudHeight < 0)
    {
        throw "hudWidth and hudHeight must be positive! They were " + hudWidth + " and " + hudHeight
    }

    RuiTopology_UpdatePos( topo, COCKPIT_RUI_OFFSET + posOffset, AnglesToRight( angles ), 
        AnglesToUp( angles ) * -1 )
    RuiTopology_UpdateSphereArcs( topo, hudWidth, hudHeight, 3 )
}
#endif