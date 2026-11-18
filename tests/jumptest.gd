extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var bs: Node = load("res://scenes/interiors/basement.tscn").instantiate()
	root.add_child(bs)
	for i in 20:
		await physics_frame
	var p := bs.get_node("Player") as CharacterBody2D

	print("до прыжка: y=%.1f floor=%s" % [p.global_position.y, p.is_on_floor()])
	Input.action_press("jump")
	for i in 10:
		await physics_frame
	print("в прыжке: y=%.1f vy=%.1f floor=%s" % [p.global_position.y, p.velocity.y, p.is_on_floor()])
	Input.action_release("jump")
	for i in 60:
		await physics_frame
	print("приземлился: y=%.1f floor=%s" % [p.global_position.y, p.is_on_floor()])

	# теперь вплотную к ящику и прыжок с разбегу
	p.global_position = Vector2(180, 210)
	for i in 5:
		await physics_frame
	Input.action_press("move_right")
	Input.action_press("jump")
	for i in 30:
		await physics_frame
	print("у ящика: x=%.1f y=%.1f" % [p.global_position.x, p.global_position.y])
	Input.action_release("jump")
	for i in 40:
		await physics_frame
	Input.action_release("move_right")
	print("после: x=%.1f y=%.1f" % [p.global_position.x, p.global_position.y])

	quit()