extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var g := scene.get_node_or_null("Ghost")

	var marks := [60, 250, 320, 600, 900, 1080, 1140, 1200, 1320]
	var prev := 0
	for m in marks:
		for i in (m - prev):
			await physics_frame
		prev = m
		if g == null:
			print("frame %4d | ГОСТЯ НЕТ" % m)
			continue
		var s: Dictionary = g.get_debug_state()
		print("frame %4d | vis=%-5s x=%6.1f t=%5.2f alpha=%.2f dissolve=%.2f" % [
			m, s["visible"], s["x"], s["time"], s["alpha"], s["dissolve"]])

	quit()