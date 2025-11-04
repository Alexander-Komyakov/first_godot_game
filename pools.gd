extends StaticBody2D


var is_entered: bool = false
var is_take: bool = false

func take_fish():
    print("ловлю")

func _ready():
    $detector.body_entered.connect(_on_player_entered)
    $detector.body_exited.connect(_on_player_exited)

func _on_player_entered(body):
    if body.name == "player":
        is_entered = true
        print("player коснулся детектора!")

func _on_player_exited(body):
    if body.name == "player":
        is_entered = false
        print("player вышел из детектора!")

func _input(event):
    if event.is_action_pressed("ui_accept"):
        is_take = true
        take_fish()
        var random_time = randf_range(2.0, 5.0)
        print("Таймер запущен на ", random_time, " секунд")
        var timer = get_tree().create_timer(random_time)
        await timer.timeout
        print("Случайный таймер завершен!")
