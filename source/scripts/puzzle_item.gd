extends TextureButton
class_name PuzzleItem

signal clicked(puzzle_item:PuzzleItem, location:Vector2)

static var symbols = [3,5,7,13];
var _symbol:int;
static var textures = [0,1,3,5];

static var Max: int: 
	get(): return len(symbols)

var Value: int: 
	get(): return _symbol

var current_location = Vector2i(0,0)

func init(symbol, r, c):
	assert ( len(symbols) == len(textures), "Invalid class arrays" )
	_symbol = symbols[symbol % len(symbols)]
	texture_normal = UiState.textures[textures[symbol % len(symbols)]]
	scale = Vector2(Reg.Level_Scale, Reg.Level_Scale)
	current_location = Vector2i(r,c)
	pressed.connect(_on_pressed)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	scale = Vector2(Reg.Level_Scale, Reg.Level_Scale)


func _on_pressed() -> void:
	clicked.emit(self, current_location)
