class_name LevelIsland extends Button
@onready var hi_score: RichTextLabel = $HiScore
@onready var star_feed_back: Control = $StarFeedBack

@export var level_id:int
@export var score:int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	text = str(level_id)
	if not (
		Reg.HiScore.get(level_id, 0) or 
		Reg.HiScore.get(level_id-1, 0)
		or level_id == 1):
		disabled = true
		hi_score.text = ''
		score = 0
	else:
		score = Reg.HiScore.get(level_id, 0)
		hi_score.text = str(score)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	star_feed_back.display(Reg.LevelStars.get(level_id, 0))
