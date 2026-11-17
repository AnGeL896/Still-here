extends Node2D

## Инструмент разработки: записывает путь игрока в GhostTrack.
## F9 — старт, F9 ещё раз — стоп и сохранение в res://tracks/
## Линия показывает записанный маршрут.

@export var hotkey: Key = KEY_F9
@export var line_color := Color(0.35, 1.0, 0.6, 0.9)
@export var marker_color := Color(1.0, 0.55, 0.3, 0.9)

var _rec := false
var _frames: Array = []
var _t := 0.0
var _player: Node2D
var _counter := 0

func _ready() -> void:
	z_index = 100
	print("[record] F9 — начать запись трека")

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.physical_keycode == hotkey:
			_toggle()
			get_viewport().set_input_as_handled()

func _process(delta: float) -> void:
	if not _rec:
		return
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		return
	_t += delta
	_frames.append({
		"t": _t,
		"x": _player.global_position.x,
		"y": _player.global_position.y,
		"flip": false,
	})
	queue_redraw()

func _toggle() -> void:
	if _rec:
		_stop()
	else:
		_start()

func _start() -> void:
	_rec = true
	_frames.clear()
	_t = 0.0
	print("[record] СТАРТ — иди по маршруту, потом F9")

func _stop() -> void:
	_rec = false
	print("[record] СТОП — кадров: ", _frames.size())
	if _frames.size() < 4:
		print("[record] слишком коротко, отмена")
		_frames.clear()
		queue_redraw()
		return

	var track := GhostTrack.new()
	for f in _frames:
		track.add_frame(float(f["t"]), float(f["x"]), float(f["y"]), bool(f["flip"]))

	var stamp := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "_")
	var path := "res://tracks/rec_%s.tres" % stamp
	var err := ResourceSaver.save(track, path)
	print("[record] сохранено: ", path)
	print("[record] длительность: ", snappedf(track.duration(), 0.01), " s, ошибка: ", err)

	_counter += 1
	_frames.clear()
	queue_redraw()

func _draw() -> void:
	if _frames.size() < 2:
		return
	var pts := PackedVector2Array()
	for f in _frames:
		pts.append(Vector2(float(f["x"]), float(f["y"]) - 14.0))
	draw_polyline(pts, line_color, 1.0)
	for f in _frames:
		if int(f["t"] * 10.0) % 10 == 0:
			draw_circle(Vector2(float(f["x"]), float(f["y"]) - 14.0), 1.5, marker_color)
	if _rec:
		var head := Vector2(float(_frames[_frames.size() - 1]["x"]), float(_frames[_frames.size() - 1]["y"]) - 14.0)
		draw_circle(head, 2.5, Color(1, 1, 1, 0.9))