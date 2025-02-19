extends Object
class_name GameBoardLayout

const DEFAULT_STATE = -1
const LEVEL_CONST_TUTORIAL = 202003200000

var board_list:Array
var gbl_state:int = DEFAULT_STATE
var flx_rng:FlxRandom

func init(level : int):
	@warning_ignore("integer_division")
	if level / 1000:
		@warning_ignore("integer_division")
		if LEVEL_CONST_TUTORIAL == level:
			gbl_state = 0
			board_list=[2,3,2,
						3,2,1,
						1,1,3]
	else:
		flx_rng = FlxRandom.new()
		flx_rng.init(level)
	
	
func next():
	if gbl_state == DEFAULT_STATE:
		return flx_rng.Int(0, PuzzleItem.Max)
	var ret = board_list[gbl_state]
	gbl_state += 1
	return ret
