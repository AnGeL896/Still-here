extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for i in 5:
		await physics_frame

	var lvl := scene.get_node("Level") as Node2D
	var ws := lvl.get_world_2d()
	var space := ws.direct_space_state

	for x in [80.0, 200.0, 900.0]:
		var q := PhysicsRayQueryParameters2D.create(Vector2(x, 200.0), Vector2(x, 310.0))
		var hit := space.intersect_ray(q)
		if hit.is_empty():
			print("x=%.0f : ничего" % x)
		else:
			print("x=%.0f : коллизия на y=%.2f  (тайл y=%d)  нормаль=%s" % [
				x, hit.position.y, int(hit.position.y / 16.0), hit.normal])

	var layer := lvl.get_node("Geometry") as TileMapLayer
	for y in [15, 16, 17]:
		var d := layer.get_cell_tile_data(Vector2i(5, y))
		print("клетка (5,%d) -> %s" % [y, "есть" if d != null else "пусто"])

	quit()