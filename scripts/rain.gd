extends Node2D

## Лёгкий дождь — сетевидные капли, которые создают атмосферу без шума.

@export var amount := 40
@export var color := Color(0.55, 0.62, 0.75, 0.28)
@export var speed := 180.0
@export var area := Vector2(480, 270)
@export var wind := Vector2(-30.0, 0.0)

var _drops: Array = []

func _ready() -> void:
	z_index = -1  # за уровнем
	for i in amount:
		_drops.append({
			"x": randf() * (area.x + 60.0) - 30.0,
			"y": randf() * area.y,
			"len": randf_range(3.0, 8.0),
			"spd": randf_range(0.7, 1.3),
		})

func _process(delta: float) -> void:
	for d in _drops:
		d["y"] += speed * d["spd"] * delta
		d["x"] += wind.x * delta
		if d["y"] > area.y + 10.0:
			d["y"] = -10.0
			d["x"] = randf() * (area.x + 60.0) - 30.0
		if d["x"] < -30.0:
			d["x"] = area.x + 30.0
		elif d["x"] > area.x + 30.0:
			d["x"] = -30.0
	queue_redraw()

func _draw() -> void:
	for d in _drops:
		var x: float = d["x"]
		var y: float = d["y"]
		var ln: float = d["len"]
		var slant := wind.x * 0.02
		draw_line(
			Vector2(x, y),
			Vector2(x + slant, y + ln),
			color,
			0.7
		)