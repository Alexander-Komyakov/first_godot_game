extends CharacterBody2D

@export var speed: float = 400

@export var can_move: bool = true

func get_input():
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_direction * speed

func _physics_process(delta):
    if can_move == false:
        return
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
