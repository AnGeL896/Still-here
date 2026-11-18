extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var inv = root.get_node("Inventory")
	var story = root.get_node("Story")
	inv.clear()
	for k in ["safe_apt_safe", "safe_basement_safe", "safe_attic_safe"]:
		story.call("set_flag", k, false)

	var ui = root.get_node("UI")
	print("=== КВАРТИРА ===")
	var room: Node = load("res://scenes/interiors/room_apt4.tscn").instantiate()
	root.add_child(room)
	var p := room.get_node("Player") as CharacterBody2D
	for i in 15: await physics_frame
	p.global_position = Vector2(352, 194)
	for i in 10: await physics_frame
	print("  у сейфа подсказка: '", ui._prompt.text, "'  видна=", ui._prompt.visible)
	var s = room.get_node("SafeA")
	s.call("interact", p)
	for i in 3: await process_frame
	print("  окно сейфа: ", ui._safe_root.visible, "  игрок заморожен=", p.frozen)
	print("  ввод кода 471: ", s.call("try_code", "471"))
	for i in 5: await process_frame
	print("  сейф открыт: ", s.is_opened(), "  фузов: ", inv.count("fuse"))
	room.queue_free()
	for i in 5: await physics_frame

	print("=== ПОДВАЛ ===")
	var bs: Node = load("res://scenes/interiors/basement.tscn").instantiate()
	root.add_child(bs)
	for i in 15: await physics_frame
	print("  сейф: ", bs.get_node_or_null("SafeB") != null, "  код=", (bs.get_node("SafeB") as Node).get_code())
	print("  записка: ", bs.get_node_or_null("BasementNote") != null)
	bs.queue_free()
	for i in 5: await physics_frame

	print("=== ЧЕРДАК ===")
	var at: Node = load("res://scenes/interiors/attic.tscn").instantiate()
	root.add_child(at)
	for i in 15: await physics_frame
	print("  сейф: ", at.get_node_or_null("SafeC") != null, "  код=", (at.get_node("SafeC") as Node).get_code())
	at.queue_free()

	quit()