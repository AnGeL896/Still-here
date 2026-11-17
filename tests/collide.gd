extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var p := scene.get_node("Player") as CharacterBody2D
	var shape := p.get_node("Shape") as CollisionShape2D

	print("спавн: ", p.position)
	print("форма: ", shape.shape.get_size(), "  позиция формы: ", shape.position)

	for i in 40:
		await physics_frame
		if i % 8 == 0 or i == 39:
			var info := "f=%2d pos=(%.2f, %.2f)" % [i, p.global_position.x, p.global_position.y]
			for ci in p.get_slide_collision_count():
				var c := p.get_slide_collision(ci)
				info += "  | collider=%s normal=%s" % [c.get_collider().name if c.get_collider() else "?", c.get_normal()]
			print(info)

	print("итог: floor=", p.is_on_floor(), " pos=", p.global_position)
	quit()