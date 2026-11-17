extends SceneTree

func _initialize() -> void:
	_run()

func _settle(p: CharacterBody2D) -> void:
	for i in 120:
		await physics_frame
		if p.is_on_floor() and absf(p.velocity.y) < 1.0:
			return

func _jump(p: CharacterBody2D, hold: int) -> float:
	var ground := p.global_position.y
	var min_y := ground
	Input.action_press("jump")
	for i in hold:
		await physics_frame
		min_y = minf(min_y, p.global_position.y)
	Input.action_release("jump")
	for i in 120:
		await physics_frame
		min_y = minf(min_y, p.global_position.y)
		if p.is_on_floor() and p.velocity.y >= 0.0:
			break
	return ground - min_y

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var p := scene.get_node("Player") as CharacterBody2D

	await _settle(p)

	var h_tap := await _jump(p, 2)
	await _settle(p)
	var h_mid := await _jump(p, 8)
	await _settle(p)
	var h_full := await _jump(p, 60)
	await _settle(p)

	print("TAP  (2 кадра)   = %.1f px  (%.2f тайла)" % [h_tap, h_tap / 16.0])
	print("MID  (8 кадров)  = %.1f px  (%.2f тайла)" % [h_mid, h_mid / 16.0])
	print("FULL (держим)    = %.1f px  (%.2f тайла)" % [h_full, h_full / 16.0])

	Input.action_press("move_right")
	for i in 40:
		await physics_frame
	var vmax: float = p.velocity.x
	print("RUN  = %.1f px/s  (%.2f тайла/с)" % [vmax, vmax / 16.0])
	Input.action_release("move_right")

	quit()