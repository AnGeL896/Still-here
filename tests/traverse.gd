extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var bs: Node = load("res://scenes/interiors/basement.tscn").instantiate()
	root.add_child(bs)
	for i in 20:
		await physics_frame
	var p := bs.get_node("Player") as CharacterBody2D

	print("старт x=%.0f" % p.global_position.x)
	Input.action_press("move_right")
	for i in 300:
		await physics_frame
		# прыгаем каждые 25 кадров — как живой игрок
		if i % 25 == 0:
			Input.action_press("jump")
		if i % 25 == 6:
			Input.action_release("jump")
	print("подвал: x=%.0f (ящики на 192..240 и 368..400)" % p.global_position.x)

	bs.queue_free()
	for i in 5:
		await physics_frame

	var at: Node = load("res://scenes/interiors/attic.tscn").instantiate()
	root.add_child(at)
	for i in 20:
		await physics_frame
	var p2 := at.get_node("Player") as CharacterBody2D
	print("старт x=%.0f" % p2.global_position.x)
	Input.action_press("move_right")
	for i in 300:
		await physics_frame
		if i % 25 == 0:
			Input.action_press("jump")
		if i % 25 == 6:
			Input.action_release("jump")
	print("чердак: x=%.0f (ящики на 176..224 и 368..432)" % p2.global_position.x)

	quit()