extends PlayState
class_name ReplayState

var replay_array = ["A-1", "A-1", "31", "B-1", "0-1", "A1"]
var replay_level = 8 #	275	

var step_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	Reg.Replay = ceilf(replay_level * 0.08)
	Reg.Levels = replay_level
	call_deferred("do_replay_setup")
	
func do_replay_setup():
	# Do initialization here
	pass
	
func _process(delta: float) -> void:
	super._process(delta)
	
	if !check_button.button_pressed: return
	check_button.disabled = true
	
	if(board.rebuilding): return
	if(board.matching): return
	if(board.moving): return
	if(!board.ready_for_input): return
	if !board.selector.cleared and !board.selector.visible: return
	if board.selector.toast_text.visible: return
	if step_active: return
	
	if replay_array:
		do_next_step(replay_array[0])
		replay_array = replay_array.slice(1)

@onready var check_button: CheckButton = $CheckButton
		
func do_next_step(step_instruction):
	step_active = true
	var rc = step_instruction[0]
	var delta = int(step_instruction.trim_prefix(rc))
	var source:Vector2 = Vector2.ZERO
	var target:Vector2 = Vector2.ZERO
	
	if rc in board.LETTERS:
		get_tree().create_timer(.05).timeout.connect(func():
				board.selector.SelectionX = 1
				board.selector.SelectionY = board.LETTERS.find(rc)
				source = board.selector.selection
				get_tree().create_timer(.05).timeout.connect(func():
					board.selector.SelectionX = source.x - delta
					board.selector.SelectionY = source.y
					target = board.selector.selection
					get_tree().create_timer(.05).timeout.connect(func():
						board.swap_spots(source, target)
						step_active = false
					)
				)
		)
		
	else:
		get_tree().create_timer(.025).timeout.connect(func():
				board.selector.SelectionX = int(rc)
				board.selector.SelectionY = 1
				source= board.selector.selection
				get_tree().create_timer(.025).timeout.connect(func():
					board.selector.SelectionX = source.x
					board.selector.SelectionY = source.y - delta
					target = board.selector.selection
					get_tree().create_timer(.025).timeout.connect(func():
						board.swap_spots(source, target)
						step_active = false
					)
				)
		)
	
func popup():
	check_button.disabled = false


func _on_check_button_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
