extends SceneTree

func _initialize() -> void:
	_run()

func _load(path: String) -> Node:
	var sc: Node = load(path).instantiate()
	root.add_child(sc)
	for i in 15:
		await physics_frame
	return sc

func _run() -> void:
	# ── двор/квартира ──
	var room := await _load("res://scenes/interiors/room_apt4.tscn")
	print("КВАРТИРА")
	for n in ["AtticLadder", "BasementHatch", "FuseBox", "Exit", "FuseC"]:
		print("   {0,-14} {1}".format([n, room.get_node_or_null(n) != null]))
	var inv = root.get_node("Inventory")
	print("   счётчик до подбора: ", (root.get_node("UI")._hud.visible))
	room.get_node("FuseC").call("interact", null)
	for i in 3:
		await process_frame
	print("   подобрал, счётчик: ", (root.get_node("UI")._hud.visible), " текст='", (root.get_node("UI")._hud.text), "'")
	room.queue_free()
	for i in 5:
		await physics_frame

	# ── подвал ──
	var bs := await _load("res://scenes/interiors/basement.tscn")
	print("ПОДВАЛ  игрок=", (bs.get_node("Player") as Node2D).global_position)
	print("   предохранитель: ", bs.get_node_or_null("FuseHidden") != null)
	print("   выход: ", bs.get_node_or_null("Exit") != null)
	bs.queue_free()
	for i in 5:
		await physics_frame

	# ── чердак ──
	var at := await _load("res://scenes/interiors/attic.tscn")
	print("ЧЕРДАК  игрок=", (at.get_node("Player") as Node2D).global_position)
	print("   сундук: ", at.get_node_or_null("Chest") != null)
	print("   ящики: ", at.get_node_or_null("BoxA") != null, " ", at.get_node_or_null("BoxB") != null)
	at.get_node("Chest").call("interact", null)
	for i in 3:
		await process_frame
	print("   лут из сундука: ", inv.count("fuse"), " шт")
	at.queue_free()

	quit()