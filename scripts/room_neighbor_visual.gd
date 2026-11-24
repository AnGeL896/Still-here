extends RoomPainter

## Квартира 13. Заброшенная, окно заколочено, свет только холодный,
## из щелей между досками. Холоднее и мертвее, чем кв. 4.

const W := 480.0
const H := 272.0
const WALL_L := 16.0
const WALL_R := 464.0
const CEIL_Y := 32.0
const BASE_Y := 208.0
const FLOOR_Y := 224.0

const C_WALL := Color(0.122, 0.134, 0.138)
const C_WALL_HI := Color(0.152, 0.164, 0.166)
const C_WALL_LO := Color(0.076, 0.084, 0.088)
const C_FLOOR := Color(0.270, 0.228, 0.180)
const C_WOOD_D := Color(0.120, 0.096, 0.074)
const C_BOARD := Color(0.305, 0.245, 0.175)
const C_BOARD_D := Color(0.205, 0.160, 0.112)
const C_COLD := Color(0.55, 0.66, 0.88)

func _ready() -> void:
	super._ready()
	_rng.seed = 1313

func _draw_base() -> void:
	_wall()
	_floor()
	_ceiling()
	_baseboard()
	_occlusion()

func _wall() -> void:
	_r(WALL_L, CEIL_Y, WALL_R - WALL_L, BASE_Y - CEIL_Y, C_WALL)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 42.0, C_WALL_LO, C_WALL, 5)
	_vg(WALL_L, BASE_Y - 54.0, WALL_R - WALL_L, 54.0, C_WALL, C_WALL_LO, 5)

	var x := 19.0
	var i := 0
	while x < WALL_R - 2.0:
		_r(x, CEIL_Y, 1.0, BASE_Y - CEIL_Y, Color(1, 1, 1, 0.022) if i % 2 == 0 else Color(0, 0, 0, 0.05))
		x += 9.0
		i += 1

	_poly(PackedVector2Array([
		Vector2(180, 60), Vector2(214, 56), Vector2(222, 86),
		Vector2(208, 104), Vector2(186, 96), Vector2(176, 76),
	]), Color(0.175, 0.180, 0.176, 0.55))
	_poly(PackedVector2Array([
		Vector2(330, 120), Vector2(356, 118), Vector2(360, 148),
		Vector2(340, 158), Vector2(326, 142),
	]), Color(0.168, 0.172, 0.168, 0.45))
	_ln(180, 60, 208, 104, Color(0, 0, 0, 0.20))
	_ln(330, 120, 340, 158, Color(0, 0, 0, 0.18))

	_poly(PackedVector2Array([
		Vector2(96, 34), Vector2(132, 33), Vector2(140, 54),
		Vector2(124, 72), Vector2(104, 64), Vector2(94, 48),
	]), Color(0.055, 0.065, 0.062, 0.22))
	_poly(PackedVector2Array([
		Vector2(392, 34), Vector2(438, 35), Vector2(442, 66),
		Vector2(414, 78), Vector2(396, 60),
	]), Color(0.050, 0.060, 0.058, 0.25))
	_poly(PackedVector2Array([
		Vector2(236, 150), Vector2(292, 148), Vector2(296, 178),
		Vector2(258, 186), Vector2(238, 170),
	]), Color(0.060, 0.068, 0.066, 0.16))

	_crack(PackedVector2Array([
		Vector2(70, 33), Vector2(76, 56), Vector2(70, 74), Vector2(78, 96),
	]))
	_crack(PackedVector2Array([
		Vector2(300, 33), Vector2(294, 52), Vector2(302, 68),
	]))
	_crack(PackedVector2Array([
		Vector2(463, 120), Vector2(444, 126), Vector2(430, 122),
	]))

	_noise(240, WALL_L + 2.0, CEIL_Y + 2.0, WALL_R - 2.0, BASE_Y - 2.0, 0.018, 0.05)

func _floor() -> void:
	var y := FLOOR_Y
	var i := 0
	while y < H:
		var h := 7.0 if i % 2 == 0 else 6.0
		var warm := 0.015 + 0.015 * float((i * 41) % 5) / 4.0
		_r(0.0, y, W, h, Color(0.90, 0.78, 0.58, warm))
		_r(0.0, y, W, 1.0, Color(0, 0, 0, 0.28))
		var jx := 32.0 + float((i * 73) % 340)
		_r(jx, y + 1.0, 1.0, h - 1.0, Color(0, 0, 0, 0.22))
		y += h
		i += 1
	for n in 16:
		var dx := _rng.randf_range(10.0, W - 10.0)
		var dy := _rng.randf_range(FLOOR_Y + 2.0, H - 2.0)
		_r(dx, dy, _rng.randf_range(1.0, 4.0), 1.0, Color(0.55, 0.52, 0.45, 0.10))
	_vg(0.0, FLOOR_Y, W, 6.0, Color(0, 0, 0, 0.32), Color(0, 0, 0, 0.0), 3)

func _ceiling() -> void:
	_noise(90, 0.0, 0.0, W, CEIL_Y - 1.0, 0.015, 0.05)
	_poly(PackedVector2Array([
		Vector2(140, 2), Vector2(178, 1), Vector2(188, 12),
		Vector2(168, 20), Vector2(146, 14),
	]), Color(0.050, 0.056, 0.056, 0.40))
	_crack(PackedVector2Array([
		Vector2(240, 1), Vector2(246, 14), Vector2(242, 24),
	]))

func _baseboard() -> void:
	_r(0.0, BASE_Y, W, 1.0, Color(1, 1, 1, 0.05))
	_r(0.0, BASE_Y + 15.0, W, 1.0, Color(0, 0, 0, 0.32))
	var x := 16.0
	while x < W:
		_r(x, BASE_Y + 1.0, 1.0, 14.0, Color(0, 0, 0, 0.14))
		x += 34.0

func _occlusion() -> void:
	_hgrad(WALL_L, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 4)
	_hgrad(WALL_R - 10.0, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.34), 4)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 9.0, Color(0, 0, 0, 0.36), Color(0, 0, 0, 0.0), 3)
	_vg(0.0, FLOOR_Y, W, 7.0, Color(0, 0, 0, 0.32), Color(0, 0, 0, 0.0), 3)
	_r(122.0, 205.0, 36.0, 5.0, Color(0, 0, 0, 0.30))
	_r(286.0, 205.0, 52.0, 5.0, Color(0, 0, 0, 0.30))
	_r(24.0, 205.0, 34.0, 5.0, Color(0, 0, 0, 0.30))
	_poly(PackedVector2Array([
		Vector2(236, 224), Vector2(292, 224), Vector2(322, 268), Vector2(262, 268),
	]), Color(0.55, 0.66, 0.88, 0.045))

func _draw_overlay() -> void:
	_window()
	_table()
	_cupboard()
	_exit()
	_calendar()
	_fallen_frame()
	_cobwebs()
	_dust()

func _window() -> void:
	_r(238.0, 119.0, 58.0, 2.0, Color(0.175, 0.170, 0.160))
	_r(238.0, 119.0, 58.0, 1.0, Color(0.330, 0.320, 0.290, 0.45))
	_r(238.0, 121.0, 58.0, 2.0, Color(0, 0, 0, 0.32))
	_r(243.0, 78.0, 48.0, 1.0, Color(0.60, 0.70, 0.90, 0.20))
	_r(243.0, 94.0, 48.0, 1.0, Color(0.60, 0.70, 0.90, 0.14))
	_r(243.0, 102.0, 48.0, 1.0, Color(0.60, 0.70, 0.90, 0.10))
	_r(240.0, 70.0, 54.0, 5.0, C_BOARD)
	_r(240.0, 70.0, 54.0, 1.0, Color(0.52, 0.44, 0.32, 0.45))
	_r(240.0, 108.0, 54.0, 5.0, C_BOARD_D)
	_ln(242.0, 72.0, 292.0, 74.0, Color(0, 0, 0, 0.25))
	_r(246.0, 72.0, 1.0, 1.0, Color(0.05, 0.05, 0.05, 0.7))
	_r(286.0, 72.0, 1.0, 1.0, Color(0.05, 0.05, 0.05, 0.7))

func _table() -> void:
	_ol(288.0, 192.0, 44.0, 4.0, Color(0, 0, 0, 0.50))
	_r(289.0, 192.0, 42.0, 1.0, Color(0.46, 0.38, 0.28, 0.45))
	_r(288.0, 196.0, 44.0, 1.0, Color(0, 0, 0, 0.38))
	_ol(292.0, 196.0, 4.0, 12.0, Color(0, 0, 0, 0.40))
	_ol(324.0, 196.0, 4.0, 12.0, Color(0, 0, 0, 0.40))
	_r(304.0, 190.0, 4.0, 1.0, Color(0.62, 0.58, 0.44, 0.85))
	_r(304.0, 189.0, 1.0, 1.0, Color(0.62, 0.58, 0.44, 0.85))

func _cupboard() -> void:
	_r(123.0, 174.0, 34.0, 1.0, Color(0.34, 0.28, 0.22, 0.40))
	_r(157.0, 175.0, 1.0, 33.0, Color(0, 0, 0, 0.30))
	_ol(127.0, 178.0, 12.0, 26.0, Color(0, 0, 0, 0.18))

func _exit() -> void:
	_r(21.0, 176.0, 1.0, 32.0, Color(0.30, 0.25, 0.20, 0.35))
	_ol(24.0, 182.0, 12.0, 10.0, Color(0, 0, 0, 0.32))
	_ol(24.0, 196.0, 12.0, 10.0, Color(0, 0, 0, 0.32))
	_r(34.0, 193.0, 2.0, 1.0, Color(0.58, 0.54, 0.45, 0.60))

func _calendar() -> void:
	_r(214.0, 88.0, 14.0, 18.0, Color(0.62, 0.60, 0.54, 0.55))
	_r(214.0, 88.0, 14.0, 3.0, Color(0.45, 0.20, 0.18, 0.65))
	for row in 3:
		for col in 3:
			_r(216.0 + col * 4.0, 93.0 + row * 4.0, 2.0, 1.0, Color(0.20, 0.20, 0.19, 0.45))

func _fallen_frame() -> void:
	_poly(PackedVector2Array([
		Vector2(196, 200), Vector2(212, 197), Vector2(216, 207), Vector2(200, 210),
	]), Color(0.240, 0.200, 0.155, 0.85))
	_ln(198.0, 202.0, 212.0, 199.0, Color(0.45, 0.42, 0.35, 0.35))

func _cobwebs() -> void:
	_ln(17.0, 33.0, 35.0, 33.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(17.0, 33.0, 17.0, 52.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(463.0, 33.0, 443.0, 33.0, Color(0.75, 0.78, 0.80, 0.04))

func _dust() -> void:
	for i in 20:
		var fi := float(i)
		var px := 236.0 + fmod(fi * 43.0, 70.0) + sin(_t * 0.19 + fi) * 3.0
		var py := 80.0 + fmod(fi * 67.0, 140.0) + sin(_t * 0.29 + fi * 1.1) * 3.0
		var a := 0.05 + 0.05 * (0.5 + 0.5 * sin(_t * 0.6 + fi))
		_dust_mote(px, py, a)