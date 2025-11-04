extends StaticBody2D

var is_entered: bool = false
var is_take: bool = false

func _ready():
    $detector.body_entered.connect(_on_player_entered)
    $detector.body_exited.connect(_on_player_exited)
    var fish = get_node("../fishing")
    fish.fishing_result.connect(_on_fishing_result)


func _on_player_entered(body):
    if body.name == "player":
        is_entered = true

func _on_player_exited(body):
    if body.name == "player":
        is_entered = false

func _input(event):
    if event.is_action_pressed("ui_accept") and is_take == false:
        is_take = true
        get_node("../player").can_move = false
        var random_time = randf_range(2.0, 5.0)
        var timer = get_tree().create_timer(random_time)
        await timer.timeout
        fish_on("easy")

func fish_on(dificulty):
    var fish = get_node("../fishing")
    fish.show() #fish.hide()
    fish.fish_on = true
    
func _on_fishing_result(success: bool):
    var fish = get_node("../fishing")
    fish.hide()
    get_node("../player").can_move = true
    is_take = false
