class_name RoomPainter
extends Node2D

## База для визуальных слоёв интерьеров.
## pass_index 0 — подложка (стены, пол, потолок, AO), 1 — поверх (детали, свет, пыль).
## Каждая комната наследует этот класс и рисует своё; общими остаются только примитивы.

@export var pass_index := 0
@export var seed_value := 7

var _rng := RandomNumberGenerator.new()
var _t := 0.0

func _ready() -> void:
	_rng.seed = seed_value
	set_process(pass_index == 1)

func _process(delta: float) -> void:
	_t += delta
	queue_redraw()

func _draw() -> void:
	if pass_index == 0:
		_draw_base()
	else:
		_draw_overlay()

## Переопределяется комнатой.
func _draw_base() -> void:
	pass

## Переопределяется комнатой.
func _draw_overlay() -> void:
	pass

# ─── примитивы ────────────────────────────────────────────────

func _r(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c)

func _poly(pts: PackedVector2Array, c: Color) -> void:
	draw_colored_polygon(pts, c)

func _ln(x1: float, y1: float, x2: float, y2: float, c: Color, w := 1.0) -> void:
	draw_line(Vector2(x1, y1), Vector2(x2, y2), c, w)

func _ol(x: float, y: float, w: float, h: float, c: Color) -> void:
	draw_rect(Rect2(x, y, w, h), c, false, 1.0)

func _vg(x: float, y: float, w: float, h: float, top: Color, bottom: Color, steps: int) -> void:
	var n := maxi(steps, 1)
	for i in n:
		var k := float(i) / float(maxi(n - 1, 1))
		_r(x, y + h * float(i) / float(n), w, h / float(n) + 0.6, top.lerp(bottom, k))

func _hgrad(x: float, y: float, w: float, h: float, left: Color, right: Color, steps: int) -> void:
	var n := maxi(steps, 1)
	for i in n:
		var k := float(i) / float(maxi(n - 1, 1))
		_r(x + w * float(i) / float(n), y, w / float(n) + 0.6, h, left.lerp(right, k))

func _crack(pts: PackedVector2Array, strength := 0.55) -> void:
	draw_polyline(pts, Color(0.02, 0.02, 0.022, strength), 1.0)
	var shifted := PackedVector2Array()
	for p in pts:
		shifted.append(p + Vector2(1.0, 0.0))
	draw_polyline(shifted, Color(1, 1, 1, 0.05), 1.0)

## Мелкий шум: снимает плоскость. Координаты — прямоугольник.
func _noise(count: int, x0: float, y0: float, x1: float, y1: float,
		light := 0.022, dark := 0.05) -> void:
	for n in count:
		var px := _rng.randf_range(x0, x1)
		var py := _rng.randf_range(y0, y1)
		if _rng.randf() < 0.5:
			_r(px, py, 1.0, 1.0, Color(1, 1, 1, light))
		else:
			_r(px, py, 1.0, 1.0, Color(0, 0, 0, dark))

## Пылинки в конусе света. dust_count штук, область задаётся вызывающим.
func _dust_mote(x: float, y: float, a: float) -> void:
	_r(x, y, 1.0, 1.0, Color(1.0, 0.96, 0.86, a))