extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var story = root.get_node("Story")
	story.call("set_flag", "safe_apt_safe", false)
	print("флаг после сброса: ", story.call("has_flag", "safe_apt_safe"))

	var sc: Node = load("res://scenes/interiors/room_apt4.tscn").instantiate()
	root.add_child(sc)
	for i in 15:
		await physics_frame

	var s = sc.get_node("SafeA")
	print("safe_id      = ", s.safe_id)
	print("opened       = ", s.is_opened())
	print("prompt       = '", s.get_prompt(), "'")
	print("enabled      = ", s.enabled, "  once=", s.once, "  requires='", s.requires, "'")
	print("can_interact = ", s.can_interact())

	# что видит игрок
	var p := sc.get_node("Player") as CharacterBody2D
	p.global_position = Vector2(352, 194)
	for i in 10:
		await physics_frame
	var ui = root.get_node("UI")
	print("игрок (352,194) -> подсказка '", ui._prompt.text, "' visible=", ui._prompt.visible)

	quit()