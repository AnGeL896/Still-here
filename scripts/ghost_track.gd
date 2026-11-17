extends Resource
class_name GhostTrack

## Кадры призрака. Один трек = одно явление.
## Кадр: { "t": время_в_секундах, "x": float, "y": float, "flip": bool }

@export var frames: Array[Dictionary] = []
@export var loop := false

func add_frame(t: float, x: float, y: float, flip := false) -> void:
	frames.append({"t": t, "x": x, "y": y, "flip": flip})

func duration() -> float:
	if frames.is_empty():
		return 0.0
	return float(frames[frames.size() - 1]["t"])

func is_empty() -> bool:
	return frames.is_empty()

## Линейная интерполяция между двумя ближайшими кадрами.
func sample(time: float) -> Dictionary:
	if frames.is_empty():
		return {}
	if frames.size() == 1 or time <= float(frames[0]["t"]):
		return frames[0]

	var last: Dictionary = frames[frames.size() - 1]
	if time >= float(last["t"]):
		return last

	var lo := 0
	var hi := frames.size() - 1
	while lo + 1 < hi:
		var mid := (lo + hi) / 2
		if float(frames[mid]["t"]) <= time:
			lo = mid
		else:
			hi = mid

	var a: Dictionary = frames[lo]
	var b: Dictionary = frames[hi]
	var span := float(b["t"]) - float(a["t"])
	var k := 0.0 if span <= 0.0 else (time - float(a["t"])) / span

	return {
		"x": lerpf(float(a["x"]), float(b["x"]), k),
		"y": lerpf(float(a["y"]), float(b["y"]), k),
		"flip": bool(a["flip"]),
	}

## Авторская заготовка: равномерное движение по точкам.
## Пригождается, когда трек ещё не записан тулзой.
static func from_waypoints(points: PackedVector2Array, speed := 24.0, fps := 30.0) -> GhostTrack:
	var track := GhostTrack.new()
	if points.size() < 2:
		return track

	var t := 0.0
	var first_dir := points[1].x < points[0].x
	track.add_frame(0.0, points[0].x, points[0].y, first_dir)

	for i in range(1, points.size()):
		var seg: Vector2 = points[i] - points[i - 1]
		var dur := seg.length() / maxf(speed, 0.001)
		var steps := maxi(1, int(ceil(dur * fps)))
		for s in range(1, steps + 1):
			var p: Vector2 = points[i - 1] + seg * (float(s) / float(steps))
			t += dur / float(steps)
			track.add_frame(t, p.x, p.y, seg.x < 0.0)
	return track