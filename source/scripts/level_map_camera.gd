extends Camera2D

@export var target_control:Control
@onready var viewport_size:Vector2 = Vector2(get_viewport_rect().size)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	limit_top = int(target_control.global_position.y)
	limit_bottom = int(target_control.size.y)
	
func _process(_delta: float) -> void:
	position.y = int(clampf(position.y, limit_top, limit_bottom - viewport_size.y))
	
func move_y(delta: float, scaled: bool = false) -> void:
	var _target_y: float = position.y + delta
	if _target_y < limit_top:
		position.y = limit_top
		return
	if _target_y + viewport_size.y > limit_bottom:
		position.y = limit_bottom - viewport_size.y
		return
	super.move_local_y(delta, scaled)
