extends RoomPainter

## Чердак. Тёмное дерево, пыль, холодный луч из дыры в крыше.
## Самое «пыльное» и тихое помещение дома.

const W := 480.0
const H := 288.0
const WALL_L := 16.0
const WALL_R := 464.0
const CEIL_Y := 32.0
const FLOOR_Y := 256.0

const C_WOOD := Color(0.265, 0.212, 0.158)
const C_WOOD_HI := Color(0.320, 0.258, 0.196)
const C_WOOD_D := Color(0.140, 0.108, 0.082)
const C_ROOF := Color(0.170, 0.140, 0.112)
const C_ROOF_D := Color(0.090, 0.074, 0.060)
const C_COLD := Color(0.60, 0.70, 0.90)
const C_METAL := Color(0.240, 0.250, 0.260)

func _ready() -> void:
	super._ready()
	_rng.seed = 1918

func _draw_base() -> void:
	_roof()
	_walls()
	_floor()
	_rafters()
	_occlusion()

func _roof() -> void:
	_r(0.0, 0.0, W, CEIL_Y, C_ROOF)
	var x := 0.0
	while x < W:
		_r(x, 0.0, 1.0, CEIL_Y, Color(0, 0, 0, 0.22))
		x += 18.0
	_r(0.0, 30.0, W, 2.0, C_ROOF_D)
	_poly(PackedVector2Array([
		Vector2(284, 0), Vector2(318, 0), Vector2(322, 14),
		Vector2(310, 30), Vector2(292, 28), Vector2(282, 12),
	]), Color(0.020, 0.024, 0.030))
	_ln(284.0, 1.0, 292.0, 28.0, Color(0.60, 0.70, 0.90, 0.20))
	_ln(318.0, 1.0, 310.0, 30.0, Color(0.60, 0.70, 0.90, 0.14))
	_noise(90, 0.0, 0.0, W, CEIL_Y - 2.0, 0.02, 0.05)

func _walls() -> void:
	_r(WALL_L, CEIL_Y, WALL_R - WALL_L, FLOOR_Y - CEIL_Y, C_WOOD_D)
	var x := 18.0
	while x < WALL_R:
		var w := 14.0
		_r(x, CEIL_Y, w, FLOOR_Y - CEIL_Y, Color(0.145, 0.115, 0.090))
		_r(x, CEIL_Y, 1.0, FLOOR_Y - CEIL_Y, Color(0, 0, 0, 0.30))
		_r(x + 1.0, CEIL_Y, 1.0, FLOOR_Y - CEIL_Y, Color(0.34, 0.28, 0.21, 0.10))
		x += 16.0
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 40.0, Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 4)
	_noise(200, WALL_L + 2.0, CEIL_Y + 2.0, WALL_R - 2.0, FLOOR_Y - 2.0, 0.020, 0.045)

func _floor() -> void:
	_r(0.0, FLOOR_Y, W, H - FLOOR_Y, C_WOOD)
	var y := FLOOR_Y
	var i := 0
	while y < H:
		_r(0.0, y, W, 1.0, Color(0, 0, 0, 0.30))
		var jx := 40.0 + float((i * 61) % 380)
		_r(jx, y + 1.0, 1.0, 7.0, Color(0, 0, 0, 0.22))
		_r(0.0, y + 1.0, W, 1.0, Color(0.55, 0.45, 0.32, 0.06))
		y += 8.0
		i += 1
	_vg(0.0, FLOOR_Y, W, 8.0, Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 3)

func _rafters() -> void:
	for rx in [112.0, 304.0]:
		_r(rx, CEIL_Y, 16.0, FLOOR_Y - CEIL_Y, Color(0.135, 0.105, 0.080))
		_r(rx, CEIL_Y, 2.0, FLOOR_Y - CEIL_Y, Color(0.34, 0.28, 0.21, 0.30))
		_r(rx + 14.0, CEIL_Y, 2.0, FLOOR_Y - CEIL_Y, Color(0, 0, 0, 0.30))

func _occlusion() -> void:
	_hgrad(WALL_L, CEIL_Y, 12.0, FLOOR_Y - CEIL_Y, Color(0, 0, 0, 0.40), Color(0, 0, 0, 0.0), 4)
	_hgrad(WALL_R - 12.0, CEIL_Y, 12.0, FLOOR_Y - CEIL_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.40), 4)
	_vg(0.0, FLOOR_Y, W, 8.0, Color(0, 0, 0, 0.36), Color(0, 0, 0, 0.0), 3)
	_r(132.0, 250.0, 40.0, 6.0, Color(0, 0, 0, 0.32))
	_r(214.0, 250.0, 36.0, 6.0, Color(0, 0, 0, 0.30))
	_r(264.0, 250.0, 34.0, 6.0, Color(0, 0, 0, 0.32))
	_r(356.0, 250.0, 70.0, 6.0, Color(0, 0, 0, 0.30))
	_r(388.0, 250.0, 26.0, 6.0, Color(0, 0, 0, 0.30))

func _draw_overlay() -> void:
	_shaft()
	_boxes()
	_safe()
	_ladders()
	_trunk()
	_cobwebs()
	_dust()

func _shaft() -> void:
	_poly(PackedVector2Array([
		Vector2(288, 30), Vector2(316, 30), Vector2(352, FLOOR_Y), Vector2(250, FLOOR_Y),
	]), Color(0.62, 0.72, 0.92, 0.055))
	_poly(PackedVector2Array([
		Vector2(296, 30), Vector2(308, 30), Vector2(330, FLOOR_Y), Vector2(272, FLOOR_Y),
	]), Color(0.78, 0.85, 1.0, 0.040))
	for i in 26:
		var fi := float(i)
		var py := 36.0 + fmod(fi * 67.0, 216.0)
		var spread := 12.0 + (py - 30.0) * 0.30
		var px := 302.0 + sin(fi * 2.1) * spread + sin(_t * 0.21 + fi) * 3.0
		var a := 0.08 + 0.08 * (0.5 + 0.5 * sin(_t * 0.7 + fi))
		_dust_mote(px, py, a)

func _boxes() -> void:
	_ol(140.0, 234.0, 20.0, 22.0, Color(0, 0, 0, 0.35))
	_r(141.0, 235.0, 18.0, 1.0, Color(0.46, 0.38, 0.28, 0.45))
	_ol(222.0, 242.0, 16.0, 14.0, Color(0, 0, 0, 0.35))
	_r(223.0, 243.0, 14.0, 1.0, Color(0.46, 0.38, 0.28, 0.40))

func _safe() -> void:
	_r(267.0, 222.0, 26.0, 1.0, Color(0.40, 0.42, 0.45, 0.40))
	_r(292.0, 223.0, 1.0, 33.0, Color(0, 0, 0, 0.28))
	_r(270.0, 254.0, 1.0, 2.0, Color(0.35, 0.22, 0.15, 0.25))

func _ladders() -> void:
	_r(31.0, 253.0, 18.0, 2.0, Color(0.34, 0.28, 0.21, 0.45))
	_r(31.0, 213.0, 2.0, 44.0, Color(0.34, 0.28, 0.21, 0.55))
	_r(47.0, 213.0, 2.0, 44.0, Color(0.34, 0.28, 0.21, 0.55))
	_r(388.0, 253.0, 24.0, 2.0, Color(0.30, 0.25, 0.19, 0.40))

func _trunk() -> void:
	_r(372.0, 236.0, 44.0, 20.0, Color(0.195, 0.150, 0.108))
	_r(372.0, 236.0, 44.0, 2.0, Color(0.42, 0.34, 0.25, 0.45))
	_r(392.0, 236.0, 2.0, 20.0, Color(0.11, 0.085, 0.062, 0.55))
	_r(374.0, 242.0, 6.0, 3.0, Color(0.46, 0.40, 0.27, 0.45))

func _cobwebs() -> void:
	_ln(17.0, 33.0, 42.0, 33.0, Color(0.72, 0.75, 0.78, 0.06))
	_ln(17.0, 33.0, 17.0, 60.0, Color(0.72, 0.75, 0.78, 0.06))
	_ln(463.0, 33.0, 438.0, 33.0, Color(0.72, 0.75, 0.78, 0.05))
	_ln(463.0, 33.0, 463.0, 58.0, Color(0.72, 0.75, 0.78, 0.05))

func _dust() -> void:
	for i in 18:
		var fi := float(i)
		var px := 30.0 + fmod(fi * 59.0, 420.0) + sin(_t * 0.15 + fi) * 5.0
		var py := 50.0 + fmod(fi * 43.0, 200.0) + sin(_t * 0.25 + fi * 1.2) * 4.0
		var a := 0.03 + 0.04 * (0.5 + 0.5 * sin(_t * 0.5 + fi))
		_dust_mote(px, py, a)