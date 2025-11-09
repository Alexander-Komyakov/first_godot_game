extends StaticBody2D

var is_entered: bool = false
@onready var entered_direction: int = buble_state_values["none"]
@onready var buble_direction: int = buble_state_values["none"]

var buble_state: bool = false

var timer_buble: Timer
var timer_buble_end: Timer


signal start_minigame(difficulty: String)

var difficulty: String

var difficulty_values = {
    "easy": 1,
    "medium": 2,
    "hard": 3
}

var buble_state_values = {
    "lup": 1,
    "ldown": 2,
    "rup": 3,
    "rdown": 4,
    "none": 5
}

func _process(delta):
    if buble_state == false and timer_buble != null and timer_buble.is_stopped() == true and get_node("../player").get_state() == get_node("../player").player_state.IDLE:
        buble_state = true
        timer_buble.start(randf_range(3, 8))

func _ready():
    timer_buble = Timer.new()
    timer_buble_end = Timer.new()
    
    add_child(timer_buble)
    add_child(timer_buble_end)
    timer_buble.timeout.connect(_on_timer_timeout)
    timer_buble_end.timeout.connect(_on_timer_buble_end_timeout)
    timer_buble.one_shot = true
    timer_buble_end.one_shot = true

    
    $detector.body_entered.connect(_on_player_entered)
    $detector.body_exited.connect(_on_player_exited)
    
    $leftDown.body_entered.connect(_on_player_entered_ldown)
    $leftUp.body_entered.connect(_on_player_entered_lup)
    $rightUp.body_entered.connect(_on_player_entered_rup)
    $rightDown.body_entered.connect(_on_player_entered_rdown)

func _on_timer_buble_end_timeout():
    buble_state = false
    if get_node("../player").get_state() == get_node("../player").player_state.IDLE and entered_direction != buble_direction and buble_direction != buble_state_values["none"]:
        _hide_all_buble()
        buble_direction = buble_state_values["none"]
    
func _on_timer_timeout():
    timer_buble_end.start(randf_range(2, 5))
    _hide_all_buble()
    buble_direction = randf_range(1, 4)
    
    match buble_direction:
        1:
            $leftUp.show()
        2:
            $leftDown.show()
        3:
            $rightUp.show()
        4:
            $rightDown.show()

func _hide_all_buble():
    $leftUp.hide()
    $leftDown.hide()
    $rightUp.hide()
    $rightDown.hide()

func _on_player_entered(body):
    if body.name == "player":
        is_entered = true

func _on_player_entered_ldown(body: Node2D) -> void:
    entered_direction = buble_state_values["ldown"]
func _on_player_entered_lup(body: Node2D) -> void:
    entered_direction = buble_state_values["lup"]
func _on_player_entered_rdown(body: Node2D) -> void:
    entered_direction = buble_state_values["rdown"]
func _on_player_entered_rup(body: Node2D) -> void:
    entered_direction = buble_state_values["rup"]

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

func play_buble_one() -> void:
    if get_node("bubleAudio") != null and not get_node("bubleAudio").playing:
        get_node("bubleAudio").play()
        
func _on_left_down_visibility_changed() -> void:
    if get_node("leftDown").visible:
        play_buble_one()


func _on_left_up_visibility_changed() -> void:
    if get_node("leftUp").visible:
        play_buble_one()


func _on_right_down_visibility_changed() -> void:
    if get_node("rightDown").visible:
        play_buble_one()


func _on_right_up_visibility_changed() -> void:
    if get_node("rightUp").visible:
        play_buble_one()
