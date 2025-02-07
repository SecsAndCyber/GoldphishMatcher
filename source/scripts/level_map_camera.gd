extends Camera2D

@export var target_control:Control
@onready var viewport_size:Vector2 = Vector2(get_viewport().size)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_top = target_control.global_position.y
	limit_bottom = target_control.size.y
	
	
func move_y(delta: float, scaled: bool = false) -> void:
	var _target_y: float = position.y + delta
	if _target_y < limit_top:
		delta = position.y - limit_top
	if _target_y + viewport_size.y > limit_bottom:
		delta = limit_bottom - (position.y  + viewport_size.y)
	super.move_local_y(delta, scaled)
