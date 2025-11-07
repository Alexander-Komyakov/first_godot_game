extends Sprite2D

var time_start = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    time_start = Time.get_ticks_usec()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
    pass

func _unhandled_input(event):
    if event is InputEventKey and event.pressed and !event.echo:
        if Time.get_ticks_usec() - time_start >= 1000000:
            get_node("../Interface").show()
            queue_free()
