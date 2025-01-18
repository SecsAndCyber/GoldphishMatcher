extends Node
class_name AudioController

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var background_music_stream_player: AudioStreamPlayer = $BackgroundMusicStreamPlayer

var cursor_click:AudioStream
var actions
var row:AudioStream
var col:AudioStream
var points:AudioStream
var lost:AudioStream
var won:AudioStream
var combo_1:AudioStream
var combo_2:AudioStream
var combo_3:AudioStream
var combo_4:AudioStream

var menu_open:AudioStream
var menu_close:AudioStream
var reset:AudioStream

var playing_level:AudioStream
var loading_level:AudioStream
		
func _ready():	
	cursor_click = load("res://assets/Audio/cursor-click.wav")
	row = load("res://assets/Audio/rotate_row.mp3")
	col = load("res://assets/Audio/rotate_col.mp3")
	points = load("res://assets/Audio/basic_score.wav")
	lost = load("res://assets/Audio/level_lost.wav")
	won = load("res://assets/Audio/level_won.wav")
	combo_1 = load("res://assets/Audio/combo_score_1.wav")
	combo_2 = load("res://assets/Audio/combo_score_2.wav")
	combo_3 = load("res://assets/Audio/combo_score_3.wav")
	combo_4 = load("res://assets/Audio/combo_score_4.wav")
	menu_open = load("res://assets/Audio/menu_open.wav")
	menu_close = load("res://assets/Audio/menu_close.wav")
	reset = load("res://assets/Audio/reset.wav")
	actions = [row, col, points, combo_1, combo_2, combo_3, combo_4, menu_open, menu_close]

func click():
	audio_stream_player.stream = cursor_click
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func reset_stats():
	audio_stream_player.stream = reset
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func row_shift():
	audio_stream_player.stream = row
	audio_stream_player.pitch_scale = randf_range(.997,1.003)
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func col_shift():
	audio_stream_player.stream = col
	audio_stream_player.pitch_scale = randf_range(.997,1.003)
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_won():
	audio_stream_player.stream = won
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_lost():
	audio_stream_player.stream = lost
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func menu(open:bool):
	if open:
		audio_stream_player.stream = menu_open
	else:
		audio_stream_player.stream = menu_close
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()
	
func score(combo_count):
	if combo_count == 1:
		audio_stream_player.stream = points
	if combo_count == 2:
		audio_stream_player.stream = combo_1
	if combo_count == 3:
		audio_stream_player.stream = combo_2
	if combo_count == 4:
		audio_stream_player.stream = combo_3
	if combo_count == 5:
		audio_stream_player.stream = combo_4
	if combo_count >= 6:
		audio_stream_player.stream = combo_4
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()
	
func start_level():
		if(Reg.LevelStep == 0):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic1.mp3");
		if(Reg.LevelStep == 1):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic2.mp3");
		if(Reg.LevelStep == 2):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic3.mp3");
		if(Reg.LevelStep == 3):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic4.mp3");
		if(Reg.LevelStep == 4):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic5.mp3");
		if(Reg.LevelStep == 5):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic6.mp3");
		if(Reg.LevelStep == 6):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic7.mp3");
		if(Reg.LevelStep == 7):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic8.mp3");
		if(Reg.LevelStep == 8):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic9.mp3");
		if(Reg.LevelStep >= 9):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic10.mp3");
		loading_level.loop = true
		if ! background_music_stream_player.stream == loading_level:
			background_music_stream_player.volume_db = Reg.MusicVolume*5
			background_music_stream_player.stream = loading_level
			background_music_stream_player.play()
