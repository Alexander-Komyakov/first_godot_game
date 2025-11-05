extends StaticBody2D

var is_entered: bool = false
signal start_minigame(difficulty: String)

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
    if event.is_action_pressed("ui_accept") and player.current_state == player.player_state.IDLE and is_entered:
        player.current_state = player.player_state.FISHING
        var random_time = randf_range(2.0, 5.0)
        var timer = get_tree().create_timer(random_time)
        await timer.timeout
        if player.current_state == player.player_state.FISHING:
            fish_on("easy")

func fish_on(difficulty: String):
    start_minigame.emit(difficulty)
    
