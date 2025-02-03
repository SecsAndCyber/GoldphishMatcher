extends Node
class_name AudioController

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var background_music_stream_player: AudioStreamPlayer = $BackgroundMusicStreamPlayer
@onready var stars_audio_player: AudioStreamPlayer = $StarsAudioPlayer

var cursor_click:AudioStream
var actions
var row:AudioStream
var col:AudioStream
var points:AudioStream
var lost:AudioStream
var won:AudioStream
var star:AudioStream
var combo_1:AudioStream
var combo_2:AudioStream
var combo_3:AudioStream
var combo_4:AudioStream
var combo_5:AudioStream
var combo_6:AudioStream
var cleared:AudioStream

var level_end_menu:AudioStream
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
	combo_5 = load("res://assets/Audio/combo_score_5.mp3")
	combo_6 = load("res://assets/Audio/combo_score_6.mp3")
	cleared = load("res://assets/Audio/combo_score_7.mp3")
	level_end_menu = load("res://assets/Audio/next_menu.mp3")
	menu_open = load("res://assets/Audio/menu_open.wav")
	menu_close = load("res://assets/Audio/menu_close.wav")
	reset = load("res://assets/Audio/reset.wav")
	star = load("res://assets/Audio/star.mp3")
	actions = [row, col, points, combo_1, combo_2, combo_3, combo_4,
				combo_5, combo_6, cleared, menu_open, menu_close, level_end_menu]

func click():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = cursor_click
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func reset_stats():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = reset
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func row_shift():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = row
	audio_stream_player.pitch_scale = randf_range(.992,1.008)
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func col_shift():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = col
	audio_stream_player.pitch_scale = randf_range(.992,1.008)
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_won():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = won
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_done():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = level_end_menu
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_cleared():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = cleared
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func level_lost():
	if Reg.SfxMute:
		return
	audio_stream_player.stream = lost
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()

func star_chime(pitch_shift:float = 1.0):
	if Reg.SfxMute:
		return
	stars_audio_player.pitch_scale = pitch_shift
	stars_audio_player.stream = star
	stars_audio_player.volume_db = Reg.SFXVolume
	stars_audio_player.play()

func menu(open:bool):
	if Reg.SfxMute:
		return
	if open:
		audio_stream_player.stream = menu_open
	else:
		audio_stream_player.stream = menu_close
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()
	
func score(combo_count):
	if Reg.SfxMute:
		return
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
	if combo_count == 6:
		audio_stream_player.stream = combo_5
	if combo_count >= 7:
		audio_stream_player.stream = combo_6
	audio_stream_player.volume_db = Reg.SFXVolume
	audio_stream_player.play()
	
func start_level():
		if(Reg.LevelStep == 0):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic1.mp3");
		elif(Reg.LevelStep == 1):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic2.mp3");
		elif(Reg.LevelStep == 2):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic3.mp3");
		elif(Reg.LevelStep == 3):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic4.mp3");
		elif(Reg.LevelStep == 4):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic5.mp3");
		elif(Reg.LevelStep == 5):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic6.mp3");
		elif(Reg.LevelStep == 6):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic7.mp3");
		elif(Reg.LevelStep == 7):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic8.mp3");
		elif(Reg.LevelStep == 8):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic9.mp3");
		elif(Reg.LevelStep >= 9):
			loading_level = load("res://assets/Audio/Background/UpbeatMelodic10.mp3");
		loading_level.loop = true
		if Reg.MusicMute:
			background_music_stream_player.stop()
			return
		if ! background_music_stream_player.stream == loading_level:
			background_music_stream_player.stream = loading_level
		if ! background_music_stream_player.playing:
			background_music_stream_player.volume_db = Reg.MusicVolume*5
			background_music_stream_player.play()
			
func settings_updated():
	start_level()
