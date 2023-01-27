global function Armor_Create
global function StringToArmorData
global function ArmorDataToString
global function RandomFloatRangeExcludeInner
global function RandomIntRangeOuterRange
global function SetArmorStat
global function GetArmorStat

enum ArmorType
{
    NORMAL,
    BALANCED,
    GOD_ROLL
}

global struct ArmorData
{
    string name = "Factory Issue Armor"
    string rarity = "contextual"
    int slot = 0
    //int minPoints = 56
    //int maxPoints = 80
    bool randomlyGeneratedStats = true


    int mobility = 0 // +0.5% base speed
    int recovery = 0 // AS PILOT, +2% healing from damage at close range.
    int resilience = 0 // +1 base HP per point
    int strength = 0 // AS TITAN, +1% offensive cooldown rate
    int discipline = 0 // AS TITAN, +1% utility cooldown rate
    int intelligence = 0 // AS TITAN, +1% defensive cooldown rate
    int total = 0
    //int power = 1
}

float highestSpikeRating = 0.0
ArmorData function Armor_Create( string name, string rarity )
{
    if (rarity == RARITY_EXOTIC)
        return Armor_CreateExotic( name )
    ArmorData data
    data.name = name
    data.rarity = rarity
    data.slot = RandomIntRange(0,4)

    array<string> pilotGroup = ["mobility", "resilience", "recovery"]
    array<string> titanGroup = ["strength", "intelligence", "discipline"]

    int titanPoints = 0
    int pilotPoints = 0

    int totalMin = int(GraphCapped( GetRarityValue(rarity), 0, 3, 5, 24 ))
    int totalMax = int(GraphCapped( GetRarityValue(rarity), 0, 3, 12, 34 ))
    printt(totalMin, "-", totalMax)
    int total = RandomIntRangeInclusive( totalMin, totalMax )
    printt("TOTAL:", total)

    array<float> pilotWeights = [RandomFloatRange(0.2, 1.0), RandomFloatRange(0.2, 1.0), RandomFloatRange(0.2, 1.0)]
    pilotWeights.sort()
    array<float> titanWeights = [RandomFloatRange(0.2, 1.0), RandomFloatRange(0.2, 1.0), RandomFloatRange(0.2, 1.0)]
    titanWeights.sort()

    float totalWeight = pilotWeights[0] + pilotWeights[1] + pilotWeights[2]
    for (int i = 0; i < 3; i++)
        pilotWeights[i] /= totalWeight
        
    totalWeight = titanWeights[0] + titanWeights[1] + titanWeights[2]
    for (int i = 0; i < 3; i++)
        titanWeights[i] /= totalWeight
     
    float spikeRatingPilot = (pilotWeights[2] - pilotWeights[0]) / 2.0 + (pilotWeights[2] - pilotWeights[1]) / 2.0
    float pilotMultiplier = GraphCapped( spikeRatingPilot, 0, 0.4, 1, 1.25 )
    float spikeRatingTitan = (titanWeights[2] - titanWeights[0]) / 2.0 + (pilotWeights[2] - pilotWeights[1]) / 2.0
    float titanMultiplier = GraphCapped( spikeRatingTitan, 0, 0.4, 1, 1.25 )
    pilotWeights.randomize()
    titanWeights.randomize()

    foreach (int i, string stat in pilotGroup) 
    {
        pilotPoints += int(pilotWeights[i] * total * pilotMultiplier)
        printt(stat, "WEIGHT:", pilotWeights[i], "TOTAL:", total, "SPIKE RATING:", spikeRatingPilot)
        SetArmorStat(data, stat, int(pilotWeights[i] * total * pilotMultiplier))
    }
    
    if (spikeRatingPilot > highestSpikeRating)
        highestSpikeRating = spikeRatingPilot
    if (spikeRatingTitan > highestSpikeRating)
        highestSpikeRating = spikeRatingTitan

    foreach (int i, string stat in titanGroup)
    {
        titanPoints += int(titanWeights[i] * total * titanMultiplier)
        printt(stat, "WEIGHT:", titanWeights[i], "TOTAL:", total, "SPIKE RATING:", spikeRatingTitan)
        SetArmorStat(data, stat, int(titanWeights[i] * total * titanMultiplier))
    }

    printt("\nHIGHEST SPIKE RATING:", highestSpikeRating)

    data.total = titanPoints + pilotPoints
    return data
}

ArmorData function Armor_CreateExotic( string name )
{
    ArmorData data
    data.name = name
    data.rarity = RARITY_EXOTIC
    data.slot = 4

    array<string> pilotGroup = ["resilience", "recovery", "mobility"]
    array<string> titanGroup = ["strength", "discipline", "intelligence"]

    int titanPoints = 0
    int pilotPoints = 0

    string stat = pilotGroup.getrandom()
    int val = 35
    SetArmorStat(data, stat, val)
    pilotPoints += val
    pilotGroup.remove(pilotGroup.find(stat))

    stat = pilotGroup.getrandom()
    val = 15 // 6
    SetArmorStat(data, stat, val)
    pilotPoints += val
    pilotGroup.remove(pilotGroup.find(stat))
    
    stat = pilotGroup[0]
    val = 0 // 2
    SetArmorStat(data, stat, val)
    pilotPoints += val

    /// TITAN ///

    stat = titanGroup.getrandom()
    val = 35 // 10
    SetArmorStat(data, stat, val)
    titanPoints += val
    titanGroup.remove(titanGroup.find(stat))

    stat = titanGroup.getrandom()
    val = 15 // 8
    SetArmorStat(data, stat, val)
    titanPoints += val
    titanGroup.remove(titanGroup.find(stat))
    
    stat = titanGroup[0]
    val = 0 // 2
    SetArmorStat(data, stat, val)
    titanPoints += val

    data.total = titanPoints + pilotPoints
    return data
}

float function RandomFloatRangeExcludeInner( float min, float max, float excludeInner )
{
    float range = max - min - excludeInner * 2.0
    print(range)
    float average = (max + min) / 2.0
    float selection = RandomFloatRange(0, range)
    printt(min, "-", average - excludeInner, average + excludeInner, "-", max)
    if (selection > range / 2)
        selection += excludeInner * 2
    return selection + min
}

int function RandomIntRangeOuterRange( int min, int max, int outerRange )
{
    printt(min, "-", min + outerRange, max - outerRange, "-", max)
    int selection = RandomIntRange(0, (outerRange + 1) * 2)
    if (selection > outerRange)
        return max - (outerRange * 2) + selection - 1
    return selection + min
}

/*ArmorData function Armor_Generate( ArmorData d )
{
    
}*/

void function SetArmorStat( ArmorData data, string stat, int value )
{
    switch (stat)
    {
        case "resilience":
            data.resilience = value
            break
        case "mobility":
            data.mobility = value
            break
        case "strength":
            data.strength = value
            break
        case "discipline":
            data.discipline = value
            break
        case "intelligence":
            data.intelligence = value
            break
        case "recovery":
            data.recovery = value
            break
    }
}

int function GetArmorStat( ArmorData data, string stat )
{
    switch (stat)
    {
        case "resilience":
            return data.resilience
            break
        case "mobility":
            return data.mobility
            break
        case "strength":
            return data.strength
            break
        case "discipline":
            return data.discipline
            break
        case "intelligence":
            return data.intelligence
            break
        case "recovery":
            return data.recovery
            break
    }
    return 0
}

ArmorData function StringToArmorData( string str )
{
    ArmorData data

    array<string> strdata = split( str, "," )

    data.name = strdata[0]
    data.rarity = strdata[1]
    data.slot = int(strdata[2])
    data.mobility = int(strdata[3])
    data.recovery = int(strdata[4])
    data.resilience = int(strdata[5])
    data.strength = int(strdata[6])
    data.intelligence = int(strdata[7])
    data.discipline = int(strdata[8])

    for (int i = 3; i <= 8; i++)
    {
        data.total += int(strdata[i])
    }

    return data
}

string function ArmorDataToString( ArmorData data )
{
    return data.name + "," 
    + data.rarity + "," 
    + data.slot + "," 
    + data.mobility + "," 
    + data.recovery + "," 
    + data.resilience + "," 
    + data.strength + "," 
    + data.intelligence + "," 
    + data.discipline
}

int function GetRarityValue( string rarity )
{
    switch (rarity)
    {
        case RARITY_COMMON:
            return 0
        case RARITY_UNCOMMON:
            return 1
        case RARITY_RARE:
            return 2
        case RARITY_EXOTIC:
        case RARITY_LEGENDARYARMOR:
            return 3
    }
    return -1
}