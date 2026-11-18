extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/interiors/room_apt4.tscn").instantiate()
	root.add_child(scene)
	for i in 20:
		await physics_frame

	var box = scene.get_node_or_null("FuseBox")
	var door = scene.get_node_or_null("Exit")
	print("щиток: ", box != null, "  дверь: ", door != null)
	print("дверь powered до: ", door.is_powered(), "  can_interact=", door.can_interact())
	print("подсказка двери: ", door.get_prompt())

	# собираем 3 предохранителя программно
	var inv = root.get_node("Inventory")
	inv.add("fuse", 3)
	print("в инвентаре: ", inv.count("fuse"))

	for i in 3:
		box.call("interact", null)
		print("вставил, слотов: ", box.get_slots(), "  powered=", box.is_powered())

	print("дверь powered после: ", door.is_powered(), "  can_interact=", door.can_interact())
	print("подсказка двери: ", door.get_prompt())

	quit()