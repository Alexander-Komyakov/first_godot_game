extends CharacterBody2D

@export var speed: float = 400
@onready var animated_sprite = $AnimatedSprite2D
@onready var audioStep = $AudioStep
@onready var audioBulk = $AudioBulk
@onready var audioCoil = $AudioCoil
@onready var audioCoilMore = $AudioCoilMore
@onready var audioLose = $AudioLose
@onready var audioWin = $AudioWin

signal stop_minigame()

var progress_bar: ProgressBar
var tween_idle: Tween
var tween_move: Tween
var tween_fishing: Tween
var anim_fish_start: bool


enum player_state {
    IDLE = 0, FISHING = 1, RESULT = 2
}
var _current_state = player_state.IDLE

func get_input():
    var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    velocity = input_direction * speed

func _physics_process(delta):
    if get_state() == player_state.IDLE:
        get_input()
        var input_vector = Vector2.ZERO
    
        # Получаем ввод со всех направлений
        input_vector.x = Input.get_axis("ui_left", "ui_right")
        input_vector.y = Input.get_axis("ui_up", "ui_down")
    
        # Нормализуем вектор, чтобы диагональное движение не было быстрее
        if input_vector.length() > 0 and not Input.is_action_pressed("ui_accept") and get_state() == player_state.IDLE:
            input_vector = input_vector.normalized()
            start_move_animation()
            if audioStep != null and not audioStep.playing:
                audioStep.play()
            if animated_sprite != null:
                animated_sprite.flip_h = input_vector.x < 0
        else:
            if audioStep != null:
                audioStep.stop()
            stop_move_animation()
        velocity = input_vector * speed
        move_and_collide(velocity * delta)
    elif get_state() == player_state.FISHING and Input.get_vector("ui_left","ui_right","ui_up","ui_down")!=Vector2.ZERO:
        stop_minigame.emit()
        set_state(player_state.IDLE)
            
    if get_state() == player_state.FISHING and get_node("../fishing").fish_on == true:
        start_fishing_animation()
    elif get_state() == player_state.FISHING and get_node("../fishing").fish_on == false and anim_fish_start == false:
        start_fishing_animation()
        anim_fish_start = true

func set_state(state: int):
    _current_state = state
    if _current_state == player_state.IDLE:
        if get_node("../pool").entered_direction == get_node("../pool").buble_direction and get_node("../pool").buble_direction != get_node("../pool").buble_state_values["none"]:
            get_node("../pool")._hide_all_buble()
        if audioCoilMore != null and audioCoilMore.playing:
            audioCoilMore.stop()
        animated_sprite.frame = 0
    elif _current_state == player_state.FISHING:
        if audioBulk != null and not audioBulk.playing:
            audioBulk.play()
        if get_node("../fishing").fish_on == false:
            if audioCoil != null and not audioCoil.playing:
                audioCoil.play()
        start_fishing_animation()
        animated_sprite.frame = 1
    else:
        #audioCoil.stop()
        animated_sprite.frame = 0

func get_state():
    return _current_state

func start_fishing_animation():
    if tween_fishing and tween_fishing.is_running():
        return 0
    tween_fishing = create_tween()
    # Анимация закидывания
    tween_fishing.tween_property(self, "rotation_degrees", -30.0, 0.2)
    tween_fishing.tween_property(self, "rotation_degrees", 10.0, 0.3)
    tween_fishing.tween_property(self, "rotation_degrees", 0.0, 0.1)
    await tween_fishing.finished
    start_idle_animation()
    
func start_idle_animation():
    if tween_idle and tween_idle.is_running():
        return 0
    tween_idle = create_tween()
    tween_idle.set_loops()  # Бесконечное повторение
    
    # Легкое масштабирование - эффект "дыхания"
    tween_idle.tween_property(self, "scale", Vector2(1.05, 0.95), 0.8)
    tween_idle.tween_property(self, "scale", Vector2(0.95, 1.05), 0.8)
    tween_idle.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
    
func stop_idle_animation():
    if tween_idle:
        tween_idle.kill()

func start_move_animation():
    stop_idle_animation()
        
    if tween_move and tween_move.is_running():
        return 0
    tween_move = create_tween()
    tween_move.set_loops()
    
    # Покачивание влево-вправо при ходьбе
    tween_move.tween_property(self, "rotation_degrees", 3.0, 0.2)
    tween_move.tween_property(self, "rotation_degrees", -3.0, 0.2)
    tween_move.tween_property(self, "rotation_degrees", 0.0, 0.2)
    

func stop_move_animation():
    if tween_move:
        tween_move.kill()
    var tween = create_tween()
    tween.tween_property(self, "rotation_degrees", 0.0, 0.1)
    await tween.finished
    start_idle_animation()
    
func _ready():
    pass
    
