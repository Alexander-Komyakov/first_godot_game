extends Sprite2D

var time = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
    pass # Replace with function body.


func _process(delta):
    time += delta
    # Мерцание/переливание цвета
    modulate.b = 0.8 + sin(time * 1.0) * 0.2
