extends ParallaxBackground

## Далёкий город. Три слоя силуэтов.
## Крыши с надстройками и антеннами — чтобы не читались как коробки.

const BASE_Y := 300.0
const SPAN := 2600.0

func _ready() -> void:
	_build_skyline(0.12, Color(0.043, 0.055, 0.078), 150.0, 91)
	_build_skyline(0.30, Color(0.063, 0.078, 0.110), 110.0, 41)
	_build_skyline(0.55, Color(0.086, 0.102, 0.140), 76.0, 77)

func _build_skyline(motion: float, col: Color, max_h: float, seed: int) -> void:
	var layer := ParallaxLayer.new()
	layer.motion_scale = Vector2(motion, motion)
	add_child(layer)

	var rng := RandomNumberGenerator.new()
	rng.seed = seed

	var x := -400.0
	while x < SPAN:
		var w := rng.randf_range(34.0, 96.0)
		var h := rng.randf_range(max_h * 0.32, max_h)
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
			var rh := rng.randf_range(5.0, 16.0)
			var rx := x + rng.randf_range(3.0, maxf(3.0, w - rw - 3.0))
			var roof := Polygon2D.new()
			roof.polygon = PackedVector2Array([
				Vector2(rx, top), Vector2(rx + rw, top),
				Vector2(rx + rw, top - rh), Vector2(rx, top - rh),
			])
			roof.color = col
			layer.add_child(roof)

		# антенны и трубы
		if rng.randf() < 0.30:
			var n := rng.randi_range(1, 2)
			for i in n:
				var ax := x + rng.randf_range(4.0, maxf(4.0, w - 4.0))
				var ah := rng.randf_range(6.0, 22.0)
				var ant := Polygon2D.new()
				ant.polygon = PackedVector2Array([
					Vector2(ax, top), Vector2(ax + 1.2, top),
					Vector2(ax + 1.2, top - ah), Vector2(ax, top - ah),
				])
				ant.color = col
				layer.add_child(ant)

		# редкие окна
		if rng.randf() < 0.4:
			var cols := int(w / 16.0)
			var rows := int(h / 22.0)
			for cx in cols:
				for cy in rows:
					if rng.randf() < 0.12:
						var wx := x + 6.0 + cx * 16.0
						var wy := top + 8.0 + cy * 22.0
						var win := Polygon2D.new()
						win.polygon = PackedVector2Array([
							Vector2(wx, wy), Vector2(wx + 3, wy),
							Vector2(wx + 3, wy + 4), Vector2(wx, wy + 4),
						])
						win.color = Color(0.55, 0.48, 0.32, 0.5)
						layer.add_child(win)

		x += w + rng.randf_range(2.0, 22.0)