extends PlayState
class_name ReplayState

@export var moves_to_replay = ["41", "B1", "A-1", "41", "A1", "A1", "41", "41", "C1", "01", "C-1", "B-1", "0-1", "01", "D-1", "D-1", "01", "D1", "D1", "0-1", "E1", "01", "C-1", "01", "01", "E1", "E1", "E1", "0-1", "E-1", "E-1", "E-1", "01", "0-1", "E-1", "01", "C-1", "C-1", "C-1", "C-1", "0-1", "D-1", "01", "01"]
var replay_array : Array
var replay_level = 6

var step_active: bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	if 'root' == get_parent().get_parent().name:
		# Running Replay Scene directly!
		Reg.Levels = replay_level
	call_deferred("do_replay_setup")
	if not 'root' == get_parent().get_parent().name:
		retry_button.visible = false
		next_button.visible = false
		current_level.visible = false
		current_score.visible = false
	
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
	_process_clicker(delta)
	
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
				move_clicker_to_selector(func():
				# get_tree().create_timer(.05).timeout.connect(func():
					board.selector.SelectionX = source.x - delta
					board.selector.SelectionY = source.y
					var target:Vector2i = Vector2i.ZERO
					target = board.selector.selection
					move_clicker_to_selector(func():
					# get_tree().create_timer(.05).timeout.connect(func():
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
				move_clicker_to_selector(func():
				#get_tree().create_timer(.025).timeout.connect(func():
					board.selector.SelectionX = source.x
					board.selector.SelectionY = source.y - delta
					var target:Vector2i = Vector2i.ZERO
					target = board.selector.selection
					move_clicker_to_selector(func():
					# get_tree().create_timer(.025).timeout.connect(func():
						board.swap_spots(source, target)
						step_active = false
					)
				)
		)
	
func popup(_level_stats:Dictionary = {}):
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
	
@onready var clicker: Control = $Clicker
var clicker_dest: Vector2
var clicker_callables = []
var clicker_speed: float = 10
var clicker_done: bool = true
func _process_clicker(delta: float):
	if clicker_done:
		return
	var clicker_delta = clicker_dest.distance_squared_to(clicker.global_position)
	clicker.global_position.x = lerp(
		clicker.global_position.x,
		clicker_dest.x,
		clicker_speed * delta
	)
	clicker.global_position.y = lerp(
		clicker.global_position.y,
		clicker_dest.y,
		clicker_speed * delta
	)
	if clicker_delta < 1:
		board.selector.visible = true
		clicker_done = true
		if clicker_callables:
			var next = clicker_callables[0]
			clicker_callables = clicker_callables.slice(1)
			get_tree().create_timer(0).timeout.connect(next)
func move_clicker_to_selector(callable:Callable):
	clicker_dest = board.selector.target_position
	board.selector.visible = false
	clicker_callables.append(callable)
	clicker_done = false
	
	
	
	
	
	
	
