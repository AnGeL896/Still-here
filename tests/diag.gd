extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for i in 10:
		await process_frame

	var lvl := scene.get_node("Level")
	print("дети Level:")
	for c in lvl.get_children():
		print("   ", c.name, "  type=", c.get_class(), "  visible=", c.visible)

	var d = lvl.get_node_or_null("Detail")
	if d == null:
		print("!!! Detail НЕ найден")
	else:
		print("Detail: cracks=", d._cracks.size(), " moss=", d._moss.size(),
			" rubble=", d._rubble.size(), " grass=", d._grass.size())

	var v = lvl.get_node_or_null("Visual")
	if v:
		print("Visual: fills=", v._fills.size(), " edges=", v._edges.size())

	quit()