extends StaticBody2D

var is_entered: bool = false
signal start_minigame(difficulty: String)

var difficulty: String

var difficulty_values = {
    "easy": 1,
    "medium": 2,
    "hard": 3
}

func _ready():
    $detector.body_entered.connect(_on_player_entered)
    $detector.body_exited.connect(_on_player_exited)

func _on_player_entered(body):
    if body.name == "player":
        is_entered = true

func _on_player_exited(body):
    if body.name == "player":
        is_entered = false

func _input(event):
    var player = get_node("../player")
    if event.is_action_pressed("ui_accept") and player.get_state() == player.player_state.IDLE and is_entered:
        player.set_state(player.player_state.FISHING)
        var random_time = randf_range(2.0, 5.0)
        var timer = get_tree().create_timer(random_time)
        await timer.timeout
        if player.get_state() == player.player_state.FISHING and get_node("../fishing").fish_on == false:
            var random_value = randf() * 100  # 0-100
            if random_value < 70:    # 0-69.999 (70%)
                difficulty = "easy"
            elif random_value < 95:  # 70-94.999 (25%)
                difficulty = "medium"
            else:                    # 95-100 (5%)
                difficulty = "hard"
            fish_on(difficulty)

func fish_on(difficulty: String):
    start_minigame.emit(difficulty)
