/////////////////////////
// RNG WITH SEED STUFF //
/////////////////////////

globalize_all_functions

struct
{
	table<int, int> stateToSeed
} file

int function xorshift32(int state)
{
	if (state == 0)
		throw "State may not be 0"
	if (!(state in file.stateToSeed))
		file.stateToSeed[state] <- state

	int x = file.stateToSeed[state]

	x = x ^ (x << 13)
	x = x ^ (x >> 17)
	x = x ^ (x << 5)
	file.stateToSeed[state] = x

	return x
}

float function xorshift32f(int state)
{
    return float(xorshift32(state)) / float(0x7fffffff);
}

int backupSeed = 0

void function TestForAverage()
{
	backupSeed = RandomInt(214783647)
}

float function xorshift_range(float min, float max, int state = 0)
{
	if (state == 0) state = GetRoguelikeSeed()
	float frac = fabs(xorshift32f(state) % 1.0)
	if (frac < 0 || frac > 1) throw "tf?"
	if (min > max) throw "min > max"
	float result = min + ((max - min) * frac)
	if (result > max) throw "result > max"
	if (result < min) throw "result > max"
	return result;
}

int function xorshift_range_int(int min, int max, int state = 0)
{
	if (state == 0) state = GetRoguelikeSeed()
	float choice = fabs(xorshift32f(state) % 1.0) * (max - min)
	//print(choice)
	return min + int(choice);
}

int function GetRoguelikeSeed()
{
	int seed = GetConVarInt("roguelike_seed")
	if (backupSeed == 0) TestForAverage()
	if (seed == 0) {
		SetConVarInt("roguelike_seed", backupSeed)
		return backupSeed
	}
	return seed
}