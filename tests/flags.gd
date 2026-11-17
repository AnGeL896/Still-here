extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var sc: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(sc)
	for i in 10:
		await physics_frame

	var g = sc.get_node_or_null("Ghost")
	var g2 = sc.get_node_or_null("GhostGreen")
	print("blue  once_flag=", g.once_flag, "  active=", str(not g._done))
	print("green once_flag=", g2.once_flag, "  active=", str(not g2._done))

	var story = root.get_node("Story")
	print("флаги: ", story.get("flags"))
	quit()