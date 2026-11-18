extends PointLight2D

## Мерцающая лампа. Три синуса с разными частотами дают нервный, но не хаотичный свет.

@export var base_energy := 0.9
@export var flicker_amount := 0.22
@export var speed := 6.5

var _t := 0.0
var _seed := 0.0

func _ready() -> void:
	_seed = randf() * 100.0

func _process(delta: float) -> void:
	_t += delta * speed
	var n := sin(_t + _seed) * 0.5 + sin(_t * 2.7 + _seed * 2.0) * 0.3 + sin(_t * 5.3) * 0.2
	energy = base_energy * (1.0 - flicker_amount * 0.5 + n * flicker_amount * 0.5)