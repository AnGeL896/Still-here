extends Node2D
class_name Ghost

## Призрак: проигрывает GhostTrack, ждёт игрока рядом и растворяется шумом.

const GhostTrack = preload("res://scripts/ghost_track.gd")

@export_category("Трек")
@export var track: GhostTrack
## Если трек не задан — собираем из точек (для быстрой расстановки в редакторе).
@export var waypoints: PackedVector2Array = PackedVector2Array()
@export var walk_speed := 24.0
## Путь к .tres с записанным треком (приоритетнее waypoints).
@export var track_path := ""

@export_category("Тайминг")
## Видеть призрака можно только когда игрок подошёл. -1 = появляться сразу.
@export var trigger_radius := 240.0
## Если задан — эхо срабатывает один раз за прохождение.
@export var once_flag := ""
## На этом расстоянии призрак перестаёт идти и начинает гаснуть.
@export var watch_radius := 85.0
## Сколько секунд стоит и смотрит на игрока перед тем, как начать гаснуть.
@export var end_hold := 1.0
@export var fade_in := 0.6
@export var fade_out := 2.0

@export_category("Вид")
@export var tint := Color(0.62, 0.78, 0.95)
@export var glow_color := Color(0.60, 0.78, 1.0)
@export var base_alpha := 0.95
@export var glow_energy := 0.9
@export var body_scale := 0.95

var _time := 0.0
var _elapsed := 0.0
var _triggered := false
var _ending := false
var _end_t := 0.0
var _done := false

var _mat: ShaderMaterial
var _visual: Node2D
var _light: PointLight2D
var _parts: Array[Polygon2D] = []
var _player: Node2D

func _ready() -> void:
	add_to_group("ghost")

	_visual = get_node_or_null("Visual") as Node2D
	_light = get_node_or_null("Light") as PointLight2D
	if _visual:
		_visual.scale = Vector2(body_scale, body_scale)

	# полигоны лежат в Visual, поэтому ищем рекурсивно
	_parts.clear()
	for p in find_children("*", "Polygon2D", true, false):
		_parts.append(p as Polygon2D)

	if not _parts.is_empty() and _parts[0].material is ShaderMaterial:
		# дублируем материал: у каждого призрака свой цвет
		_mat = (_parts[0].material as ShaderMaterial).duplicate() as ShaderMaterial
		_mat.set_shader_parameter("tint", tint)
		for p in _parts:
			p.material = _mat
	if _light:
		_light.color = glow_color

	if track_path != "" and (track == null or track.is_empty()):
		var loaded = load(track_path)
		if loaded is GhostTrack:
			track = loaded
	if (track == null or track.is_empty()) and waypoints.size() >= 2:
		track = GhostTrack.from_waypoints(waypoints, walk_speed)

	if track == null or track.is_empty():
		set_process(false)
		return

	# стартуем там, где начинается трек — иначе призрак «прыгнёт» при срабатывании
	var first: Dictionary = track.frames[0]
	position = Vector2(float(first["x"]), float(first["y"]))

	# уже видели это эхо в прошлом прохождении — не повторяем
	if once_flag != "" and Story.has_flag(once_flag):
		_done = true
		visible = false
		set_process(false)
		return

	visible = false
	_apply_fade(0.0, 0.0)

func _process(delta: float) -> void:
	if _done:
		return

	# ── ждём, пока игрок подойдёт ──
	if not _triggered:
		if trigger_radius < 0.0:
			_triggered = true
		else:
			if _player == null or not is_instance_valid(_player):
				_player = get_tree().get_first_node_in_group("player") as Node2D
			if _player and global_position.distance_to(_player.global_position) <= trigger_radius:
				_triggered = true
				_elapsed = 0.0
				if once_flag != "":
					Story.set_flag(once_flag)
			else:
				return

	visible = true
	_elapsed += delta

	# ── идём по треку ──
	if not _ending:
		_time = minf(_time + delta, track.duration())
	var s: Dictionary = track.sample(_time)
	position = Vector2(float(s.get("x", position.x)), float(s.get("y", position.y)))

	var face_left := bool(s.get("flip", false))
	if _visual:
		_visual.scale.x = -body_scale if face_left else body_scale

	# ── конец трека или игрок вплотную → останавливаемся и гаснем ──
	if not _ending:
		var close_enough := _player != null and is_instance_valid(_player) \
			and global_position.distance_to(_player.global_position) <= watch_radius
		if _time >= track.duration() - 0.001 or close_enough:
			_ending = true
			_end_t = -end_hold
			# перед уходом смотрим на игрока
			if _player and _visual:
				var look := signf(_player.global_position.x - global_position.x)
				if look != 0.0:
					_visual.scale.x = look * body_scale
	else:
		_end_t += delta

	var appear: float = clampf(_elapsed / maxf(fade_in, 0.001), 0.0, 1.0)
	var diss: float = 0.0
	if _ending:
		diss = clampf(maxf(0.0, _end_t) / maxf(fade_out, 0.001), 0.0, 1.0)

	_apply_fade(appear * base_alpha, diss)

	if diss >= 1.0:
		_done = true
		visible = false
		set_process(false)

func _apply_fade(a: float, d := 0.0) -> void:
	_last_alpha = a
	_last_dissolve = d
	# плавное появление/исчезновение через modulate + scale
	var fade := a * (1.0 - d)
	modulate = Color(1.0, 1.0, 1.0, fade)
	# лёгкое уменьшение при исчезновении
	if d > 0.0:
		var s := body_scale * (1.0 - d * 0.3)
		scale = Vector2(s, s)
	else:
		scale = Vector2(body_scale, body_scale)
	if _mat:
		_mat.set_shader_parameter("alpha", a)
		_mat.set_shader_parameter("dissolve", d)
	if _light:
		_light.energy = glow_energy * fade

var _last_alpha := 0.0
var _last_dissolve := 0.0

func get_debug_state() -> Dictionary:
	return {
		"visible": visible,
		"x": global_position.x,
		"y": global_position.y,
		"time": _time,
		"elapsed": _elapsed,
		"alpha": _last_alpha,
		"dissolve": _last_dissolve,
		"done": _done,
		"triggered": _triggered,
		"ending": _ending,
	}

func restart() -> void:
	_time = 0.0
	_elapsed = 0.0
	_end_t = 0.0
	_triggered = false
	_ending = false
	_done = false
	visible = false
	set_process(true)
	_apply_fade(0.0, 0.0)