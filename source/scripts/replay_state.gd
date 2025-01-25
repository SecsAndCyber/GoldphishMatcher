extends PlayState
class_name ReplayState

@export var moves_to_replay = ["2-1", "B-1", "21", "1-1", "1-1", "31", "31", "B1", "3-1", "3-1", "31", "31", "31", "0-1", "A1", "0-1"]
var replay_array : Array
var replay_level = 3

var step_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if 'root' == get_parent().get_parent().name:
		# Running Replay Scene directly!
		Reg.Levels = replay_level
	call_deferred("do_replay_setup")
	if not 'root' == get_parent().get_parent().name:
		retry_button.queue_free()
		next_button.queue_free()
		current_level.visible = false
		current_score.visible = false
		run_score.visible = false
	
func do_replay_setup():
	if Reg.LastMoves:
		moves_to_replay =  Reg.LastMoves
		replay_level = Reg.LastLevel
	Reg.Replay = ceili(replay_level * 0.08)
	Reg.Levels = replay_level
	replay_array = moves_to_replay.duplicate(true)
	Reg.Loss = false
	background.texture = BG_TEXTURE_NORMAL
	foreground.texture = FG_TEXTURE_NORMAL
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
	
	if rc in board.LETTERS:
		get_tree().create_timer(.05).timeout.connect(func():
				board.selector.SelectionX = 1
				board.selector.SelectionY = board.LETTERS.find(rc)
				var source:Vector2i = Vector2i.ZERO
				source = board.selector.selection
				get_tree().create_timer(.05).timeout.connect(func():
					board.selector.SelectionX = source.x - delta
					board.selector.SelectionY = source.y
					var target:Vector2i = Vector2i.ZERO
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
				var source:Vector2i = Vector2i.ZERO
				source= board.selector.selection
				get_tree().create_timer(.025).timeout.connect(func():
					board.selector.SelectionX = source.x
					board.selector.SelectionY = source.y - delta
					var target:Vector2i = Vector2i.ZERO
					target = board.selector.selection
					get_tree().create_timer(.025).timeout.connect(func():
						board.swap_spots(source, target)
						step_active = false
					)
				)
		)
	
func popup():
	if Reg.Loss:
		background.texture = BG_TEXTURE_LOSS
		foreground.texture = FG_TEXTURE_LOSS
	get_tree().create_timer(4).timeout.connect(func():
		# This delay is necessary for the texture swap to show up
		check_button.button_pressed = false
		check_button.disabled = false
		super.do_setup()
		_on_check_button_toggled(true)
	)


func _on_check_button_toggled(toggled_on: bool) -> void:
	do_replay_setup()
	check_button.button_pressed = toggled_on
