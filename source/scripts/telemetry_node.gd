extends HTTPRequest
class_name TelemetryNode

var http_client:HTTPClient = null
var baseUrl = "https://molyett.com/api/goldphish/"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	use_threads = true
	if http_client == null:
		http_client = HTTPClient.new()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func buildUrl(endpoint:String, parameters:Dictionary = {}):
	var _r = baseUrl + "?endpoint=" + endpoint
	var enc_parameters:Dictionary = {}
	for p in parameters:
		enc_parameters[urlB64(p)] = urlB64(parameters[p])
	if parameters:
		_r += "&" + http_client.query_string_from_dict(enc_parameters)
	return _r
			
func urlB64(to_encode:Variant):
	var b64:String = Marshalls.utf8_to_base64(str(to_encode))
	b64 = b64.replace('+','-')
	b64 = b64.replace('/','_')
	b64 = b64.replace('=','.')
	return b64

func start_level(gs:GameState):
	request(buildUrl('new_game_state',{
		'GameClient' : Reg.GameId,
		'Level' : Reg.Levels,
		'Settings' : {
			'Music': Reg.MusicMute,
			'Sfx': Reg.SfxMute,
			},
		'GameState': gs.get_parent().name
	}))

func reset_game():
	request(buildUrl('reset_game',{
		'GameClient' : Reg.GameId,
		'Level' : Reg.Levels,
		'RunningScore' : Reg.RunningScore,
	}))

func reset_scores():
	request(buildUrl('reset_scores',{
		'GameClient' : Reg.GameId,
		'Level' : Reg.Levels,
		'HiScores' : Reg.HiScore,
	}))

func finish_level(moves:Array):
	request(buildUrl('level_cleared',{
		'GameClient' : Reg.GameId,
		'Level' : Reg.Levels,
		'Score' : Reg.Score,
		'Moves' : moves
	}))

func failed_level(moves:Array):
	request(buildUrl('level_failed',{
		'GameClient' : Reg.GameId,
		'Level' : Reg.Levels,
		'Score' : Reg.Score,
		'Moves' : moves
	}))
