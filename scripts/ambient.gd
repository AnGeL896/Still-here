extends Node2D

## Процедурный эмбиент. Без .wav файлов.
## Типы: трансформаторный гул, капли, ветер.

enum Ambient { HUM, DRIP, WIND }

@export var type: Ambient = Ambient.HUM
@export var volume_db := -20.0

var _player: AudioStreamPlayer
var _t := 0.0
var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	_rng.seed = randi()
	_player = AudioStreamPlayer.new()
	_player.volume_db = volume_db
	add_child(_player)

	match type:
		Ambient.HUM:
			_start_hum()
		Ambient.DRIP:
			_start_drip()
		Ambient.WIND:
			_start_wind()

func _start_hum() -> void:
	var stream := _make_hum(4.0)
	_player.stream = stream
	_player.play()

func _make_hum(duration: float) -> AudioStream:
	var sr := 22050
	var samples := int(duration * sr)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var base := 50.0  # 50 Гц — гул трансформатора
	var harm := 100.0

	for i in samples:
		var t := float(i) / sr
		var s := sin(TAU * base * t) * 0.15
		s += sin(TAU * harm * t) * 0.05
		# лёгкий шум
		s += _rng.randf_range(-1.0, 1.0) * 0.01
		s = clampf(s, -1.0, 1.0)
		data.encode_s16(i * 2, int(s * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream

func _start_drip() -> void:
	# случайные капли с интервалом
	_t = 0.0
	set_process(true)

func _process(delta: float) -> void:
	if type != Ambient.DRIP:
		return
	_t += delta
	if _t > _rng.randf_range(0.5, 2.5):
		_t = 0.0
		_play_drip()

func _play_drip() -> void:
	var sr := 22050
	var duration := 0.15
	var samples := int(duration * sr)
	var data := PackedByteArray()
	data.resize(samples * 2)

	var freq := _rng.randf_range(800.0, 1400.0)
	for i in samples:
		var t := float(i) / sr
		var env := exp(-t * 25.0)
		var s := sin(TAU * freq * t) * env * 0.3
		s = clampf(s, -1.0, 1.0)
		data.encode_s16(i * 2, int(s * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data

	_player.stream = stream
	_player.play()

func _start_wind() -> void:
	var stream := _make_wind(6.0)
	_player.stream = stream
	_player.play()

func _make_wind(duration: float) -> AudioStream:
	var sr := 22050
	var samples := int(duration * sr)
	var data := PackedByteArray()
	data.resize(samples * 2)

	for i in samples:
		var t := float(i) / sr
		# низкий шум ветра
		var s := _rng.randf_range(-1.0, 1.0) * 0.08
		s += sin(TAU * 80.0 * t) * 0.02
		s = clampf(s, -1.0, 1.0)
		data.encode_s16(i * 2, int(s * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_end = samples
	return stream