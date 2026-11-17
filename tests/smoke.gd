extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)

	for i in 90:
		await process_frame

	var p := scene.get_node_or_null("Player") as CharacterBody2D
	if p == null:
		print("SMOKE FAIL: Player not found")
		quit()
		return

	print("SMOKE pos=%s floor=%s state=%s" % [p.global_position, p.is_on_floor(), p.get_state()])

	var cam := scene.get_node_or_null("Player/Camera") as Camera2D
	print("SMOKE camera=%s current=%s" % [cam.global_position if cam else "none", cam.enabled if cam else false])

	var level := scene.get_node_or_null("Level")
	print("SMOKE level_children=%d" % (level.get_child_count() if level else -1))

	quit()