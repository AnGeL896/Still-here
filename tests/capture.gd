extends SceneTree

func _initialize() -> void:
	_run()

func _snap(name: String) -> void:
	await RenderingServer.frame_post_draw
	var vp := root.get_viewport()
	var img := vp.get_texture().get_image()
	img.save_png("res://tests/%s.png" % name)
	print("saved ", name, " ", img.get_width(), "x", img.get_height())

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var p := scene.get_node("Player") as CharacterBody2D

	for i in 200:
		await process_frame
	await _snap("shot_idle")

	Input.action_press("move_right")
	var n := 0
	for i in 200:
		await physics_frame
		await process_frame
		if n < 2 and i % 3 == 0:
			await _snap("shot_walk%d" % n)
			var body := p.get_node("Body") as Polygon2D
			print("  walk%d player=(%.3f,%.3f) body=%s canvas=%s" % [
				n, p.global_position.x, p.global_position.y, body.global_position,
				body.get_global_transform_with_canvas().origin])
			n += 1
		if p.global_position.x > 220:
			break
	Input.action_release("move_right")
	quit()