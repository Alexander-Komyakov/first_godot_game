extends CharacterBody2D

@export var speed: float = 400
signal stop_minigame()

var progress_bar: ProgressBar


enum player_state {
    IDLE = 0, FISHING = 1, RESULT = 2
}
var current_state = player_state.IDLE

func get_input():
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_direction * speed

func _physics_process(delta):
    if current_state == player_state.IDLE:
        get_input()
        var input_vector = Vector2.ZERO
    
        # Получаем ввод со всех направлений
        input_vector.x = Input.get_axis("ui_left", "ui_right")
        input_vector.y = Input.get_axis("ui_up", "ui_down")
    
        # Нормализуем вектор, чтобы диагональное движение не было быстрее
        if input_vector.length() > 0:
            input_vector = input_vector.normalized()
    
        velocity = input_vector * speed
        move_and_collide(velocity * delta)
        #move_and_slide()
    elif current_state == player_state.FISHING and Input.get_vector("ui_left","ui_right","ui_up","ui_down")!=Vector2.ZERO:
        stop_minigame.emit()
        current_state = player_state.IDLE
