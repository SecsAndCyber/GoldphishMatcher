extends Control

@export var complete:bool = false

@onready var Stars: Array = [
	$StarA, $StarB, $StarC
]

var AnimationFrames = []

func _init():
	for i in range(25):
		AnimationFrames.append(
			load("res://assets/GoldStar_Spinning-" + str(i + 11) + ".png")
		)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("set_up")
	
func set_up() -> void:
	if get_parent().name == 'root':
		self.scale = Vector2(Reg.UI_Scale, Reg.UI_Scale)
		call_deferred("begin")
	for s in Stars:
		s.get_node('Star').modulate = Color(0,0,0)
		var star_tr:TextureRect = s.get_node('Animate')
		for i in range(25):
			star_tr.texture.set_frame_texture(i,
				AnimationFrames[i]
			)
			star_tr.texture.set_frame_duration(i,.1)

func begin() -> void:
	visible = true
	if Reg.Score:
		print(Reg.Score)
	
	get_tree().create_timer(.75).timeout.connect(func():
		Stars[0].get_node('Animate').visible = true
		Stars[0].get_node('Animate').texture.pause = false
		get_tree().create_timer(1.5).timeout.connect(func():
			Stars[1].get_node('Animate').visible = true
			Stars[1].get_node('Animate').texture.pause = false
			get_tree().create_timer(1.75).timeout.connect(func():
				Stars[2].get_node('Animate').visible = true
				Stars[2].get_node('Animate').texture.pause = false
				complete = true
			)
		)
	)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	for s in Stars:
		var star_tr : TextureRect = s.get_node('Animate')
		if !star_tr.texture.pause:
			if star_tr.texture.current_frame >= 20:
				s.get_node('Star').modulate = Color.WHITE
				star_tr.visible = false
