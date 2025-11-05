extends CanvasLayer

signal fishing_result(success: bool)

var fish_on = false
var tween = create_tween()
var moving_indicator = ColorRect.new()
var target_zone = ColorRect.new()
var fishing_bar = ColorRect.new()

func go_loop():
    tween = create_tween()
    tween.tween_property(moving_indicator, "position:y", 40.0, 1.3)  # Вправо за 2 сек
    tween.tween_property(moving_indicator, "position:y", 330-target_zone.size[0], 1.3)   # Влево за 2 сек  
    
    tween.set_loops()  # Зациклить
    
func stop_loop():
    if tween and tween.is_valid():
        tween.kill()
    
func _ready():
    get_node("../player").stop_minigame.connect(_stop_fishing)
    get_node("../pool").start_minigame.connect(_start_fishing)
    
    # Создаем полосу для индикатора
    fishing_bar.color = Color.LIGHT_GRAY
    add_child(fishing_bar)
    
    # Создаем движущийся индикатор (зеленый)
    target_zone.color = Color.GREEN
    add_child(target_zone)
    
    # Создаем целевую зону (красный)
    moving_indicator.color = Color.RED
    add_child(moving_indicator)

func check_hit():
    if target_zone.position[1] <= moving_indicator.position[1]+moving_indicator.size[1] and target_zone.position[1] + target_zone.size[1] >= moving_indicator.position[1]:
        return true
    else:
        return false

func _process(delta):
    if fish_on == true:
        if Input.is_action_just_pressed("ui_accept"):
            stop_loop()
            var success = check_hit()
            fish_on = false
            show_result(success)

func show_result(success: bool):
    get_node("../player").current_state = PlayerMove.player_state.RESULT
    var result_text = Label.new()
    result_text.position = Vector2(50, 200)
    
    if success:
        result_text.text = "УСПЕХ!"
        result_text.add_theme_color_override("font_color", Color.GREEN)
    else:
        result_text.text = "ПРОВАЛ!"
        result_text.add_theme_color_override("font_color", Color.RED)  
    add_child(result_text)
    # Удалить через 2 секунды
    await get_tree().create_timer(2.0).timeout
    result_text.queue_free()
    fishing_result.emit(success)  # Отправляем результат
    get_node("../player").current_state = PlayerMove.player_state.IDLE
    _stop_fishing()
    
func _stop_fishing():
    stop_loop()
    fish_on = false
    hide()
    
func _start_fishing(difficulty: String):
    fish_on = true
    if difficulty == "easy":
        fishing_bar.size = Vector2(48, 300)
        fishing_bar.position = Vector2(150, 35)
        
        target_zone.size = Vector2(44, 30)
        target_zone.position = Vector2(152, 150)
        
        moving_indicator.size = Vector2(44, 30)
        moving_indicator.position = Vector2(152, 330-target_zone.size[0])
    go_loop()
    show()
