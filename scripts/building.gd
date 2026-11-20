extends Node2D

## Панельный дом на фоне. Приглушённый силуэт с панелями, этажами и проводами.
## Ставится поверх блоков T_DEEP (фон без коллизии), z_index = -3.

@export var width := 200.0        ## ширина здания
@export var height := 120.0       ## высота (вверх от позиции)
@export var seed := 1
@export var base_color := Color(0.043, 0.055, 0.078)   ## силуэт (как T_DEEP)
@export var window_color := Color(0.020, 0.025, 0.040) ## совсем тёмные окна

func _ready() -> void:
	z_index = -3
	_build()

func _build() -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	# силуэт
	var body := Polygon2D.new()
	body.color = base_color
	body.polygon = PackedVector2Array([
		Vector2(0, 0), Vector2(width, 0),
		Vector2(width, -height), Vector2(0, -height),
	])
	add_child(body)

	# вертикальные швы между панелями
	var panels := maxi(1, int(width / 48.0))
	for i in range(1, panels):
		var x := i * (width / panels)
		var seam := Polygon2D.new()
		seam.color = Color(base_color.r * 0.78, base_color.g * 0.78, base_color.b * 0.78, 0.7)
		seam.polygon = PackedVector2Array([
			Vector2(x, 0), Vector2(x + 1, 0),
			Vector2(x + 1, -height), Vector2(x, -height),
		])
		add_child(seam)

	# горизонтальные швы (этажи)
	var floors := maxi(1, int(height / 22.0))
	for j in range(1, floors):
		var y := -j * (height / floors)
		var seam := Polygon2D.new()
		seam.color = Color(base_color.r * 0.85, base_color.g * 0.85, base_color.b * 0.85, 0.45)
		seam.polygon = PackedVector2Array([
			Vector2(0, y), Vector2(width, y),
			Vector2(width, y + 1), Vector2(0, y + 1),
		])
		add_child(seam)

	# окна — совсем тёмные, едва заметные
	for cx in panels:
		for cy in floors:
			if rng.randf() < 0.5:
				var wx := 5.0 + cx * (width / panels)
				var wy := -5.0 - cy * (height / floors)
				var win := Polygon2D.new()
				win.color = window_color
				win.polygon = PackedVector2Array([
					Vector2(wx, wy), Vector2(wx + 5, wy),
					Vector2(wx + 5, wy + 6), Vector2(wx, wy + 6),
				])
				add_child(win)

	# провода вдоль верхнего края
	for i in 2:
		var ly := -height - 2.0 - i * 3.0
		var wire := Line2D.new()
		wire.width = 0.6
		wire.default_color = Color(0.02, 0.02, 0.03, 0.8)
		wire.add_point(Vector2(-10, ly))
		wire.add_point(Vector2(width + 10, ly + rng.randf_range(-2.0, 3.0)))
		add_child(wire)