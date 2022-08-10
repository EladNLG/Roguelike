globalize_all_functions

global struct Choice
{
    string a
    string b
    void functionref ( int ) onChosen
}

struct
{
    array<Choice ornull functionref()> choiceQueue
    Choice& currentChoice
    array<int> loadoutIndexes
    bool isMakingChoice = false
} file

array<string> loadouts = [
    "Expedition",
    "Tone",
    "Scorch",
    "Brute",
    "Ion",
    "Ronin",
    "Northstar",
    "Legion"
]

void function Upgrades_Init()
{
    AddClientCommandCallback( "choose", OnChoose )
    #if SP
    AddCallback_OnLevelEnd( OnLevelEnd )
    #endif
}

void function OnLevelEnd( string map, LevelTransitionStruct trans )
{
    UnlockLoadouts()
}

int function BTLoadoutToIndex( string loadout )
{
    foreach (int index, string l in loadouts)
        if (l == loadout) return index

    return -1
}

void function UnlockLoadouts()
{
    AddChoicesToQueue( [UnlockLoadout, UnlockLoadout] )
}

Choice ornull function UnlockLoadout()
{
    entity player = GetPlayerArray()[0]
    array<string> choices
    foreach (int index, string l in loadouts)
    {
        if (!IsBTLoadoutUnlocked( index ))
            choices.append(l)
        if (choices.len() == 2)
            break
    }

    print(choices.len())

    if (choices.len() == 1)
    {
        SetBTLoadoutUnlocked( BTLoadoutToIndex( choices[0] ) )
        return null
    }
    else if (choices.len() < 1)
        return null
        
    Choice c
    c.a = choices[0]
    c.b = choices[1]
    c.onChosen = LoadoutChosen
    file.loadoutIndexes.clear()
    file.loadoutIndexes.append(BTLoadoutToIndex( choices[0] ))
    file.loadoutIndexes.append(BTLoadoutToIndex( choices[1] ))

    return c
}

void function LoadoutChosen( int choice )
{
    switch (choice)
    {
        case 0:
        case 1:
            SetBTLoadoutUnlocked( file.loadoutIndexes[0] ) 
            break
        case 2:
            SetBTLoadoutUnlocked( file.loadoutIndexes[1] ) 
            break
    }
}

bool function OnChoose( entity player, array<string> args )
{
    if (args.len() < 1)
        return true

    int choice = int(args[0])

    if (file.currentChoice.onChosen != null)
        file.currentChoice.onChosen( choice )

    file.choiceQueue.remove(0)

    if (file.choiceQueue.len() > 0)
        MakeChoice( file.choiceQueue[0]() )
    else 
    {
        GetPlayerArray()[0].Signal("PlayerDoneSelecting")
        file.isMakingChoice = false
    }
    return true
}

void function MakeChoice( Choice ornull c )
{
    if (c == null)
    {
        file.choiceQueue.remove(0)

        if (file.choiceQueue.len() > 0)
            MakeChoice( file.choiceQueue[0]() )
        else 
        {
            foreach (entity player in GetPlayerArray())
                player.Signal("PlayerDoneSelecting")
            file.isMakingChoice = false
        }
        return
    }
    expect Choice( c )
    ServerToClientStringCommand( GetPlayerArray()[0], "choice " + c.a + "|" + c.b )
    file.currentChoice = c
    file.isMakingChoice = true
}

void function AddChoiceToQueue( Choice ornull functionref() c )
{
    file.choiceQueue.append(c)
    if (!file.isMakingChoice)
        MakeChoice(c())
}

void function AddChoicesToQueue( array<Choice ornull functionref()> c )
{
    if (c.len() < 1)
        return
    file.choiceQueue.extend(c)
    if (!file.isMakingChoice)
        MakeChoice(c[0]())
}

