extends Control

@export var complete:bool = false

@onready var Stars: Array = [
	$StarA, $StarB, $StarC
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("set_up")
	
func set_up() -> void:
	if get_parent().name == 'root':
		self.scale = Vector2(Reg.UI_Scale, Reg.UI_Scale)
		call_deferred("begin")
	for s in Stars:
		s.get_node('Star').modulate = Color(0,0,0)

func begin() -> void:
	var rows:int = 4 + int(Reg.Levels / 5)
	var star_1_delay : float = .75
	var star_2_delay : float = 1.5
	var star_3_delay : float = 1.75
	visible = true
	if Reg.Score:
		if Reg.Score <= rows * 5 * 3:
			star_3_delay = 0
		if Reg.Score <= rows * 5 * 2:
			star_2_delay = 0
		if Reg.Score <= rows * 5:
			star_1_delay = 0
	
	get_tree().create_timer(star_1_delay).timeout.connect(func():
		if star_1_delay:
			Stars[0].get_node('Animate').play()
		get_tree().create_timer(star_2_delay).timeout.connect(func():
			if star_2_delay:
				Stars[1].get_node('Animate').play()
			get_tree().create_timer(star_3_delay).timeout.connect(func():
				if star_3_delay:
					Stars[2].get_node('Animate').play()
				complete = true
			)
		)
	)


func _on_animate_animation_ended(animated_texture_rect: AnimatedTextureRect) -> void:
	for s in Stars:
		if animated_texture_rect == s.get_node('Animate'):
			s.get_node('Star').modulate = Color.WHITE
			animated_texture_rect.visible = false
