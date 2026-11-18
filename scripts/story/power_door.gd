extends DoorTransition
class_name PowerDoor

## Дверь, которая открывается только при питании.
## Пока питания нет — «E» не работает.

@export var indicator_off := Color(0.55, 0.16, 0.14)
@export var indicator_on := Color(0.42, 0.95, 0.62)

var _powered := false
var _lamp: Polygon2D

func _ready() -> void:
	super._ready()
	_build_lamp()
	set_powered(false)

func _build_lamp() -> void:
	_lamp = Polygon2D.new()
	_lamp.polygon = PackedVector2Array([
		Vector2(-2, -34), Vector2(2, -34),
		Vector2(2, -30), Vector2(-2, -30),
	])
	_lamp.color = indicator_off
	add_child(_lamp)

func set_powered(v: bool) -> void:
	_powered = v
	if _lamp:
		_lamp.color = indicator_on if v else indicator_off
	open_prompt = "E — выйти" if v else "E — нет питания"
	prompt = open_prompt

func is_powered() -> bool:
	return _powered

func can_interact() -> bool:
	if not super.can_interact():
		return false
	return _powered