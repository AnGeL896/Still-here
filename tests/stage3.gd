extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for i in 5:
		await process_frame

	var g1 = scene.get_node_or_null("Ghost")
	var g2 = scene.get_node_or_null("GhostGreen")

	print("Ghost      tint=", g1.tint, "  mat=", g1._mat)
	print("GhostGreen tint=", g2.tint, "  mat=", g2._mat)
	print("материалы разные: ", g1._mat != g2._mat)
	if g1._mat and g2._mat:
		print("шейдер blue  tint=", g1._mat.get_shader_parameter("tint"))
		print("шейдер green tint=", g2._mat.get_shader_parameter("tint"))

	# тест рекордера
	var rec = scene.get_node_or_null("Recorder")
	print("рекордер: ", rec != null)
	rec.call("_toggle")
	Input.action_press("move_right")
	for i in 90:
		await physics_frame
	Input.action_release("move_right")
	rec.call("_toggle")
	quit()