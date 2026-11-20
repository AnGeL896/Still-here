extends DoorTransition
class_name FoldingLadder

## Складная лестница. Точка взаимодействия на полу (неподвижная).
## Визуал (LadderVisual) складывается вверх. Первый E — опустить, второй E — переход.

@export var visual_path: NodePath      ## путь к LadderVisual (дочерний узел с лестницей)
@export var folded_offset := -100.0    ## насколько визуал поднимается вверх (сложено)
@export var fold_time := 0.7           ## время анимации опускания

var _visual: Node2D
var _extended := false
var _tween: Tween

func _ready() -> void:
	super._ready()  # Interactable._ready — add_to_group("interactable")
	_visual = get_node_or_null(visual_path) as Node2D
	if _visual:
		_visual.position.y = folded_offset
	# промпт по умолчанию — опустить
	open_prompt = "E — опустить лестницу"

func interact(player: Node) -> void:
	# первый E (лестница сложена) — опустить
	if not _extended:
		_extend()
		return
	# второй E (лестница опущена) — обычный переход двери
	super.interact(player)

func _extend() -> void:
	_extended = true
	open_prompt = "E — подняться"
	if _visual == null:
		return
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_CUBIC)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(_visual, "position:y", 0.0, fold_time)
	_play_creak()

func _play_creak() -> void:
	var audio := AudioStreamPlayer.new()
	audio.volume_db = -12.0
	add_child(audio)
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
	if not _extended:
		return "E — опустить лестницу"
	return open_prompt