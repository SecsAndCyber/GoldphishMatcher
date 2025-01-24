extends PlayState
class_name ReplayState

@export var moves_to_replay = ["21", "01", "A1"]
var replay_array : Array
var replay_level = 1

var step_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_replay_setup")
	if not 'root' == get_parent().name:
		retry_button.queue_free()
		next_button.queue_free()
		current_level.visible = false
		current_score.visible = false
		run_score.visible = false
	
func do_replay_setup():
	if Reg.LastMoves:
		moves_to_replay =  Reg.LastMoves
		replay_level = Reg.LastLevel
	Reg.Replay = ceilf(replay_level * 0.08)
	Reg.Levels = replay_level
	replay_array = moves_to_replay.duplicate(true)
	Reg.Loss = false
	Reg.PS = self
	
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
	if ! board.selector.blocks or ! board.selector.blocks[0]: return
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
	check_button.button_pressed = false
	check_button.disabled = false
	call_deferred("do_setup")
	_on_check_button_toggled(true)


func _on_check_button_toggled(toggled_on: bool) -> void:
	do_replay_setup()
	check_button.button_pressed = toggled_on
