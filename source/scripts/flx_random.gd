extends Object
class_name FlxRandom
'''
	This script is a port of flixel/math/FlxRandom.hx

	https://github.com/HaxeFlixel/flixel/blob/master/LICENSE.md
	The MIT License (MIT)
'''

'''
	 * Constants used in the pseudorandom number generation equation.
	 * These are the constants suggested by the revised MINSTD pseudorandom number generator,
	 * and they use the full range of possible integer values.
	 *
	 * @see http://en.wikipedia.org/wiki/Linear_congruential_generator
	 * @see Stephen K. Park and Keith W. Miller and Paul K. Stockmeyer (1988).
	 *      "Technical Correspondence". Communications of the ACM 36 (7): 105–110.
'''
const MAX_VALUE_INT:int = 0x7FFFFFFF
const MIN_VALUE_INT:int = -MAX_VALUE_INT
const MODULUS:int = MAX_VALUE_INT
const MULTIPLIER:float = 48271.0;
var rng = RandomNumberGenerator.new()

var internalSeed:float = 1.0
var initialSeed:int:
	set(value): internalSeed = value
	
var currentSeed:int:
	set(value): internalSeed = value
	get(): return int(internalSeed)

func init(InitialSeed:int = MIN_VALUE_INT):
	if InitialSeed != MIN_VALUE_INT:
		initialSeed = InitialSeed
	else:
		resetInitialSeed()

func resetInitialSeed() -> int:
	initialSeed = rangeBound(rng.randi() * MAX_VALUE_INT);
	return initialSeed

func Int(Min:int = 0, Max:int = MAX_VALUE_INT, Excludes = null)-> int:
	'''
	 * Returns a pseudorandom integer between Min and Max, inclusive.
	 * Will not return a number in the Excludes array, if provided.
	 * Please note that large Excludes arrays can slow calculations.
	 *
	 * @param   Min        The minimum value that should be returned. 0 by default.
	 * @param   Max        The maximum value that should be returned. 2,147,483,647 by default.
	 * @param   Excludes   Optional array of values that should not be returned.
	 */
	'''
	if (Min == 0 && Max == MAX_VALUE_INT && Excludes == null):
		return int(generate())
	if (Min == Max):
		return Min
	else:
		# Swap values if reversed
		if Min > Max:
			Min = Min + Max
			Max = Min - Max
			Min = Min - Max

		if Excludes == null:
			return floor(Min + generate() / MODULUS * (Max - Min + 1))
		else:
			var result:int = Excludes[0]
			while (Excludes.indexOf(result) >= 0):
				result = floor(Min + generate() / MODULUS * (Max - Min + 1));

			return result
			
func generate() -> float:
	internalSeed = int(internalSeed * MULTIPLIER) % MODULUS;
	return internalSeed
	
static func rangeBound(Value:int) -> int:
	return clamp(Value, 1, MODULUS - 1)
