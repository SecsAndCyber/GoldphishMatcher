extends GameState
class_name UiState

static var textures:Array = [
		load("res://assets/HappyGoldfishCookieSquare.png"),
		load("res://assets/SadGoldfishCookieSquare.png"),
		load("res://assets/HappyGoldfishCookieSquare.png"),
		load("res://assets/EvilGoldfishCookieSquare.png"),
		load("res://assets/HappyGoldfishCookieSquare.png"),
		load("res://assets/DeadGoldfishCookieSquare.png"),
		load("res://assets/HappyGoldfishCookieSquare.png")
	]
static var fish:Array
static var fish_rng:RandomNumberGenerator

@onready var fishes: Control = $Fishes

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	call_deferred("do_ui_setup")
	
func do_ui_setup():
	# Do initialization here
	fish = []
	fish_rng = RandomNumberGenerator.new()
	fish_rng.seed = Reg.Levels
	for index in range(0, Reg.Levels):
		fish.append(TextureRect.new())
		fish[index].texture = textures[index % len(textures)]
		fish[index].scale = Vector2(Reg.UI_Scale, Reg.UI_Scale)
		fishes.add_child(fish[index])
		fish[index].position = Vector2(
			Reg.fish_location.x - index * (Reg.fish_speed + fish_rng.randi_range(int(size.x / -2), int(size.x / 2))),
			Reg.fish_location.y + index * Reg.fish_speed
		)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for index in range(0, len(fish)):
		fish[index].position.x += (Reg.fish_speed * Reg.Levels) * delta
		fish[index].position.y = delta * (Reg.fish_speed + Reg.fish_speed * sin(deg_to_rad(Time.get_ticks_msec()))) * Reg.UI_Scale + index * Reg.fish_speed
		
		if fish[index].position.x > self.size.x:
			fish[index].position.x = -1 * fish[index].size.x - index * Reg.fish_speed;
	Reg.fish_location.x = fish[0].position.x;
	Reg.fish_location.y = fish[0].position.y;
	pass
