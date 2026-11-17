extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)

	for i in 20:
		await physics_frame

	var p := scene.get_node("Player") as CharacterBody2D
	print("РёРіСЂРѕРє: pos=", p.global_position, " floor=", p.is_on_floor())

	var lvl := scene.get_node("Level")
	var layer := lvl.get_node_or_null("Collision")
	if layer is TileMapLayer:
		print("С‚Р°Р№Р»РѕРІ РїРѕСЃС‚Р°РІР»РµРЅРѕ: ", layer.get_used_cells().size())
		print("РєРѕР»-РІРѕ РёСЃС‚РѕС‡РЅРёРєРѕРІ С‚Р°Р№Р»СЃРµС‚Р°: ", layer.tile_set.get_source_count())
		print("С„РёР·РёС‡РµСЃРєРёС… СЃР»РѕС‘РІ: ", layer.tile_set.get_physics_layers_count())
		# РїСЂРѕРІРµСЂСЏРµРј РєРѕР»Р»РёР·РёСЋ РїРѕРґ РЅРѕРіР°РјРё
		var below := Vector2i(int(floor(p.global_position.x / 16.0)), int(floor((p.global_position.y + 12.0) / 16.0)))
		print("РєР»РµС‚РєР° РїРѕРґ РЅРѕРіР°РјРё ", below, " -> ", layer.get_cell_tile_data(below))
	else:
		print("!!! Geometry РЅРµ TileMapLayer")

	# РїСЂРѕР№С‚Рё РІРїСЂР°РІРѕ Рё РїСЂРѕРІРµСЂРёС‚СЊ, С‡С‚Рѕ РЅРµ РїСЂРѕРІР°Р»РёРІР°РµРјСЃСЏ
	Input.action_press("move_right")
	var min_y := p.global_position.y
	for i in 240:
		await physics_frame
		min_y = minf(min_y, p.global_position.y)
	Input.action_release("move_right")
	print("РїРѕСЃР»Рµ Р±РµРіР°: pos=", p.global_position, " floor=", p.is_on_floor(), " min_y=", min_y)

	# РїСЂС‹Р¶РѕРє
	Input.action_press("jump")
	for i in 60:
		await physics_frame
	Input.action_release("jump")
	for i in 40:
		await physics_frame
	print("РїРѕСЃР»Рµ РїСЂС‹Р¶РєР°: pos=", p.global_position, " floor=", p.is_on_floor())

	quit()