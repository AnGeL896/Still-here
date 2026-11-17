extends Node2D

## Детали поверх визуала: трещины, мох, щебень, травинки.
## Только неровности, никакой плитки.

const TILE := 16
const T_DEEP := 6

var _cracks: Array = []
var _moss: Array = []
var _rubble: Array = []
var _grass: Array = []

func setup(cells: Dictionary, seed_value: int) -> void:
	_cracks.clear()
	_moss.clear()
	_rubble.clear()
	_grass.clear()

	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value

	for pos: Vector2i in cells:
		var mat: int = cells[pos]
		if mat == T_DEEP:
			continue

		var bx: float = pos.x * TILE
		var by: float = pos.y * TILE

		var r := rng.randf()
		if r < 0.11:
			_cracks.append(_make_crack(rng, bx, by))
		elif r < 0.19:
			_moss.append(Rect2(
				bx + rng.randf_range(0.0, 7.0),
				by + rng.randf_range(6.0, 12.0),
				rng.randf_range(3.0, 9.0),
				rng.randf_range(2.0, 4.0)
			))

		# открытая поверхность сверху
		if cells.has(Vector2i(pos.x, pos.y - 1)):
			continue
		if mat != 1 and mat != 2 and mat != 7:
			continue

		# трава: тонкие травинки
		if rng.randf() < 0.38:
			var tufts := rng.randi_range(1, 4)
			var blades: Array = []
			for i in tufts:
				var gx := bx + rng.randf_range(1.0, 14.0)
				var gh := rng.randf_range(3.0, 7.0)
				blades.append([gx, gh, rng.randf_range(-1.2, 1.2)])
			_grass.append({"x": bx, "y": by, "blades": blades})

		# щебень: тёмный и светлый вперемешку, без «снега»
		if rng.randf() < 0.30:
			var dark := rng.randf() < 0.55
			_rubble.append({
				"poly": _make_rubble(rng, bx, by),
				"color": Color(0.115, 0.125, 0.145, 0.95) if dark
					else Color(0.205, 0.215, 0.240, 0.95),
			})

	queue_redraw()

func _make_crack(rng: RandomNumberGenerator, bx: float, by: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var x := bx + rng.randf_range(2.0, 13.0)
	var y := by + rng.randf_range(2.0, 7.0)
	pts.append(Vector2(x, y))
	for i in rng.randi_range(2, 4):
		x += rng.randf_range(-3.5, 3.5)
		y += rng.randf_range(2.0, 5.0)
		pts.append(Vector2(x, y))
	return pts

func _make_rubble(rng: RandomNumberGenerator, bx: float, by: float) -> PackedVector2Array:
	var w := rng.randf_range(5.0, 14.0)
	var h := rng.randf_range(2.5, 6.0)
	var x := bx + rng.randf_range(1.0, maxf(1.0, 15.0 - w))
	return PackedVector2Array([
		Vector2(x, by),
		Vector2(x + w, by),
		Vector2(x + w * 0.72, by - h),
		Vector2(x + w * 0.28, by - h),
	])

func _draw() -> void:
	for r in _rubble:
		draw_colored_polygon(r["poly"], r["color"])

	for g in _grass:
		for b in g["blades"]:
			var x: float = b[0]
			var h: float = b[1]
			var lean: float = b[2]
			draw_line(
				Vector2(x, g["y"]),
				Vector2(x + lean, g["y"] - h),
				Color(0.200, 0.270, 0.170, 0.90),
				1.0
			)

	for c in _cracks:
		draw_polyline(c, Color(0.025, 0.030, 0.045, 0.95), 1.0)
	for m in _moss:
		draw_rect(m, Color(0.150, 0.210, 0.130, 0.55))