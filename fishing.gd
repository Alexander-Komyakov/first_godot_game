extends CanvasLayer

signal add_score(score: int)


var fish_on: bool
var tween: Tween
var moving_indicator = ColorRect.new()
var target_zone = ColorRect.new()
var fishing_bar = ColorRect.new()
var border = ColorRect.new()
 
var fish_values = [
    "червышь",
    "кривяк",
    "лупышь",
    "кубич",
    "задумок",
    "пиляшь"
]


func stop_loop():
    if tween:
        tween.kill()
        tween.custom_step(1000)
        tween = null

func _ready():
    fish_on = false
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
    
    border = ColorRect.new()
    border.color = Color.BLACK

    add_child(border)
# Чтобы бордюр был СНИЗУ (под полосой), а не поверх — переместим его в начало списка детей:
    move_child(border, 0)


func check_hit():
    if target_zone.position[1] <= moving_indicator.position[1]+moving_indicator.size[1] and target_zone.position[1] + target_zone.size[1] >= moving_indicator.position[1]:
        return true
    else:
        return false
        
func _end_game(success: bool, score: int):
    stop_loop()
    fish_on = false
    show_result(success)
    if get_node("../pool").buble_direction == get_node("../pool").entered_direction and get_node("../pool").buble_direction != 5:
        score *= 2
    add_score.emit(score)  # Отправляем результат
    

func _process(delta):
    if fish_on == true:
        if Input.is_action_just_pressed("ui_accept"):
            var difficulty = get_node("../pool").difficulty
            var difficulty_values = get_node("../pool").difficulty_values
            if check_hit() == true:
                _end_game(check_hit(), difficulty_values[difficulty])
            else:
                _end_game(check_hit(), 0)
            

func show_result(success: bool):
    var player = get_node("../player")
    player.set_state(PlayerMove.player_state.RESULT)
    var screen_size = get_viewport().get_visible_rect().size
    
    $water.show()
    $rod.show()
    $fishLabel.show()
    if success:
        $fish.show()

        var pool = get_node("../pool")
        var difficulty = pool.difficulty_values[pool.difficulty]
        player.audioWin.play()
        if pool.buble_direction == pool.entered_direction and pool.buble_direction != 5:
            difficulty *= 2
        $fish.frame = difficulty-1
        $fishLabel.text = "Поймал рыбу: " + fish_values[difficulty-1] + " +" + str(difficulty)
        $fish.show()
    else:
        player.audioLose.play()
        $fishLabel.text = "Cорвалась бандура!"
    player.audioCoilMore.stop()
    # Удалить через 2 секунды
    await get_tree().create_timer(2.0).timeout
    #fishing_result.emit(success)  # Отправляем результат
    get_node("../player").set_state(PlayerMove.player_state.IDLE)
    $fish.hide()
    $water.hide()
    $rod.hide()
    $fishLabel.hide()
    
    _stop_fishing()

func _stop_fishing():
    stop_loop()
    fish_on = false
    $fish.hide()
    hide()

func _start_fishing(difficulty: String):
    fish_on = true
    get_node("../player").audioCoilMore.play()
    var screen_size = get_viewport().get_visible_rect().size
    var center_x = screen_size.x / 2
    var center_y = screen_size.y / 2
    
    # Базовые размеры
    var bar_width = 48
    var bar_height = 300
    var bar_pos_x = center_x - bar_width / 2  # Центрируем по X
    var bar_pos_y = center_y - bar_height / 2 + 50  # Центрируем по Y
    
    # Настройки сложности
    var target_size = Vector2(44, 0)
    var indicator_speed = 0.0
    
    match difficulty:
        "easy":
            target_size.y = 40  # Большая цель
            indicator_speed = 0.8  # Медленно
        "medium":
            target_size.y = 30   # Средняя цель  
            indicator_speed = 0.6  # Быстрее
        "hard":
            target_size.y = 20   # Маленькая цель
            indicator_speed = 0.4  # Очень быстро
    
    # СЛУЧАЙНАЯ позиция цели в рамках полосы
    var min_target_y = bar_pos_y + 10
    var max_target_y = bar_pos_y + bar_height - target_size.y - 10
    var random_target_y = randf_range(min_target_y, max_target_y)
    
    # Устанавливаем размеры с зависимостями
    fishing_bar.size = Vector2(bar_width, bar_height)
    fishing_bar.position = Vector2(bar_pos_x, bar_pos_y)
    
    target_zone.size = target_size
    target_zone.position = Vector2(bar_pos_x + 2, random_target_y)  # Случайная позиция
    
    moving_indicator.size = Vector2(44, 10)
    moving_indicator.position = Vector2(bar_pos_x + 2, bar_height + bar_pos_y - moving_indicator.size.y)
    
    border.size = fishing_bar.size + Vector2(8, 8)  # +4 пикселя с каждой стороны
    border.position = fishing_bar.position - Vector2(4, 4)  # сдвигаем на 4 пикселя влево/вверх
    
    # Запускаем анимацию
    stop_loop()
    tween = create_tween()
    var min_y = bar_pos_y + 5
    var max_y = bar_pos_y + bar_height - moving_indicator.size.y - 5
    
    tween.tween_property(moving_indicator, "position:y", min_y, indicator_speed)
    tween.tween_property(moving_indicator, "position:y", max_y, indicator_speed)
    tween.set_loops(6)
    tween.finished.connect(func(): _end_game(false, 0))

    show()
