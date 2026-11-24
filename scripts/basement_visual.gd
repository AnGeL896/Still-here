extends RoomPainter

## Подвал. Сырой бетон, трубопровод, лужи, одна мерцающая лампа.
## Холодный и тесный, но с тёплым пятном света в центре.

const W := 480.0
const H := 272.0
const WALL_L := 16.0
const WALL_R := 464.0
const CEIL_Y := 32.0
const BASE_Y := 208.0
const FLOOR_Y := 224.0
const BOTTOM := 256.0

const C_CONCRETE := Color(0.128, 0.142, 0.142)
const C_CONCRETE_HI := Color(0.162, 0.176, 0.174)
const C_CONCRETE_LO := Color(0.070, 0.080, 0.082)
const C_WET := Color(0.052, 0.066, 0.066)
const C_RUST := Color(0.330, 0.190, 0.110)
const C_PIPE := Color(0.175, 0.165, 0.148)
const C_PIPE_D := Color(0.095, 0.090, 0.082)
const C_BULB := Color(1.0, 0.78, 0.48)

func _ready() -> void:
	super._ready()
	_rng.seed = 2024

func _draw_base() -> void:
	_wall()
	_floor()
	_ceiling()
	_columns()
	_baseboard()
	_occlusion()

func _wall() -> void:
	_r(WALL_L, CEIL_Y, WALL_R - WALL_L, BASE_Y - CEIL_Y, C_CONCRETE)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 46.0, C_CONCRETE_LO, C_CONCRETE, 5)
	_vg(WALL_L, BASE_Y - 48.0, WALL_R - WALL_L, 48.0, C_CONCRETE, C_CONCRETE_LO, 5)

	var y := 58.0
	while y < BASE_Y:
		_r(WALL_L, y, WALL_R - WALL_L, 1.0, Color(0, 0, 0, 0.16))
		_r(WALL_L, y + 1.0, WALL_R - WALL_L, 1.0, Color(1, 1, 1, 0.025))
		y += 26.0
	var x := 44.0
	var row := 0
	while x < WALL_R:
		var off := 0.0 if row % 2 == 0 else 26.0
		_r(x + off, CEIL_Y, 1.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.10))
		x += 52.0
		row += 1

	_poly(PackedVector2Array([
		Vector2(60, 34), Vector2(112, 33), Vector2(120, 62),
		Vector2(96, 82), Vector2(68, 66),
	]), Color(0.040, 0.058, 0.054, 0.30))
	_poly(PackedVector2Array([
		Vector2(330, 150), Vector2(392, 148), Vector2(398, 190),
		Vector2(356, 202), Vector2(334, 180),
	]), Color(0.038, 0.055, 0.052, 0.34))
	_poly(PackedVector2Array([
		Vector2(180, 96), Vector2(228, 94), Vector2(232, 126),
		Vector2(198, 134), Vector2(182, 116),
	]), Color(0.045, 0.060, 0.056, 0.22))

	for n in 12:
		var sx := _rng.randf_range(WALL_L + 4.0, WALL_R - 6.0)
		var sy := _rng.randf_range(CEIL_Y + 4.0, BASE_Y - 8.0)
		_r(sx, sy, _rng.randf_range(2.0, 7.0), 1.0, Color(0.55, 0.56, 0.52, 0.10))

	_crack(PackedVector2Array([
		Vector2(250, 33), Vector2(256, 56), Vector2(250, 74), Vector2(258, 96),
	]))
	_crack(PackedVector2Array([
		Vector2(430, 33), Vector2(424, 52), Vector2(432, 68),
	]))
	_crack(PackedVector2Array([
		Vector2(463, 96), Vector2(446, 102), Vector2(434, 98),
	]))

	_noise(300, WALL_L + 2.0, CEIL_Y + 2.0, WALL_R - 2.0, BASE_Y - 2.0, 0.018, 0.055)

func _floor() -> void:
	_r(0.0, FLOOR_Y, W, H - FLOOR_Y, Color(0.255, 0.262, 0.258))
	_vg(0.0, FLOOR_Y, W, 10.0, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.0), 3)
	_crack(PackedVector2Array([
		Vector2(90, 230), Vector2(104, 242), Vector2(96, 256), Vector2(110, 268),
	]), 0.35)
	_crack(PackedVector2Array([
		Vector2(300, 228), Vector2(316, 240), Vector2(308, 252),
	]), 0.30)
	_poly(PackedVector2Array([
		Vector2(196, 250), Vector2(248, 248), Vector2(262, 262),
		Vector2(214, 266), Vector2(192, 258),
	]), C_WET)
	_poly(PackedVector2Array([
		Vector2(330, 258), Vector2(372, 256), Vector2(380, 268), Vector2(338, 270),
	]), Color(0.045, 0.058, 0.058, 0.85))
	for n in 22:
		var dx := _rng.randf_range(6.0, W - 8.0)
		var dy := _rng.randf_range(FLOOR_Y + 2.0, H - 2.0)
		_r(dx, dy, _rng.randf_range(1.0, 4.0), 1.0, Color(0.42, 0.40, 0.34, 0.14))

func _ceiling() -> void:
	_r(0.0, 0.0, W, CEIL_Y, Color(0.100, 0.108, 0.110))
	_vg(0.0, 0.0, W, 12.0, Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 4)
	_noise(100, 0.0, 0.0, W, CEIL_Y - 1.0, 0.015, 0.05)
	_pipe_h(18.0, 0.0, W, 5.0)
	_pipe_h(27.0, 0.0, W, 3.0)
	for bx in [80.0, 200.0, 320.0, 430.0]:
		_r(bx, 16.0, 2.0, 14.0, C_PIPE_D)
		_r(bx, 16.0, 1.0, 14.0, Color(0.42, 0.40, 0.35, 0.35))
	_poly(PackedVector2Array([
		Vector2(120, 2), Vector2(160, 1), Vector2(170, 10), Vector2(150, 16), Vector2(126, 12),
	]), Color(0.040, 0.050, 0.050, 0.45))

func _pipe_h(y: float, x0: float, x1: float, h: float) -> void:
	_r(x0, y, x1 - x0, h, C_PIPE)
	_r(x0, y, x1 - x0, 1.0, Color(0.48, 0.45, 0.38, 0.45))
	_r(x0, y + h - 1.0, x1 - x0, 1.0, Color(0, 0, 0, 0.35))

func _columns() -> void:
	for cx in [144.0, 320.0]:
		_r(cx, CEIL_Y, 16.0, FLOOR_Y - CEIL_Y, Color(0.088, 0.096, 0.098))
		_r(cx, CEIL_Y, 1.0, FLOOR_Y - CEIL_Y, Color(0.26, 0.28, 0.28, 0.30))
		_r(cx + 15.0, CEIL_Y, 1.0, FLOOR_Y - CEIL_Y, Color(0, 0, 0, 0.35))

func _baseboard() -> void:
	# бетонный цоколь 208..224: непрерывный, по нему стоят записки
	_r(0.0, BASE_Y, W, FLOOR_Y - BASE_Y, Color(0.210, 0.218, 0.214))
	_r(0.0, BASE_Y, W, 1.0, Color(0.34, 0.35, 0.34, 0.55))
	_r(0.0, FLOOR_Y - 1.0, W, 1.0, Color(0, 0, 0, 0.30))
	var x := 24.0
	while x < W:
		_r(x, BASE_Y + 1.0, 1.0, FLOOR_Y - BASE_Y - 2.0, Color(0, 0, 0, 0.16))
		x += 56.0
	_vg(0.0, BASE_Y, W, 8.0, Color(0.030, 0.045, 0.042, 0.30), Color(0, 0, 0, 0.0), 3)

func _occlusion() -> void:
	_hgrad(WALL_L, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.36), Color(0, 0, 0, 0.0), 4)
	_hgrad(WALL_R - 10.0, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.36), 4)
	_vg(0.0, FLOOR_Y, W, 8.0, Color(0, 0, 0, 0.34), Color(0, 0, 0, 0.0), 3)
	# контактные тени сейфа и выхода (они стоят на полу 224)
	_r(384.0, 222.0, 40.0, 6.0, Color(0, 0, 0, 0.32))
	_r(24.0, 222.0, 34.0, 6.0, Color(0, 0, 0, 0.32))

func _draw_overlay() -> void:
	_bulb_glow()
	_pipes()
	_puddles()
	_debris()
	_exit()
	_note_papers()
	_cobwebs()
	_dust()

func _note_papers() -> void:
	# записки сейчас не имеют собственного спрайта — рисуем лист, чтобы видеть цель
	_paper(150.0, 208.0)
	_paper(300.0, 210.0)

func _paper(x: float, y: float) -> void:
	var top := y - 10.0
	_r(x - 5.0, top, 10.0, 11.0, Color(0.60, 0.58, 0.51, 0.95))
	_r(x - 5.0, top, 10.0, 1.0, Color(0.76, 0.74, 0.66, 0.55))
	_r(x + 3.0, top + 1.0, 1.0, 9.0, Color(0, 0, 0, 0.18))
	_r(x - 4.0, top + 4.0, 6.0, 1.0, Color(0.25, 0.24, 0.21, 0.35))
	_r(x - 4.0, top + 7.0, 5.0, 1.0, Color(0.25, 0.24, 0.21, 0.28))
	_r(x - 5.0, y - 1.0, 10.0, 2.0, Color(0, 0, 0, 0.30))
	_r(x - 1.0, top - 1.0, 2.0, 1.0, Color(0.62, 0.58, 0.46, 0.85))

func _bulb_glow() -> void:
	draw_circle(Vector2(240, 70), 9.0, Color(1.0, 0.80, 0.52, 0.06))
	draw_circle(Vector2(240, 70), 18.0, Color(1.0, 0.78, 0.48, 0.03))
	_poly(PackedVector2Array([
		Vector2(206, 224), Vector2(274, 224), Vector2(292, 268), Vector2(188, 268),
	]), Color(1.0, 0.78, 0.48, 0.035))

func _pipes() -> void:
	_r(86.0, 32.0, 5.0, FLOOR_Y - 32.0, C_PIPE)
	_r(86.0, 32.0, 1.0, FLOOR_Y - 32.0, Color(0.48, 0.45, 0.38, 0.40))
	_r(84.0, 60.0, 9.0, 3.0, C_PIPE_D)
	_r(84.0, 140.0, 9.0, 3.0, C_PIPE_D)
	draw_circle(Vector2(88.5, 120.0), 4.0, Color(0.30, 0.12, 0.10))
	draw_circle(Vector2(88.5, 120.0), 2.0, Color(0.48, 0.20, 0.16))

func _puddles() -> void:
	_r(224.0, 252.0, 2.0, 8.0, Color(1.0, 0.82, 0.55, 0.10))
	_r(232.0, 254.0, 1.0, 5.0, Color(1.0, 0.82, 0.55, 0.07))
	_ln(198.0, 251.0, 250.0, 249.0, Color(0.55, 0.60, 0.58, 0.10))

func _debris() -> void:
	_poly(PackedVector2Array([
		Vector2(252, 244), Vector2(266, 244), Vector2(263, 258), Vector2(255, 258),
	]), Color(0.240, 0.250, 0.255, 0.90))
	_r(252.0, 244.0, 14.0, 1.0, Color(0.42, 0.44, 0.45, 0.55))
	_poly(PackedVector2Array([
		Vector2(340, 262), Vector2(354, 260), Vector2(358, 266), Vector2(344, 268),
	]), Color(0.300, 0.280, 0.240, 0.75))
	_r(276.0, 260.0, 2.0, 5.0, Color(0.20, 0.30, 0.22, 0.75))
	_r(280.0, 262.0, 2.0, 4.0, Color(0.24, 0.28, 0.20, 0.65))

func _exit() -> void:
	_r(31.0, 192.0, 18.0, 32.0, Color(0.095, 0.100, 0.105))
	_r(33.0, 195.0, 14.0, 27.0, Color(0.150, 0.155, 0.160))
	_r(33.0, 195.0, 14.0, 1.0, Color(0.35, 0.37, 0.38, 0.35))
	_r(26.0, 216.0, 28.0, 3.0, Color(0.20, 0.21, 0.21))
	_r(26.0, 219.0, 28.0, 2.0, Color(0.12, 0.13, 0.13))
	_poly(PackedVector2Array([
		Vector2(26, 194), Vector2(54, 194), Vector2(62, 236), Vector2(18, 236),
	]), Color(0.55, 0.66, 0.86, 0.05))

func _cobwebs() -> void:
	_ln(17.0, 33.0, 38.0, 33.0, Color(0.70, 0.74, 0.76, 0.05))
	_ln(17.0, 33.0, 17.0, 54.0, Color(0.70, 0.74, 0.76, 0.05))
	_ln(463.0, 33.0, 440.0, 33.0, Color(0.70, 0.74, 0.76, 0.04))

func _dust() -> void:
	for i in 16:
		var fi := float(i)
		var px := 200.0 + fmod(fi * 47.0, 80.0) + sin(_t * 0.17 + fi) * 4.0
		var py := 80.0 + fmod(fi * 59.0, 150.0) + sin(_t * 0.27 + fi * 1.4) * 3.0
		var a := 0.04 + 0.05 * (0.5 + 0.5 * sin(_t * 0.55 + fi))
		_dust_mote(px, py, a)