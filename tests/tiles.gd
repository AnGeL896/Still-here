extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var lvl_script = load("res://scripts/level.gd")
	var n = lvl_script.new()
	root.add_child(n)
	for i in 3:
		await process_frame

	var layer := n.get_node_or_null("Geometry") as TileMapLayer
	var ts := layer.tile_set
	var atlas := ts.get_source(0) as TileSetAtlasSource

	for id in [1, 2, 3]:
		var td := atlas.get_tile_data(Vector2i(id, 0), 0)
		print("тайл ", id,
			" полигонов: ", td.get_collision_polygons_count(0),
			" точки: ", td.get_collision_polygon_points(0, 0))

	# что реально стоит в клетках слева от игрока
	for y in [14, 15, 16, 17]:
		var line := "ряд y=%d: " % y
		for x in range(0, 7):
			var d := layer.get_cell_tile_data(Vector2i(x, y))
			if d == null:
				line += " .  "
			else:
				var src := layer.get_cell_source_id(Vector2i(x, y))
				var at := layer.get_cell_atlas_coords(Vector2i(x, y))
				line += "%d:%s " % [at.x, "S" if d.get_collision_polygons_count(0) > 0 else "-"]
		print(line)

	quit()