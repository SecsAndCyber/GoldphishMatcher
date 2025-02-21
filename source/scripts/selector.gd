extends TextureRect
class_name Selector

@export var speed: float = 1.5
var selection = Vector2i.ZERO
var target_position = Vector2.ZERO

@onready var toast_text: RichTextLabel = $"../toastText"
var cleared: bool = true
var toast_top: float = 0
var blocks = [[]];

var SelectionX:int:
	set(value):
		if blocks and blocks[0]:
			cleared = false
			selection.x = (value + len(blocks)) % len(blocks)
			selection.y = (selection.y + len(blocks[0])) % len(blocks[0])
			target_position.x = blocks[selection.x][selection.y].global_position.x
	get: return selection.x

var SelectionY:int:
	set(value):
		if blocks and blocks[0]:
			cleared = false
			selection.x = (selection.x + len(blocks)) % len(blocks)
			selection.y = (value + len(blocks[0])) % len(blocks[0])
			target_position.y = blocks[selection.x][selection.y].global_position.y
	get: return selection.y

func clear():
	cleared = true
	visible = false
	
func reveal(location:Vector2i):
	SelectionX=location.x
	SelectionY=location.y
	visible = true

func toast(text:String):
	if Reg.Levels == GameBoardLayout.LEVEL_CONST_TUTORIAL:
		toast_text.scale = Vector2(.75,.75)
	print("toast:", text, " ", Reg.PS.board)
	toast_top = -1 * toast_text.get_content_height()
	toast_text.text = text
	toast_text.visible = true
	
	toast_text.global_position.x = 35.0;
	toast_text.global_position.y = 310.0;
	toast_text.modulate = Color(256, 256, 256, 1)

func _process(delta: float) -> void:
	if !Reg.Replay:
		visible = !cleared and !Reg.Loss and !toast_text.visible
	scale = Vector2(Reg.Level_Scale, Reg.Level_Scale)
	if toast_text.visible:
		toast_text.global_position.y = lerp(toast_text.global_position.y, toast_top, speed*delta)
		if(toast_text.global_position.y < 0.75 * toast_top):
			toast_text.visible = false
	else:
		if Input.is_key_pressed(KEY_SPACE):
			modulate = Color(0, 0, 256, 1)
		else:
			modulate = Color(256, 0, 0, 1)		
	
	if Reg.PS == null or Reg.PS.board == null or Reg.PS.board.moving or Reg.PS.board.rebuilding:
		modulate = Color(256, 256, 256, 1)
		return
	blocks = Reg.PS.board.blocks;
	if !cleared:
		SelectionX = selection.x
		SelectionY = selection.y
		global_position.x = blocks[selection.x][selection.y].global_position.x
		global_position.y = blocks[selection.x][selection.y].global_position.y
