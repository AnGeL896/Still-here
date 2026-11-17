extends Node2D
class_name Interactable

## Базовый интерактивный объект.
## Игрок сам ищет ближайший в группе "interactable" — физика не нужна.

@export var prompt := "E"
@export var once := false
@export var requires := ""
@export var enabled := true
@export var radius := 34.0

var _used := false

func _ready() -> void:
	add_to_group("interactable")

func can_interact() -> bool:
	if not enabled:
		return false
	if once and _used:
		return false
	if requires != "" and not Story.has_flag(requires):
		return false
	return true

func get_prompt() -> String:
	return prompt

func get_radius() -> float:
	return radius

func interact(_player: Node) -> void:
	if not can_interact():
		return
	if once:
		_used = true