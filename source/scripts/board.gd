extends Control
class_name Board

const LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
var xs: int
var ys: int

var level_block_count: int
var ready_for_input: bool = false

var map : Array
var blocks : Array
var highlight_lines : Array
var moves = []
var offset : Vector2 = Vector2.ZERO

@onready var crackers: Control = $Crackers
@onready var selector: Selector = $Selector.get_node("Selector")
@onready var highlights: Control = $Highlights

var rebuilding:bool = false
var rebuild_speed:float = .25
var moving:bool = false
var moved:bool = false
var rng:FlxRandom

var new_blocks # :Array<Array<Cracker>>;
var new_xs:int
var new_ys:int

var combo_score:int
var combo_count:int

var points_per_fish:int = 5
var cost_per_move:int = -1
var end_only:bool = false

var closing:bool = false
var matching:bool = false
var dragged:bool = false

var has_match:bool:
	get:
		if matching: return false
		if moved:
			matching = true
			get_tree().create_timer(.05).timeout.connect(func():
				if is_match():
					draw_highlights()
					get_tree().create_timer(.05).timeout.connect(func():
						matching = false
					)
				else:
					matching = false
			)
		for c in range(0,xs):
			if(map[0][c]): return true
		for r in range(0,ys):
			if(map[1][r]): return true
		return false

var _score:int;
var score:int:
	set(val):
		_score = clampi(val,0,0x999999)
		Reg.Score = _score;
		return _score;
	get:
		return clampi(_score,0,0x999999)
	
func create(x_size, y_size):
	crackers.visible = true
	for hl in highlights.get_children():
		highlights.remove_child(hl)
		hl.queue_free()
	for cr in crackers.get_children():
		crackers.remove_child(cr)
		cr.queue_free()
	Reg.HiScoreSet = false
	rebuilding = false
	rebuild_speed = .25
	moving = false
	moved = false
	closing = false
	matching = false
	dragged = false
	score = 0
	combo_score = 0
	combo_count = 0
	xs = x_size
	ys = y_size
	level_block_count = x_size * y_size
	rng = FlxRandom.new()
	rng.init(Reg.Levels)
	
	blocks = []
	for r in range(xs):
		blocks.append([])
		for c in range(ys):
			blocks[r].append(null)
			blocks[r][c] = PuzzleItem.new()
			blocks[r][c].init(rng.Int(0, PuzzleItem.Max), r, c)
			blocks[r][c].clicked.connect(on_puzzle_item_click)
			crackers.add_child(blocks[r][c])
			blocks[r][c].position.x = r * blocks[r][c].size.x * blocks[r][c].scale.x
			blocks[r][c].position.y = c * blocks[r][c].size.y * blocks[r][c].scale.x
	offset = blocks[0][0].size * blocks[0][0].scale * .5
	map = [[],[]]
	highlight_lines = [[],[]]
	for r in range(xs):
		map[0].append(false)
		var line_obj = new_line(r,len(highlight_lines[0]),'x')
		highlight_lines[0].append(line_obj)
		highlights.add_child(line_obj)
	for c in range(ys):
		map[1].append(false)
		var line_obj = new_line(len(highlight_lines[1]),c,'y')
		highlight_lines[1].append(line_obj)
		highlights.add_child(line_obj)
	ready_for_input = true

func new_line(r,c,angle) -> Line2D:
	var _nl = Line2D.new()
	if angle == 'x':
		_nl.add_point(Vector2(blocks[r][0].position.x,blocks[r][0].position.y)+offset)
		_nl.add_point(Vector2(blocks[r][ys-1].position.x,blocks[r][ys-1].position.y)+offset)
	if angle == 'y':
		_nl.add_point(Vector2(blocks[0][c].position.x,blocks[0][c].position.y)+offset)
		_nl.add_point(Vector2(blocks[xs-1][c].position.x,blocks[xs-1][c].position.y)+offset)
	_nl.visible = false
	return _nl

func fix_line(line2d, r,c,angle) -> Line2D:
	if angle == 'x':
		line2d.points[0] = Vector2(blocks[r][0].position.x,blocks[r][0].position.y)+offset
		line2d.points[1] = Vector2(blocks[r][ys-1].position.x,blocks[r][ys-1].position.y)+offset
	if angle == 'y':
		line2d.points[0] = Vector2(blocks[0][c].position.x,blocks[0][c].position.y)+offset
		line2d.points[1] = Vector2(blocks[xs-1][c].position.x,blocks[xs-1][c].position.y)+offset
	return line2d

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in crackers.get_children():
		crackers.remove_child(n)
		n.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(closing): return
	if (Reg.Loss):
		closing = true;
		ready_for_input = false
		crackers.visible = false
		Reg.HiScoreSet = false;
		selector.toast("Failed");
		Reg.Sounds.level_lost();
		if !Reg.Replay:
			Reg.LastLevel = Reg.Levels
			Reg.LastMoves = moves
			Reg.telemetryNode.failed_level(moves)
			get_tree().create_timer(3).timeout.connect(func():
				Reg.saveScore();
				Reg.PS.change_scene_to_file("res://source/failed_state.tscn")
			)
		else:
			Reg.PS.popup()
			return
	if(!blocks_correct(rebuild_speed)): return;
	if(matching): return;
	moving = false;
	if(!has_match && !moved):
		ready_for_input = true
		combo_score = 0;
		combo_count = 0;
	if has_match:
		handle_match_state()
		return
	ready_for_input = not (rebuilding or matching or moving)
	
func swap_spots(source:Vector2, target:Vector2):
	ready_for_input = false
	moving = true
	rebuild_speed = .25
	var tmpBlockTarget:PuzzleItem = blocks[target.x][target.y]
	var tmpBlockSource:PuzzleItem = blocks[source.x][source.y]
	var delta = Vector2(
					source.x - target.x,
					source.y - target.y
				)
	if delta.x == 0:
		moves.append(str(source.x) + str(delta.y))
		Reg.Sounds.row_shift()
	else:
		moves.append(str(LETTERS[source.y]) + str(delta.x))
		Reg.Sounds.col_shift()
	blocks[source.x][source.y] = null;
	score = score + cost_per_move;
	while(tmpBlockTarget != null):
		blocks[target.x][target.y] = tmpBlockSource;
		tmpBlockSource = tmpBlockTarget;
		source.x = target.x;
		source.y = target.y;
		target.x = int(xs + source.x - delta.x) % xs;
		target.y = int(ys + source.y - delta.y) % ys;
		tmpBlockTarget = blocks[target.x][target.y];
	blocks[target.x][target.y] = tmpBlockSource;
	moved = true;

func get_game_state():
	var columns = []
	var rows = []
	for c in range(xs):
		columns.append(1)
	for r in range(ys):
		rows.append(1)
	var items_count = {}
	for c in range(xs):
		for r in range(ys):
			var item_value:int = blocks[c][r].Value;
			rows[r] *= item_value
			columns[c] *= item_value
			items_count[item_value] = items_count.get(item_value,0) + 1
	# Test for softlock
	var _loss = true;
	for count in items_count:
		if items_count[count] >= min(xs, ys):
			_loss = false
	Reg.Loss = _loss
	return [rows, columns]

func is_match() -> bool:
	var sweep_up:bool = true
	var game_state = get_game_state()
	var rows = game_state[0]
	var columns = game_state[1]
	end_only = true
	var mini_combo:int = 1
	var points_gained:int = 0
	
	for i in range(ys):
		if(xs > 1 || sweep_up):
			map[1][i] = rows[i] == pow(blocks[0][i].Value, xs)
		if(xs > 1 && map[1][i]):
			if(i+1 != ys): end_only = false
			points_gained += Reg.Levels * points_per_fish * mini_combo
			mini_combo += 1
			
	for i in range(xs):
		if(ys > 1 || sweep_up):
			map[0][i] = columns[i] == pow(blocks[i][0].Value, ys);
		if(ys > 1 && map[0][i]):
			if(i+1 != xs): end_only = false
			points_gained += Reg.Levels * points_per_fish * mini_combo
			mini_combo += 1
	if(points_gained > 0):
		combo_count += 1;
		combo_score += points_gained * combo_count;
		score += combo_score;
		Reg.Sounds.score(combo_count);
		selector.toast(str(combo_score));
	moved = false
	return bool(points_gained)

func blocks_correct(speed:float) -> bool:
	if(rebuilding): return false
	var blocks_moved = false
	
	if Reg.Replay:
		speed = float(Reg.Replay) * speed
	
	for r in range(xs):
		for c in range(ys):
			var block:PuzzleItem = blocks[r][c]
			block.current_location = Vector2(r,c)
			var destination:Vector2 = Vector2(
				r * blocks[r][c].size.x * blocks[r][c].scale.x,
				c * blocks[r][c].size.y * blocks[r][c].scale.x
			)
			if abs(block.position.x - destination.x) > 1:
				block.position.x = lerp(block.position.x, destination.x, speed)
				blocks_moved = true
			else:
				block.position.x = destination.x
			if abs(block.position.y - destination.y) > 1:
				block.position.y = lerp(block.position.y, destination.y, speed)
				blocks_moved = true
			else:
				block.position.y = destination.y
	if !blocks_moved and !matching:
		for r in range(xs):
			for c in range(ys):
				highlight_lines[0][r] = fix_line(highlight_lines[0][r],r,c,'x')
				highlight_lines[1][c] = fix_line(highlight_lines[1][c],r,c,'y')
	return !blocks_moved

func handle_match_state():
	if(rebuilding): return
	rebuilding = true
	rebuild_speed = .05;
	new_xs = xs;
	new_ys = ys;
	
	for c in range(xs):
		if map[0][c]:
			new_xs -= 1
	for r in range(ys):
		if map[1][r]:
			new_ys -= 1
	if new_ys > 0 and new_xs > 0:
		var rebuild_delay:float = .25;
		if end_only:
			rebuild_delay += .25;
		get_tree().create_timer(rebuild_delay).timeout.connect(func():
			hide_highlights()
			var selected_point:Vector2i = Vector2i(selector.selection.x,selector.selection.y)
				
			new_blocks = []
			var new_r:int = 0;
			for r in range(xs):
				if !map[0][r]:
					new_blocks.append([])
				for c in range(ys):
					var block: PuzzleItem = blocks[r][c]
					if map[1][c] or map[0][r]:
						crackers.remove_child(block)
					else:
						new_blocks[new_r].append(block)
						var new_c: int = len(new_blocks[new_r]) - 1
						block.current_location = Vector2i(new_r, new_c)
						if selector.selection == Vector2i(r,c):
							selected_point.x = new_r;
							selected_point.y = new_c;
				if !map[0][r]:
					new_r += 1
			blocks = new_blocks
			xs = new_xs
			ys = new_ys
			map = [[],[]]
			
			for r in range(xs):
				map[0].append(false)
			for c in range(ys):
				map[1].append(false)
			
			selector.clear()
			rebuilding = false
			moved = true
		)
	else:
		# End of level
		var end_delay:float = .5;
		get_tree().create_timer(end_delay).timeout.connect(func():
			if new_ys > 1 or new_xs > 1:
				crackers.visible = false
				selector.toast("[center]Cleared!\n+"+str(level_block_count));
				score += level_block_count;
				# Reassigning lambda capture does not modify the outer local variable "end_delay"
				@warning_ignore("CONFUSABLE_CAPTURE_REASSIGNMENT")
				end_delay = 2.5;
			hide_highlights()
			
			get_tree().create_timer(end_delay).timeout.connect(func():
				if ! Reg.Replay:
					Reg.LastLevel = Reg.Levels
					Reg.LastMoves = moves
					Reg.telemetryNode.finish_level(moves, func(result, _response_code, _headers, body):
						if result == HTTPRequest.RESULT_SUCCESS:
							var json = JSON.parse_string(body.get_string_from_utf8())
							Reg.PS.popup(json)
						else:
							print("Request Error:", result)
							Reg.PS.popup()
					)
					# Moving to next level
					if !Reg.Done && Reg.HiScore[0] < Reg.Score + Reg.RunningScore:
						Reg.HiScore[0] = Reg.Score + Reg.RunningScore
					if Reg.Levels in Reg.HiScore:
						if Reg.HiScore[Reg.Levels] < Reg.Score:
							Reg.HiScoreSet = true
							Reg.HiScore[Reg.Levels] = Reg.Score
							Reg.HiScoreMoves[Reg.Levels] = moves
					else:
						Reg.HiScoreSet = true
						Reg.HiScore[Reg.Levels] = Reg.Score
						Reg.HiScoreMoves[Reg.Levels] = moves
					print(moves)
					Reg.saveScore()
					Reg.PS.remove_child(self)
				else:
					Reg.PS.popup()
			)
		)

func draw_highlights():
	for c in range(xs):
		if map[0][c]:
			highlight_lines[0][c].visible = true
	for r in range(ys):
		if map[1][r]:
			highlight_lines[1][r].visible = true
func hide_highlights():
	get_tree().create_timer(.0025).timeout.connect(func():
		for c in range(xs):
			highlight_lines[0][c].visible = false
		for r in range(ys):
			highlight_lines[1][r].visible = false
		for orphan in highlight_lines[0].slice(xs):
			if orphan.get_parent() == highlights:
				highlights.remove_child(orphan)
		for orphan in highlight_lines[1].slice(ys):
			if orphan.get_parent() == highlights:
				highlights.remove_child(orphan)
	)

func on_puzzle_item_click(_puzzle_item:PuzzleItem, location:Vector2i):
	if(Reg.Replay): return
	if(rebuilding): return
	if(matching): return
	if(moving): return
	if !ready_for_input: return
	if !selector.cleared and !selector.visible: return
	var r = location.x
	var c = location.y
	if !selector.cleared and ((
		selector.SelectionX == r and abs(selector.SelectionY - c)==1) or (
		selector.SelectionY == c and abs(selector.SelectionX - r)==1)
		):
			var Source:Vector2 = selector.selection
			var Target:Vector2 = location
			swap_spots(Source, Target)
			selector.clear()
	else:
		selector.SelectionX = location.x
		selector.SelectionY = location.y
