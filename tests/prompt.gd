extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var sc: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(sc)
	var p := sc.get_node("Player") as CharacterBody2D
	for i in 20:
		await physics_frame

	var door = sc.get_node_or_null("HouseDoor")
	print("door prompt (свойство): [", door.get_prompt(), "]")

	p.global_position = Vector2(1180, 242)
	for i in 20:
		await physics_frame

	var ui = root.get_node("UI")
	print("label text: [", ui._prompt.text, "]")
	print("label visible: ", ui._prompt.visible)
	print("label size: ", ui._prompt.size, " font_size: ", ui._prompt.get_theme_font_size("font_size"))
	print("label position: ", ui._prompt.position)

	var codes := ""
	for c in ui._prompt.text:
		codes += str(c.unicode_at(0)) + " "
	print("кодпоинты: ", codes)

	var f = ui._prompt.get_theme_font("font")
	print("шрифт: ", f, " -> ", f.get_font_name() if f else "НЕТ")
	if f:
		print("  есть глиф 'ы' (U+044B): ", f.has_char(0x044B))
		print("  есть глиф '—' (U+2014): ", f.has_char(0x2014))
		print("  есть глиф 'E': ", f.has_char(0x45))

	quit()