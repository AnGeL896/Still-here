extends RoomPainter

## Подъезд. Холодная штукатурка, плитка, слабая лампа,
## граффити и следы жильцов. Ничего не двигает и не блокирует.

const W := 480.0
const H := 272.0
const WALL_L := 16.0
const WALL_R := 464.0
const CEIL_Y := 32.0
const BASE_Y := 192.0
const FLOOR_Y := 208.0

const C_PLASTER := Color(0.150, 0.160, 0.162)
const C_PLASTER_HI := Color(0.188, 0.198, 0.196)
const C_PLASTER_LO := Color(0.098, 0.108, 0.112)
const C_DADO := Color(0.092, 0.122, 0.116)
const C_DADO_HI := Color(0.128, 0.158, 0.148)
const C_TILE := Color(0.285, 0.285, 0.272)
const C_TILE_D := Color(0.220, 0.222, 0.214)
const C_GROUT := Color(0.105, 0.107, 0.104)
const C_CEIL := Color(0.118, 0.124, 0.128)
const C_DOOR := Color(0.185, 0.150, 0.118)
const C_DOOR_D := Color(0.120, 0.096, 0.074)
const C_METAL := Color(0.300, 0.320, 0.340)
const C_RUST := Color(0.340, 0.205, 0.125)
const C_WARM := Color(1.0, 0.78, 0.50)
const C_COLD := Color(0.58, 0.68, 0.88)

func _ready() -> void:
	super._ready()
	_rng.seed = 4101

# ─── подложка ─────────────────────────────────────────────────

func _draw_base() -> void:
	_wall()
	_ceiling()
	_floor()
	_baseboard()
	_occlusion()

func _wall() -> void:
	_r(WALL_L, CEIL_Y, WALL_R - WALL_L, BASE_Y - CEIL_Y, C_PLASTER)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 40.0, C_PLASTER_LO, C_PLASTER, 5)
	_vg(WALL_L, BASE_Y - 52.0, WALL_R - WALL_L, 52.0, C_PLASTER, C_PLASTER_LO, 5)

	# панель ниже
	_r(WALL_L, 150.0, WALL_R - WALL_L, BASE_Y - 150.0, C_DADO)
	_r(WALL_L, 150.0, WALL_R - WALL_L, 1.0, C_DADO_HI)
	_r(WALL_L, 151.0, WALL_R - WALL_L, 1.0, Color(0, 0, 0, 0.28))
	_r(WALL_L, 152.0, WALL_R - WALL_L, BASE_Y - 152.0, Color(0, 0, 0, 0.10))

	# открытая кладка
	_brick_patch(24.0, 178.0, 52.0, 28.0)
	_brick_patch(330.0, 186.0, 40.0, 20.0)
	_brick_patch(438.0, 60.0, 24.0, 46.0)

	# пятна и потёки
	_poly(PackedVector2Array([
		Vector2(168, 34), Vector2(206, 33), Vector2(212, 48),
		Vector2(198, 60), Vector2(176, 56), Vector2(164, 46),
	]), Color(0.09, 0.09, 0.085, 0.15))
	_poly(PackedVector2Array([
		Vector2(360, 34), Vector2(404, 35), Vector2(400, 54),
		Vector2(378, 58), Vector2(362, 48),
	]), Color(0.08, 0.085, 0.082, 0.13))

	# трещины
	_crack(PackedVector2Array([
		Vector2(96, 33), Vector2(101, 54), Vector2(96, 72), Vector2(102, 92),
	]))
	_crack(PackedVector2Array([
		Vector2(300, 33), Vector2(295, 50), Vector2(301, 64),
	]))
	_crack(PackedVector2Array([
		Vector2(463, 150), Vector2(446, 156), Vector2(432, 152),
	]))

	_noise(260, WALL_L + 2.0, CEIL_Y + 2.0, WALL_R - 2.0, BASE_Y - 2.0, 0.020, 0.045)

func _brick_patch(x: float, y: float, w: float, h: float) -> void:
	_r(x, y, w, h, Color(0.180, 0.115, 0.098, 0.55))
	var row := 0.0
	while row < h:
		_r(x, y + row, w, 1.0, Color(0.09, 0.06, 0.05, 0.35))
		var off := 6.0 if int(row / 6.0) % 2 == 0 else 0.0
		var bx := x + off
		while bx < x + w:
			_r(bx, y + row, 1.0, 6.0, Color(0.09, 0.06, 0.05, 0.30))
			bx += 12.0
		row += 6.0
	_r(x, y, w, 1.0, Color(0, 0, 0, 0.25))

func _ceiling() -> void:
	_r(0.0, 0.0, W, CEIL_Y, C_CEIL)
	_vg(0.0, 0.0, W, 10.0, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.0), 4)
	_noise(110, 0.0, 0.0, W, CEIL_Y - 1.0, 0.018, 0.05)
	_poly(PackedVector2Array([
		Vector2(60, 2), Vector2(96, 1), Vector2(104, 10), Vector2(86, 16), Vector2(66, 12),
	]), Color(0.055, 0.058, 0.058, 0.35))
	_crack(PackedVector2Array([
		Vector2(210, 1), Vector2(216, 10), Vector2(212, 18),
	]))

func _floor() -> void:
	_r(0.0, FLOOR_Y, W, H - FLOOR_Y, C_TILE)
	var y := FLOOR_Y
	while y < H:
		var off := 0.0 if int((y - FLOOR_Y) / 16.0) % 2 == 0 else 8.0
		var x := -off
		while x < W:
			var n := float((int(x) * 31 + int(y) * 17) % 7)
			var tint := 0.018 + n * 0.006
			_r(x + 1.0, y + 1.0, 14.0, 14.0, Color(1, 1, 1, tint) if n < 3.5 else Color(0, 0, 0, tint))
			x += 16.0
		_r(0.0, y, W, 1.0, C_GROUT)
		y += 16.0
	var gx := 0.0
	while gx < W:
		_r(gx, FLOOR_Y, 1.0, H - FLOOR_Y, Color(0, 0, 0, 0.18))
		gx += 16.0

	# грязь у стен
	_vg(0.0, FLOOR_Y, 26.0, H - FLOOR_Y, Color(0, 0, 0, 0.22), Color(0, 0, 0, 0.0), 3)
	_hgrad(W - 26.0, FLOOR_Y, 26.0, H - FLOOR_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.22), 3)
	# треснувшая плитка
	_crack(PackedVector2Array([
		Vector2(150, 214), Vector2(158, 224), Vector2(152, 234), Vector2(160, 244),
	]), 0.40)

func _baseboard() -> void:
	# цоколь 192..208: физический пол здесь, по нему стоят игрок и двери
	_r(0.0, BASE_Y, W, FLOOR_Y - BASE_Y, Color(0.300, 0.255, 0.205))
	_r(0.0, BASE_Y, W, 1.0, Color(0.46, 0.39, 0.30, 0.60))
	_r(0.0, FLOOR_Y - 1.0, W, 1.0, Color(0, 0, 0, 0.30))
	var x := 16.0
	while x < W:
		_r(x, BASE_Y + 1.0, 1.0, FLOOR_Y - BASE_Y - 2.0, Color(0, 0, 0, 0.14))
		x += 34.0

func _occlusion() -> void:
	_hgrad(WALL_L, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.30), Color(0, 0, 0, 0.0), 4)
	_hgrad(WALL_R - 10.0, CEIL_Y, 10.0, BASE_Y - CEIL_Y, Color(0, 0, 0, 0.0), Color(0, 0, 0, 0.30), 4)
	_vg(WALL_L, CEIL_Y, WALL_R - WALL_L, 8.0, Color(0, 0, 0, 0.32), Color(0, 0, 0, 0.0), 3)
	_vg(0.0, FLOOR_Y, W, 8.0, Color(0, 0, 0, 0.28), Color(0, 0, 0, 0.0), 3)

	# тени под порогами и ящиками
	_r(26.0, 192.0, 30.0, 4.0, Color(0, 0, 0, 0.30))
	_r(106.0, 192.0, 30.0, 4.0, Color(0, 0, 0, 0.30))
	_r(186.0, 192.0, 30.0, 4.0, Color(0, 0, 0, 0.30))
	_r(400.0, 192.0, 40.0, 3.0, Color(0, 0, 0, 0.22))

# ─── поверх ───────────────────────────────────────────────────

func _draw_overlay() -> void:
	_doors()
	_mailboxes()
	_graffiti()
	_lamp_glow()
	_door_light()
	_cobwebs()
	_dust()

func _doors() -> void:
	var xs := [40.0, 120.0, 200.0]
	for i in xs.size():
		var x: float = xs[i]
		# полотно
		_ol(x - 6.0, 163.0, 12.0, 29.0, Color(0, 0, 0, 0.35))
		_r(x - 5.0, 164.0, 10.0, 1.0, Color(0.55, 0.48, 0.38, 0.22))
		_ol(x - 4.0, 170.0, 8.0, 8.0, Color(0, 0, 0, 0.22))
		_ol(x - 4.0, 182.0, 8.0, 7.0, Color(0, 0, 0, 0.22))
		# номер
		if i == 1:
			_num(x, 168.0, "4", C_PLASTER_HI)
		elif i == 2:
			_num(x, 168.0, "13", C_PLASTER_HI)
		# ручка
		_r(x + 3.0, 186.0, 2.0, 1.0, Color(0.62, 0.57, 0.45, 0.75))
		# зазор под дверью
		var warm := i == 1
		_r(x - 6.0, 191.0, 12.0, 1.0, Color(C_WARM if warm else C_COLD, 0.30))

func _num(x: float, y: float, s: String, c: Color) -> void:
	# простая сегментная цифра, без шрифта
	if s == "4":
		_r(x - 2.0, y, 1.0, 4.0, c)
		_r(x - 1.0, y + 2.0, 3.0, 1.0, c)
		_r(x + 1.0, y, 1.0, 4.0, c)
	else:
		_r(x - 3.0, y, 1.0, 4.0, c)
		_r(x - 2.0, y, 2.0, 1.0, c)
		_r(x - 2.0, y + 3.0, 2.0, 1.0, c)
		_r(x + 1.0, y, 1.0, 4.0, c)
		_r(x + 1.0, y, 2.0, 1.0, c)
		_r(x + 1.0, y + 3.0, 2.0, 1.0, c)

func _mailboxes() -> void:
	var x0 := 404.0
	var y0 := 160.0
	_r(x0, y0, 32.0, 32.0, Color(0.10, 0.12, 0.15))
	_r(x0, y0, 32.0, 1.0, Color(0.35, 0.38, 0.42, 0.40))
	for row in 3:
		for col in 2:
			var bx := x0 + 2.0 + col * 15.0
			var by := y0 + 2.0 + row * 10.0
			_r(bx, by, 13.0, 8.0, Color(0.155, 0.175, 0.205))
			_r(bx, by, 13.0, 1.0, Color(0.32, 0.35, 0.39, 0.30))
			if (row + col) % 3 == 0:
				_r(bx + 5.0, by + 3.0, 3.0, 1.0, Color(0.05, 0.05, 0.05, 0.70))
	_r(x0 + 2.0, y0 + 22.0, 13.0, 8.0, Color(0, 0, 0, 0.55))
	_r(x0 + 2.0, y0 + 22.0, 13.0, 1.0, C_RUST)
	_r(x0 + 17.0, y0 + 22.0, 13.0, 8.0, Color(0.155, 0.175, 0.205))
	_r(x0 + 2.0, y0 + 32.0, 28.0, 2.0, Color(0, 0, 0, 0.30))

func _graffiti() -> void:
	# выцветшая краска: рваные края и потёки, чтобы не читались как прямоугольники
	_noise(46, 82.0, 116.0, 144.0, 134.0, 0.05, 0.10)
	_noise(30, 302.0, 146.0, 362.0, 164.0, 0.05, 0.10)

	# красный: заплатки по углам
	_poly(PackedVector2Array([
		Vector2(80, 115), Vector2(94, 115), Vector2(88, 122), Vector2(80, 125),
	]), C_PLASTER)
	_poly(PackedVector2Array([
		Vector2(130, 115), Vector2(145, 115), Vector2(145, 125), Vector2(136, 120),
	]), C_PLASTER)
	_poly(PackedVector2Array([
		Vector2(80, 127), Vector2(93, 131), Vector2(87, 135), Vector2(80, 135),
	]), C_PLASTER)
	_poly(PackedVector2Array([
		Vector2(134, 131), Vector2(145, 128), Vector2(145, 135), Vector2(138, 135),
	]), C_PLASTER)
	# потёки
	_r(100.0, 134.0, 1.0, 7.0, Color(0.45, 0.14, 0.12, 0.18))
	_r(121.0, 133.0, 1.0, 5.0, Color(0.45, 0.14, 0.12, 0.14))
	_r(138.0, 132.0, 1.0, 4.0, Color(0.45, 0.14, 0.12, 0.12))

	# голубой: заплатки
	_poly(PackedVector2Array([
		Vector2(300, 145), Vector2(314, 145), Vector2(308, 152), Vector2(300, 155),
	]), C_PLASTER)
	_poly(PackedVector2Array([
		Vector2(350, 145), Vector2(365, 145), Vector2(365, 156), Vector2(356, 151),
	]), C_PLASTER)
	_poly(PackedVector2Array([
		Vector2(300, 157), Vector2(313, 161), Vector2(307, 165), Vector2(300, 165),
	]), C_DADO)
	_poly(PackedVector2Array([
		Vector2(352, 161), Vector2(365, 158), Vector2(365, 165), Vector2(356, 165),
	]), C_DADO)
	# потёки
	_r(320.0, 164.0, 1.0, 7.0, Color(0.16, 0.30, 0.42, 0.16))
	_r(345.0, 163.0, 1.0, 5.0, Color(0.16, 0.30, 0.42, 0.12))

	_ln(86.0, 124.0, 132.0, 120.0, Color(0.75, 0.35, 0.30, 0.18))
	_ln(308.0, 154.0, 352.0, 150.0, Color(0.35, 0.55, 0.75, 0.16))

func _lamp_glow() -> void:
	draw_circle(Vector2(240, 44), 8.0, Color(1.0, 0.82, 0.55, 0.05))
	draw_circle(Vector2(240, 44), 15.0, Color(1.0, 0.80, 0.52, 0.025))
	draw_circle(Vector2(400, 44), 7.0, Color(1.0, 0.82, 0.55, 0.04))
	draw_circle(Vector2(400, 44), 13.0, Color(1.0, 0.80, 0.52, 0.02))

func _door_light() -> void:
	# холодный затек из входной двери
	_poly(PackedVector2Array([
		Vector2(28, 194), Vector2(52, 194), Vector2(64, 246), Vector2(16, 246),
	]), Color(0.55, 0.66, 0.86, 0.035))

func _cobwebs() -> void:
	_ln(17.0, 33.0, 34.0, 33.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(17.0, 33.0, 17.0, 50.0, Color(0.75, 0.78, 0.80, 0.05))
	_ln(463.0, 33.0, 446.0, 33.0, Color(0.75, 0.78, 0.80, 0.04))

func _dust() -> void:
	for i in 14:
		var fi := float(i)
		var px := 60.0 + fmod(fi * 53.0, 360.0) + sin(_t * 0.21 + fi) * 5.0
		var py := 40.0 + fmod(fi * 37.0, 150.0) + sin(_t * 0.33 + fi * 1.3) * 4.0
		var a := 0.05 + 0.05 * (0.5 + 0.5 * sin(_t * 0.7 + fi))
		_dust_mote(px, py, a)