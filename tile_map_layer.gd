extends TileMapLayer

var tween_idle: Tween
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass
    #start_idle_animation()

func start_idle_animation():
    if tween_idle and tween_idle.is_running():
        return 0
    tween_idle = create_tween()
    tween_idle.set_loops()  # Бесконечное повторение
    
    # Легкое масштабирование - эффект "дыхания"
    tween_idle.tween_property(self, "scale", Vector2(1.0, 0.99), 0.8)
    tween_idle.tween_property(self, "scale", Vector2(0.99, 1.0), 0.8)
    tween_idle.tween_property(self, "scale", Vector2(1.0, 1.0), 0.4)
    
