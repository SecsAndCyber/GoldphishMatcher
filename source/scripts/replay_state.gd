extends PlayState
class_name ReplayState

var replay_array = ["A1", "6-1", "7-1", "7-1", "71", "A1", "6-1", "6-1", "5-1", "A1", "71", "7-1", "A1", "71", "71", "A1", "71", "71", "71", "A1", "A1", "A1", "51", "51", "A1", "5-1", "A1", "A1", "5-1", "A1", "A1", "5-1", "5-1", "5-1", "A1", "A1", "5-1", "21", "21", "A-1", "A-1", "A1", "A-1", "5-1", "A1", "51", "41", "A1", "41", "41", "A-1", "A1", "A1", "41", "A-1", "A-1", "7-1", "4-1", "A1", "4-1", "31", "A1", "A1", "3-1", "4-1", "A1", "41", "71", "H1", "7-1", "H-1", "11", "11", "A-1", "A1", "21", "A1", "21", "21", "A-1", "2-1", "A-1", "2-1", "A-1", "11", "A-1", "11", "A1", "A1", "A1", "11", "11", "11", "11", "11", "A-1", "A1", "11", "A-1", "1-1", "A-1", "A-1", "1-1", "A1", "01", "A-1", "01", "01", "01", "A-1", "01", "A-1", "A-1", "0-1", "01", "01", "01", "01", "01", "A1", "A1", "A1", "0-1", "A1", "0-1", "2-1", "A-1", "21", "A1", "H1", "H1", "1-1"]
var replay_level = 20

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Reg.Replay = true
	Reg.Levels = replay_level
	call_deferred("do_replay_setup")
	
func do_replay_setup():
	# Do initialization here
	pass
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if check_button.button_pressed: return
	
	if(board.rebuilding): return
	if(board.matching): return
	if(board.moving): return
	if(!board.ready_for_input): return
	if !board.selector.cleared and !board.selector.visible: return
	if board.selector.toast_text.visible: return
	
	if replay_array:
		do_next_step(replay_array[0])
		replay_array = replay_array.slice(1)

@onready var check_button: CheckButton = $CheckButton
		
func do_next_step(step_instruction):
	var rc = step_instruction[0]
	var delta = int(step_instruction.trim_prefix(rc))
	var source:Vector2 = Vector2.ZERO
	var target:Vector2 = Vector2.ZERO
	
	if rc in board.LETTERS:
		board.selector.SelectionX = 1
		board.selector.SelectionY = board.LETTERS.find(rc)
		source = board.selector.selection
		
		board.selector.SelectionX = source.x - delta
		board.selector.SelectionY = source.y
		target = board.selector.selection
	else:
		board.selector.SelectionX = int(rc)
		board.selector.SelectionY = 1
		source= board.selector.selection
		
		board.selector.SelectionX = source.x
		board.selector.SelectionY = source.y - delta
		target = board.selector.selection
	board.swap_spots(source, target)
	
func popup():
	pass


func _on_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
