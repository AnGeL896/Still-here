extends SceneTree

func _initialize() -> void:
	_run()

func _run() -> void:
	var scene: Node = load("res://scenes/main.tscn").instantiate()
	root.add_child(scene)
	var p := scene.get_node("Player") as CharacterBody2D
	for i in 20:
		await physics_frame

	var note := scene.get_node_or_null("Note1")
	var ui = root.get_node_or_null("UI")
	var story = root.get_node_or_null("Story")

	print("note found: ", note != null)
	print("UI autoload: ", ui != null)

	if note:
		print("can_interact far: ", note.can_interact())
		print("prompt: ", note.get_prompt())

	p.global_position = Vector2(300, 242)
	for i in 12:
		await physics_frame
	print("prompt visible: ", ui._prompt.visible)
	print("prompt text  : ", ui._prompt.text)

	note.interact(p)
	for i in 6:
		await process_frame
	print("note open   : ", ui.is_note_open())
	print("frozen      : ", p.frozen)
	print("note read   : ", story.call("is_note_read", "notice_01"))
	print("flag set    : ", story.call("has_flag", "read_notice_01"))

	quit()