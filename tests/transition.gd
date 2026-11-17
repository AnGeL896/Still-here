extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	for i in 15:
		await physics_frame

	var door = scene.get_node_or_null("HouseDoor")
	print("РґРІРµСЂСЊ РІ РґРѕРјРµ: ", door != null)
	if door:
		print("  target: ", door.target_scene)
		print("  spawn : ", door.target_spawn)
		print("  prompt: ", door.get_prompt())
		print("  РјРѕР¶РЅРѕ : ", door.can_interact())

	var note = scene.get_node_or_null("Note1")
	print("Р·Р°РїРёСЃРєР° РІРѕ РґРІРѕСЂРµ: ", note != null, " -> ", note.note.id if note and note.note else "РЅРµС‚")

	print("--- РїРµСЂРµС…РѕРґ ---")
	door.interact(scene.get_node("Player"))
	for i in 150:
		await process_frame

	var cs = current_scene
	print("С‚РµРєСѓС‰Р°СЏ СЃС†РµРЅР°: ", cs.name if cs else "РќР•Рў")
	var p = cs.get_node_or_null("Player") as Node2D if cs else null
	print("РёРіСЂРѕРє: ", p.global_position if p else "РќР•Рў")

	var cup = cs.get_node_or_null("Cupboard") as Node
	if cup:
		print("С€РєР°С„: prompt='", cup.get_prompt(), "'")
		cup.call("interact", p)
		print("РїРѕСЃР»Рµ РєР»РёРєР°: prompt='", cup.get_prompt(), "'")
	var n2 = cs.get_node_or_null("Table/Note") as Node
	print("Р·Р°РїРёСЃРєР° РІ РєРѕРјРЅР°С‚Рµ: ", n2 != null, " -> ", n2.note.id if n2 and n2.note else "РЅРµС‚")

	quit()