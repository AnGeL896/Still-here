extends Node2D

## Стена жилого дома с подъездом. Поверх T_BRICK (z=0), под игроком.
## Панельные швы, козырёк, тёмные окна, тусклая лампочка у входа.

@export var wall_w := 544.0                       # ширина стены (≈34 тайла)
@export var wall_h := 200.0                       # высота
@export var door_x := 8.0                         # смещение двери от начала стены
@export var wall_color := Color(0.184, 0.157, 0.157)
@export var window_color := Color(0.020, 0.025, 0.040)  # тёмные окна
@export var lamp_energy := 0.35

func _ready() -> void:
	z_index = 0
	_build()

func _build() -> void:
	# вертикальные панельные швы
	var panels := maxi(1, int(wall_w / 64.0))
	for i in range(1, panels):
		var x := i * (wall_w / panels)
		var s := Polygon2D.new()
		s.color = Color(wall_color.r * 0.8, wall_color.g * 0.8, wall_color.b * 0.8, 0.6)
		s.polygon = PackedVector2Array([
			Vector2(x, 0), Vector2(x + 1, 0),
			Vector2(x + 1, -wall_h), Vector2(x, -wall_h),
		])
		add_child(s)

	# горизонтальные швы (этажи)
	var floors := maxi(1, int(wall_h / 28.0))
	for j in range(1, floors):
		var y := -j * (wall_h / floors)
		var s := Polygon2D.new()
		s.color = Color(wall_color.r * 0.85, wall_color.g * 0.85, wall_color.b * 0.85, 0.4)
		s.polygon = PackedVector2Array([
			Vector2(0, y), Vector2(wall_w, y),
			Vector2(wall_w, y + 1), Vector2(0, y + 1),
		])
		add_child(s)

	# тёмные окна выше (без света)
	var rng := RandomNumberGenerator.new(); rng.seed = 2024
	for k in 3:
		var wx := 40.0 + k * 170.0
		if wx > wall_w - 20.0:
			break
		var wy := -wall_h + 26.0
		var w := Polygon2D.new()
		w.color = window_color
		w.polygon = PackedVector2Array([
			Vector2(wx, wy), Vector2(wx + 10, wy),
			Vector2(wx + 10, wy + 13), Vector2(wx, wy + 13),
		])
		add_child(w)

	# козырёк над дверью
	var awning := Polygon2D.new()
	awning.color = Color(0.10, 0.11, 0.13)
	awning.polygon = PackedVector2Array([
		Vector2(door_x - 14, -34), Vector2(door_x + 14, -34),
		Vector2(door_x + 18, -27), Vector2(door_x - 18, -27),
	])
	add_child(awning)

	# тусклая лампочка у входа
	var lamp := PointLight2D.new()
	lamp.position = Vector2(door_x, -24)
	lamp.color = Color(1.0, 0.80, 0.50)
	lamp.energy = lamp_energy
	var grad := Gradient.new()
	grad.offsets = PackedFloat32Array([0.0, 0.4, 1.0])
	grad.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 0.5), Color(1, 1, 1, 0)])
	var tex := GradientTexture2D.new()
	tex.gradient = grad
	tex.width = 128; tex.height = 128; tex.fill = 1
	tex.fill_from = Vector2(0.5, 0.5); tex.fill_to = Vector2(1, 0.5)
	lamp.texture = tex
	lamp.texture_scale = 1.2
	add_child(lamp)