extends Control
class_name Board

const LETTERS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
var xs: int;
var ys: int;

var level_block_count: int;

var map : Array
var blocks : Array
var moves = []

@onready var crackers: Control = $Crackers
@onready var selector: Selector = $Selector.get_node("Selector")

var rebuilding:bool = false;
var rebuild_speed:float = .25;
var moving:bool = false;
var moved:bool = false;
var rng:FlxRandom;

var new_blocks # :Array<Array<Cracker>>;
var new_xs:int;
var new_ys:int;

var combo_score:int;
var combo_count:int;

var points_per_fish:int = 5;
var cost_per_move:int = -1;
var end_only:bool = false;

var closing:bool = false;
var matching:bool = false;
var dragged:bool = false;

var has_match:bool:
	get:
		if matching: return false
		if moved:
			matching = true
			get_tree().create_timer(.05).timeout.connect(func():
				if is_match():
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
	Reg.HiScoreSet = false;
	score = 0
	combo_score = 0
	combo_count = 0
	xs = x_size
	ys = y_size
	level_block_count = x_size * y_size
	map = [[],[]]
	for r in range(xs):
		map[0].append(false)
	for c in range(ys):
		map[1].append(false)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for n in crackers.get_children():
		crackers.remove_child(n)
		n.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if(closing): return
	if (Reg.Loss):
		crackers.visible = false
		closing = true;
		Reg.HiScoreSet = false;
		selector.toast("Failed");
		Reg.Sounds.level_lost();
		Reg.telemetryNode.failed_level(moves)
		get_tree().create_timer(3).timeout.connect(func():
			Reg.saveScore();
			Reg.PS.change_scene_to_file("res://source/failed_state.tscn")
		)
		return
	if(!blocks_correct(rebuild_speed)): return;
	if(matching): return;
	moving = false;
	if(!has_match && !moved):
		combo_score = 0;
		combo_count = 0;
	if has_match:
		handle_match_state()
	
func swap_spots(source:Vector2, target:Vector2):
	moving = true;
	rebuild_speed = .25;
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
	var _loss = len(items_count) == 4;
	for count in items_count:
		if items_count[count] != 1:
			_loss = false
	Reg.Loss = _loss
	return [rows, columns]

func is_match() -> bool:
	var sweep_up:bool = true
	var game_state = get_game_state()
	var rows = game_state[0]
	var columns = game_state[1]
	var scored:bool = false
	end_only = true
	var mini_combo:int = 1
	var points_gained:int = 0
	
	for i in range(ys):
		if(xs > 1 || sweep_up):
			map[1][i] = rows[i] == pow(blocks[0][i].Value, xs)
		if(xs > 1 && map[1][i]):
			if(i+1 != ys): end_only = false
			points_gained += Reg.Levels * points_per_fish * mini_combo
			scored = true
			mini_combo += 1
			
	for i in range(xs):
		if(ys > 1 || sweep_up):
			map[0][i] = columns[i] == pow(blocks[i][0].Value, ys);
		if(ys > 1 && map[0][i]):
			if(i+1 != xs): end_only = false
			points_gained += Reg.Levels * points_per_fish * mini_combo
			scored = true
			mini_combo += 1
	if(points_gained > 0):
		combo_count += 1;
		combo_score += points_gained * combo_count;
		score += combo_score;
		Reg.Sounds.score(combo_count);
		selector.toast(str(combo_score));
	moved = false
	return scored

func blocks_correct(speed:float) -> bool:
	if(rebuilding): return false
	var blocks_moved = false
	
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
		var rebuild_delay:float = .2;
		if end_only:
			rebuild_delay = .5;
		get_tree().create_timer(rebuild_delay).timeout.connect(func():
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
			
			selector.SelectionX = int(selected_point.x)
			selector.SelectionY = int(selected_point.y)
			rebuilding = false
			moved = true
		)
	else:
		# End of level
		var end_delay:float = .5;
		if new_ys == 0 and new_xs == 0:
			selector.toast("[center]Cleared!\n"+str(level_block_count));
			score += level_block_count;
			end_delay = 3;
			
		get_tree().create_timer(end_delay).timeout.connect(func():
			Reg.telemetryNode.finish_level(moves)
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
			Reg.PS.popup()
		)

func on_puzzle_item_click(_puzzle_item:PuzzleItem, location:Vector2i):
	if(rebuilding): return;
	if(matching): return;
	if(moving): return;
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
