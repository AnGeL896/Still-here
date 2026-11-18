extends ParallaxBackground

## Далёкий ночной город для крыши. Три слоя силуэтов.
## Мы смотрим на город с высоты — поэтому город в нижней части, с редкими огнями.

const BASE_Y := 210.0
const SPAN := 1400.0

func _ready() -> void:
	_build_skyline(0.10, Color(0.070, 0.082, 0.115), 40.0, 91)
	_build_skyline(0.22, Color(0.095, 0.110, 0.150), 58.0, 41)
	_build_skyline(0.40, Color(0.120, 0.135, 0.180), 74.0, 77)

func _build_skyline(motion: float, col: Color, max_h: float, seed: int) -> void:
	var layer := ParallaxLayer.new()
	layer.motion_scale = Vector2(motion, motion)
	add_child(layer)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var x := -300.0
	while x < SPAN:
		var w := rng.randf_range(26.0, 70.0)
		var h := rng.randf_range(max_h * 0.35, max_h)
		var top := BASE_Y - h

		var block := Polygon2D.new()
		block.polygon = PackedVector2Array([
			Vector2(x, BASE_Y),
			Vector2(x + w, BASE_Y),
			Vector2(x + w, top),
			Vector2(x, top),
		])
		block.color = col
		layer.add_child(block)

		# надстройки на крыше
		if rng.randf() < 0.45:
			var rw := w * rng.randf_range(0.22, 0.55)
			var rh := rng.randf_range(4.0, 12.0)
			var rx := x + rng.randf_range(3.0, maxf(3.0, w - rw - 3.0))
			var roof := Polygon2D.new()
			roof.polygon = PackedVector2Array([
				Vector2(rx, top), Vector2(rx + rw, top),
				Vector2(rx + rw, top - rh), Vector2(rx, top - rh),
			])
			roof.color = col
			layer.add_child(roof)

		# антенны и трубы
		if rng.randf() < 0.35:
			var n := rng.randi_range(1, 2)
			for i in n:
				var ax := x + rng.randf_range(4.0, maxf(4.0, w - 4.0))
				var ah := rng.randf_range(5.0, 18.0)
				var ant := Polygon2D.new()
				ant.polygon = PackedVector2Array([
					Vector2(ax, top), Vector2(ax + 1.0, top),
					Vector2(ax + 1.0, top - ah), Vector2(ax, top - ah),
				])
				ant.color = col
				layer.add_child(ant)

		# редкие светящиеся окна (ночной город)
		if rng.randf() < 0.7:
			var cols := int(w / 12.0)
			var rows := int(h / 16.0)
			for cx in cols:
				for cy in rows:
					if rng.randf() < 0.22:
						var wx := x + 4.0 + cx * 12.0
						var wy := top + 5.0 + cy * 16.0
						var win := Polygon2D.new()
						win.polygon = PackedVector2Array([
							Vector2(wx, wy), Vector2(wx + 4.0, wy),
							Vector2(wx + 4.0, wy + 5.0), Vector2(wx, wy + 5.0),
						])
						# тёплые огни (разные оттенки)
						var warm := rng.randf()
						if warm < 0.7:
							win.color = Color(1.0, 0.85, 0.50, 0.95)
						elif warm < 0.9:
							win.color = Color(0.60, 0.72, 0.95, 0.9)
						else:
							win.color = Color(1.0, 0.60, 0.42, 0.9)
						layer.add_child(win)

		x += w + rng.randf_range(2.0, 16.0)