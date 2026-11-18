extends Node2D
class_name FoldingLadder

## Складная лестница. В сложенном состоянии висит наверху.
## При взаимодействии (E) — опускается с анимацией + звук скрипа.
## После подъёма — складывается обратно.

@export var folded_y := -100.0  ## Y лестницы в сложенном состоянии (относительно родителя)
@export var extended_y := 0.0   ## Y лестницы в опущенном состоянии
@export var fold_speed := 3.0   ## Скорость анимации
@export var creak_sound := true ## Звук скрипа при движении

var _extended := false
var _tween: Tween
var _player: CharacterBody2D
var _can_interact := true

func _ready() -> void:
	# стартовое состояние — сложено
	position.y = folded_y
	# слушаем игрока
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D

func _process(delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		return
	# проверяем, рядом ли игрок
	var dist := global_position.distance_to(_player.global_position)
	_can_interact = dist < 40.0

func interact(player: Node) -> void:
	if not _can_interact:
		return
	_toggle()

func _toggle() -> void:
	_extended = not _extended
	var target_y := extended_y if _extended else folded_y
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position:y", target_y, 1.0 / fold_speed)
	# звук скрипа
	if creak_sound:
		_play_creak()

func _play_creak() -> void:
	var audio := AudioStreamPlayer.new()
	audio.volume_db = -12.0
	add_child(audio)
	# генерируем простой скрип (низкий скрип)
	var stream := AudioStreamWAV.new()
	var sr := 22050
	var duration := 0.6
	var samples := int(duration * sr)
	var data := PackedByteArray()
	data.resize(samples * 2)
	var rng := RandomNumberGenerator.new()
	rng.seed = randi()
	for i in samples:
		var t := float(i) / sr
		var env := sin(t / duration * PI)
		var freq := 80.0 + rng.randf_range(-20.0, 20.0)
		var s := sin(TAU * freq * t) * env * 0.3
		s = clampf(s, -1.0, 1.0)
		data.encode_s16(i * 2, int(s * 32767.0))
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sr
	stream.stereo = false
	stream.data = data
	audio.stream = stream
	audio.play()
	get_tree().create_timer(duration).timeout.connect(audio.queue_free)

func get_prompt() -> String:
	if _can_interact:
		return "E — опустить" if not _extended else "E — поднять"
	return ""