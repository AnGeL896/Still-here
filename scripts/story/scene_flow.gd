extends CanvasLayer

## Переходы между сценами с затемнением.
## Spawn = позиция игрока в НОВОЙ сцене. Vector2.ZERO — оставить как в сцене.

var _fade: ColorRect
var _busy := false

func _ready() -> void:
	# 120 — выше UI и постобработки, затемнение должно накрывать всё
	layer = 120
	_fade = ColorRect.new()
	_fade.color = Color(0.0, 0.0, 0.0, 0.0)
	_fade.position = Vector2.ZERO
	_fade.size = Vector2(480, 270)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_fade)

func is_busy() -> bool:
	return _busy

func go_to(path: String, spawn := Vector2.ZERO) -> void:
	if _busy:
		return
	_busy = true

	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.22)
	await tw.finished

	var err := get_tree().change_scene_to_file(path)
	if err != OK:
		push_warning("SceneFlow: не удалось загрузить " + path)
		_fade.color.a = 0.0
		_busy = false
		return

	await get_tree().process_frame
	await get_tree().process_frame

	if spawn != Vector2.ZERO:
		var p := get_tree().get_first_node_in_group("player") as Node2D
		if p:
			p.global_position = spawn
			if p is CharacterBody2D:
				(p as CharacterBody2D).velocity = Vector2.ZERO
			if p.has_method("snap_camera"):
				p.call("snap_camera")

	var tw2 := create_tween()
	tw2.tween_property(_fade, "color:a", 0.0, 0.30)
	await tw2.finished

	_busy = false