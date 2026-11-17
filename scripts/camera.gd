extends Camera2D

@export var target_path: NodePath
@export var follow_speed := 6.5
@export var look_ahead := 26.0
@export var look_speed := 2.0
@export var vertical_offset := -18.0
@export var deadzone := 6.0

# границы задаются в сцене: двор 1760x320, интерьер ~544x272
@export var bound_left := 0
@export var bound_right := 1760
@export var bound_top := 0
@export var bound_bottom := 320

var _target: CharacterBody2D
var _look := 0.0
var _pos := Vector2.ZERO

func _ready() -> void:
	_target = get_node_or_null(target_path) as CharacterBody2D
	limit_left = bound_left
	limit_right = bound_right
	limit_top = bound_top
	limit_bottom = bound_bottom
	snap_to_target()

func _process(delta: float) -> void:
	if _target == null:
		return

	var vx := _target.velocity.x
	var want := 0.0
	if absf(vx) > deadzone:
		want = signf(vx) * look_ahead

	_look = lerpf(_look, want, 1.0 - exp(-look_speed * delta))
	var goal := _target.global_position + Vector2(_look, vertical_offset)
	_pos = _pos.lerp(goal, 1.0 - exp(-follow_speed * delta))
	# округляем до целого пикселя: иначе на 3x-апскейле края дрожат
	global_position = _pos.round()

func snap_to_target() -> void:
	if _target == null:
		return
	_pos = _target.global_position + Vector2(0.0, vertical_offset)
	global_position = _pos