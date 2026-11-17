extends Interactable
class_name DoorTransition

## Дверь между сценами. E — переход с затемнением.

@export var target_scene := ""
@export var target_spawn := Vector2.ZERO
@export var locked_flag := ""
@export var open_prompt := "E — войти"

func _ready() -> void:
	super._ready()
	if prompt == "E":
		prompt = open_prompt

func can_interact() -> bool:
	if not super.can_interact():
		return false
	if locked_flag != "" and not Story.has_flag(locked_flag):
		return false
	return true

func interact(_player: Node) -> void:
	if locked_flag != "" and not Story.has_flag(locked_flag):
		return
	if target_scene == "":
		return
	SceneFlow.go_to(target_scene, target_spawn)