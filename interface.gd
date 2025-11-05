extends CanvasLayer



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    $ProgressFish.min_value = 0
    $ProgressFish.max_value = 10
    $ProgressFish.value = 0  # Наполовину заполнен
    get_node("../fishing").add_score.connect(_add_score)

func _add_score(score: int):
    if ($ProgressFish.value + score >= $ProgressFish.max_value):
        $ProgressFish.value = score + $ProgressFish.value - $ProgressFish.max_value
        $ProgressFish.max_value = $ProgressFish.max_value * 2
    else:
        $ProgressFish.value += score
    $ProgressFishLabel.text = str(int($ProgressFish.value)) + "/" + str(int($ProgressFish.max_value))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
