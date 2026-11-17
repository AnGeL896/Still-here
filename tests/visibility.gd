extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)

	var p := scene.get_node("Player") as CharacterBody2D
	var g := scene.get_node("Ghost") as Node2D
	var cam := scene.get_node("Player/Camera") as Camera2D

	var vp: Vector2 = root.get_visible_rect().size
	print("viewport = ", vp)

	Input.action_press("move_right")

	var first_seen := -1
	for i in 1500:
		await physics_frame

		var st: Dictionary = g.get_debug_state()
		var center := cam.get_screen_center_position()
		var half := vp * 0.5
		var view := Rect2(center - half, vp)
		var gpos: Vector2 = g.global_position + Vector2(0, -18)
		var on_screen: bool = view.has_point(gpos)

		if i % 120 == 0:
			print("f=%4d player.x=%6.1f ghost.x=%6.1f vis=%-5s onscreen=%-5s view=[%.0f..%.0f]" % [
				i, p.global_position.x, g.global_position.x, st["visible"], on_screen,
				view.position.x, view.end.x])

		if on_screen and st["visible"] and first_seen < 0:
			first_seen = i
			print(">>> ГОСТЬ Впервые на экране на кадре %d, player.x=%.0f ghost.x=%.0f" % [i, p.global_position.x, g.global_position.x])

		if st["done"]:
			print("гость растворился на кадре %d" % i)
			break

	print("ИТОГ: на экране появлялся =", first_seen >= 0)
	quit()