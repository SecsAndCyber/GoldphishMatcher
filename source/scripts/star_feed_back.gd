extends Control

@export var started:bool = false
@export var complete:bool = false

@onready var Stars: Array = [
	$StarA, $StarB, $StarC
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	call_deferred("set_up")
	
func set_up() -> void:
	if get_parent().name == 'root':
		add_child(Reg.Sounds)
		self.scale = Vector2(Reg.UI_Scale, Reg.UI_Scale)
		Reg.LastLevel = 1
		Reg.Score = 120
		call_deferred("begin", {"map_level":1,"least":9,"average":"79.5000","two_star":124.7217376441414,"maximum":225})
	for s in Stars:
		# s.get_node('Star').visible = false
		s.get_node('Star').modulate = Color(0,0,0)

func display(star_count:int = 0) -> void:
	star_count = clampi(star_count,0,len(Stars))
	for s in Stars:
		s.get_node('Star').visible = false
		s.get_node('Star').modulate = Color.WHITE
	for i in range(star_count):
		Stars[i].get_node('Star').visible = true


func begin(level_stats:Dictionary = {}) -> void:
	for s in Stars:
		s.get_node('Star').visible = true
		s.get_node('Star').modulate = Color(0,0,0)
	@warning_ignore("integer_division")
	var rows:int = 4 + int((Reg.LastLevel % 1000) / 5)
	var star_1_delay : float = .75
	var star_2_delay : float = 1.5
	var star_3_delay : float = 1.75
	
	var star_1_threshold : float = (Reg.LastLevel % 1000) * rows * 5
	var star_2_threshold : float = star_1_threshold * 3
	var star_3_threshold : float = star_2_threshold * 3
	started = true
	
	if level_stats:
		if Reg.LastLevel == level_stats.get('map_level'):
			if star_2_threshold < float(level_stats.get('average', 0)):
				star_2_threshold = float(level_stats.get('average'))
			if star_3_threshold < float(level_stats.get('two_star',0)):
				star_3_threshold = float(level_stats.get('two_star'))
			if star_3_threshold >= float(level_stats.get('maximum',0)):
				star_3_threshold = float(level_stats.get('maximum',0))
	if star_3_threshold <= star_2_threshold:
		star_2_threshold = (star_3_threshold + star_1_threshold) / 2
	visible = true
	if Reg.Score:
		print("%d : (%d,%d,%d)" % [Reg.Score, star_1_threshold, star_2_threshold, star_3_threshold])
		if Reg.Score < star_3_threshold:
			star_3_delay = 0
		if Reg.Score < star_2_threshold:
			star_2_delay = 0
		if Reg.Score < star_1_threshold:
			star_1_delay = 0
	Stars[0].get_node('ThresholdLabel').visible = true
	Stars[0].get_node('ThresholdLabel').text = '[center]' + str(int(star_1_threshold))
	Stars[1].get_node('ThresholdLabel').visible = true
	Stars[1].get_node('ThresholdLabel').text = '[center]' + str(int(star_2_threshold))
	Stars[2].get_node('ThresholdLabel').visible = true
	Stars[2].get_node('ThresholdLabel').text = '[center]' + str(int(star_3_threshold))
	
	get_tree().create_timer(star_1_delay).timeout.connect(func():
		if star_1_delay:
			Reg.LevelStars[Reg.Levels]=max(1, Reg.LevelStars.get(Reg.Levels, 0))
			Reg.Sounds.star_chime(1.15)
			Stars[0].get_node('ThresholdLabel').visible = false
			Stars[0].get_node('Animate').play()
		else:
			Stars[0].get_node('Star').visible = true
		get_tree().create_timer(star_2_delay).timeout.connect(func():
			if star_2_delay:
				Reg.LevelStars[Reg.Levels]=max(2, Reg.LevelStars.get(Reg.Levels, 0))
				Reg.Sounds.star_chime(1.5)
				Stars[1].get_node('ThresholdLabel').visible = false
				Stars[1].get_node('Animate').play()
			else:
				Stars[1].get_node('Star').visible = true
			get_tree().create_timer(star_3_delay).timeout.connect(func():
				if star_3_delay:
					Reg.LevelStars[Reg.Levels]=max(3, Reg.LevelStars.get(Reg.Levels, 0))
					Reg.Sounds.star_chime(2)
					Stars[2].get_node('ThresholdLabel').visible = false
					Stars[2].get_node('Animate').play()
				else:
					Stars[2].get_node('Star').visible = true
					complete = true
			)
		)
	)


func _on_animate_animation_ended(animated_texture_rect: AnimatedTextureRect) -> void:
	for s in Stars:
		if animated_texture_rect == s.get_node('Animate'):
			s.get_node('Star').visible = true
			s.get_node('Star').modulate = Color.WHITE
			animated_texture_rect.visible = false
			if s == Stars[-1]:
				complete = true
