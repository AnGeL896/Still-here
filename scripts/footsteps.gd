extends Node2D

## Процедурные звуки шагов. Без .wav — генерируем в памяти.
## Мягкий стук, без хруста и шума.

enum Surface { STONE, WOOD, DIRT }

@export var surface: Surface = Surface.STONE
@export var step_interval := 0.28
@export var volume_db := -14.0

var _player: CharacterBody2D
var _t := 0.0
var _was_on_floor := false
var _players: Array[AudioStreamPlayer] = []
var _player_idx := 0

func _ready() -> void:
	for i in 3:
		var p := AudioStreamPlayer.new()
		p.volume_db = volume_db
		add_child(p)
		_players.append(p)

func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
		if _player == null:
			return

	var on_floor := _player.is_on_floor()
	if not _was_on_floor and on_floor:
		_play_step(true)
		_t = 0.0
	elif on_floor and absf(_player.velocity.x) > 6.0:
		_t += delta
		if _t >= step_interval:
			_t = 0.0
			_play_step(false)
	_was_on_floor = on_floor

func _play_step(land: bool) -> void:
	var stream := _make_step(land)
	if stream == null:
		return
	var p := _players[_player_idx]
	_player_idx = (_player_idx + 1) % _players.size()
	p.stream = stream
	p.volume_db = volume_db + (3.0 if land else 0.0)
	p.play()

func _make_step(heavy: bool) -> AudioStream:
	var sr := 22050
	var duration := 0.06 if not heavy else 0.10
	var samples := int(duration * sr)
	var data := PackedByteArray()
	data.resize(samples * 2)

	# параметры поверхности
	var freq: float
	var decay: float
	match surface:
		Surface.STONE:
			freq = 180.0
			decay = 18.0
		Surface.WOOD:
			freq = 220.0
			decay = 14.0
		Surface.DIRT:
			freq = 120.0
			decay = 10.0

	for i in samples:
		var t := float(i) / sr
		var env := exp(-t * decay)
		if heavy:
			env *= 1.3
		# чистый тон без шума
		var s := sin(TAU * freq * t) * env * 0.35
		# лёгкий второй гармоник для объёма
		s += sin(TAU * freq * 2.0 * t) * env * 0.08
		s = clampf(s, -1.0, 1.0)
		data.encode_s16(i * 2, int(s * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data
	return stream