extends Node
class_name Reg

# This is a singleton class, ensuring only one instance exists
static var instance:Reg = null
func _init():
	if Reg.instance:
		push_error("Singleton already exists!")
		queue_free()
		return
	Reg.instance = self
	Reg.Sounds = load("res://source/audio_controller.tscn").instantiate()
	Reg.telemetryNode = load("res://source/telemetry_node.tscn").instantiate()
	_gameId = UUID.v4()

@export var _ps:GameState = null
static var PS:GameState:
	set(val):
		instance._ps = val
	get:
		return instance._ps

static var telemetryNode:TelemetryNode 
static var Sounds:AudioController 
@export var _gameId:String = "";
static var GameId:String:
	set(val):
		instance._gameId = val
	get:
		return instance._gameId

@export var _levels:int
static var Levels:int:
	set(val):
		instance._levels = val
	get:
		return instance._levels
		
@export var _runningscore:int
static var RunningScore:int:
	set(val):
		instance._runningscore = val
	get:
		return instance._runningscore

@export var _score:int = 0;
static var Score:int:
	set(val):
		instance._score = val
	get:
		return instance._score

@export var _hiscore:Dictionary = {0:0};
static var HiScore:Dictionary:
	set(val):
		instance._hiscore = val
	get:
		return instance._hiscore

@export var _hiscore_moves:Dictionary = {0:0};
static var HiScoreMoves:Dictionary:
	set(val):
		instance._hiscore_moves = val
	get:
		return instance._hiscore_moves

@export var _highscoreset:bool
static var HiScoreSet:bool:
	set(val):
		instance._highscoreset = val
	get:
		return instance._highscoreset

static var Loss:bool = false;
static var Done:bool = false;

static var UI_Scale:float = .33333
static var Level_Scale:float:
	get():
		if LevelStep == 0:
			return UI_Scale * 2
		if LevelStep == 1:
			return 0.54
		if LevelStep == 2:
			return 0.444
		if LevelStep == 3:
			return 0.383
		#return UI_Scale * clampf(2 - ((instance._levels / 5)/5.0), 1, 2);
		return UI_Scale
static var LevelStep:int:
	get():
		return int(instance._levels / 5)
static var MusicVolume:float = .0125
var _music_mute:bool = false
static var MusicMute:bool:
	get():
		print("Music Muted:", str(instance._music_mute))
		return instance._music_mute
	set(val):
		instance._music_mute = val
		instance.Sounds.settings_updated()
static var SFXVolume:float = .75;
var _sfx_mute:bool = false
static var SfxMute:bool:
	get():
		return instance._sfx_mute
	set(val):
		instance._sfx_mute = val
		instance.Sounds.settings_updated()
var _network_disable:bool = false
static var NetworkMute:bool:
	get():
		return instance._network_disable
	set(val):
		instance._network_disable = val
static var hideMouse:bool = false;

static var fish_speed:float = 50.0 * UI_Scale;
static var fish_location:Vector2 = Vector2.ZERO;

var _save_path = "user://puzzler.state"
static func saveScore():
	var file = FileAccess.open(instance._save_path, FileAccess.WRITE)
	file.store_line(JSON.stringify({
		'levels':instance._levels,
		'runningscore':instance._runningscore,
		'GameId':instance._gameId,
		'HiScore':instance._hiscore,
		'HiScoreMoves':instance._hiscore_moves,
		'MusicMute':instance._music_mute,
		'SfxMute':instance._sfx_mute,
		'NetworkMute':instance._network_disable
	}))

static func loadScore():
	var file = FileAccess.open(instance._save_path, FileAccess.READ)
	
	if fish_location == Vector2.ZERO:
		fish_location = Vector2(20*Reg.UI_Scale, fish_speed*Reg.UI_Scale)
	Reg.Levels = 1
	Reg.RunningScore = 0
	if file:
		var json_string = file.get_line()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var node_data = json.data
			instance._levels=node_data['levels']
			instance._runningscore=node_data['runningscore']
			if node_data.get('GameId'):
				instance._gameId=node_data['GameId']
			for k in node_data['HiScore']:
				instance._hiscore[int(k)]=node_data['HiScore'][k]
			for k in node_data['HiScoreMoves']:
				instance._hiscore_moves[int(k)]=node_data['HiScoreMoves'][k]
			if node_data.get('MusicMute'):
				instance._music_mute=node_data['MusicMute']
			if node_data.get('SfxMute'):
				instance._sfx_mute=node_data['SfxMute']
			if node_data.get('NetworkMute'):
				instance._network_disable=node_data['NetworkMute']
		
			if not 0 in instance._hiscore:
				instance._hiscore[0]=0
	Reg.Done = Reg.Levels > 30

static func clearSave():
	Reg.Levels = 1
	Reg.RunningScore = 0
	Reg.HiScore = {0:0}
	Reg.Score = 0
	saveScore()
