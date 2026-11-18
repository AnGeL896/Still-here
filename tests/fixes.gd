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
	var story = root.get_node("Story")

	# ── подвал: можно ли пройти? ──
	var bs := await _load("res://scenes/interiors/basement.tscn")
	var p := bs.get_node("Player") as CharacterBody2D
	Input.action_press("move_right")
	for i in 260:
		await physics_frame
	Input.action_release("move_right")
	print("ПОДВАЛ: игрок x=%.0f (старт 68, TJ1780)  floor=%s" % [p.global_position.x, p.is_on_floor()])
	bs.queue_free()
	for i in 5:
		await physics_frame

	# ── чердак: можно ли пройти? ──
	var at := await _load("res://scenes/interiors/attic.tscn")
	var p2 := at.get_node("Player") as CharacterBody2D
	Input.action_press("move_right")
	for i in 260:
		await physics_frame
	Input.action_release("move_right")
	print("ЧЕРДАК: игрок x=%.0f (старт 64)  floor=%s" % [p2.global_position.x, p2.is_on_floor()])
	at.queue_free()
	for i in 5:
		await physics_frame

	# ── подбор и сохранение ──
	story.call("set_flag", "picked_room_fuse", false)
	var room := await _load("res://scenes/interiors/room_apt4.tscn")
	var f = room.get_node("FuseC")
	print("В КВАРТИРЕ до подбора: visible=", f.visible)
	f.call("interact", null)
	for i in 3:
		await process_frame
	print("после подбора: visible=", f.visible, "  флаг=", story.call("has_flag", "picked_room_fuse"))
	room.queue_free()
	for i in 5:
		await physics_frame

	var room2 := await _load("res://scenes/interiors/room_apt4.tscn")
	var f2 = room2.get_node("FuseC")
	print("В КВАРТИРЕ после перезахода: visible=", f2.visible, "  enabled=", f2.enabled)

	quit()