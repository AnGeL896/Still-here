extends CharacterBody2D
class_name Player

# ─── Горизонталь ────────────────────────────────────────────────
@export_category("Движение")
@export var max_speed := 92.0
@export var ground_accel := 1250.0
@export var ground_friction := 1450.0
@export var air_accel := 880.0
@export var air_friction := 420.0

# ─── Прыжок ────────────────────────────────────────────────────
@export_category("Прыжок")
@export var jump_velocity := -268.0
@export var jump_cut := 0.35
@export var coyote_time := 0.10
@export var jump_buffer_time := 0.12

# ─── Гравитация ────────────────────────────────────────────────
@export_category("Гравитация")
@export var gravity_rise := 860.0
@export var gravity_fall := 1350.0
@export var gravity_apex := 520.0
@export var apex_threshold := 30.0
@export var max_fall_speed := 350.0

var _coyote := 0.0
var _buffer := 0.0
var _jumping := false
var _facing := 1.0
var _body: Polygon2D
var frozen := false
var _nearby: Interactable

func _ready() -> void:
	add_to_group("player")
	_body = get_node_or_null("Body") as Polygon2D
	if _body:
		# визуал отвязываем от родителя и округляем до пикселя:
		# физика остаётся дробной, а рисуется ровно
		_body.top_level = true
	floor_snap_length = 4.0
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(50.0)

func set_frozen(v: bool) -> void:
	frozen = v
	if v:
		velocity = Vector2.ZERO
		UI.hide_prompt()

func snap_camera() -> void:
	var cam := get_node_or_null("Camera") as Camera2D
	if cam != null and cam.has_method("snap_to_target"):
		cam.call("snap_to_target")

func _process(_delta: float) -> void:
	if _body:
		_body.global_position = global_position.round()
	if frozen:
		return
	_update_nearby()

func _update_nearby() -> void:
	var best: Interactable = null
	var best_d := 1.0e20
	for node in get_tree().get_nodes_in_group("interactable"):
		var it := node as Interactable
		if it == null or not it.can_interact():
			continue
		var r: float = it.get_radius()
		var d := global_position.distance_squared_to(it.global_position)
		if d <= r * r and d < best_d:
			best_d = d
			best = it
	_nearby = best
	if best != null:
		UI.show_prompt(best.get_prompt())
	else:
		UI.hide_prompt()

func _unhandled_input(event: InputEvent) -> void:
	if frozen:
		return
	if event.is_action_pressed("interact") and _nearby != null:
		_nearby.interact(self)
		get_viewport().set_input_as_handled()

func _physics_process(delta: float) -> void:
	if frozen:
		return
	var grounded := is_on_floor()

	# Койот-таймер: после схода с края ещё можно прыгнуть.
	if grounded:
		_coyote = coyote_time
		_jumping = false
	else:
		_coyote = maxf(0.0, _coyote - delta)

	# Буфер прыжка: нажатие до посадки всё равно сработает.
	if Input.is_action_just_pressed("jump"):
		_buffer = jump_buffer_time
	else:
		_buffer = maxf(0.0, _buffer - delta)

	# ── горизонталь ──
	var dir := Input.get_axis("move_left", "move_right")
	if dir != 0.0:
		_facing = dir
		var accel := ground_accel if grounded else air_accel
		velocity.x = move_toward(velocity.x, dir * max_speed, accel * delta)
	else:
		var fric := ground_friction if grounded else air_friction
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# ── прыжок ──
	if _buffer > 0.0 and _coyote > 0.0:
		velocity.y = jump_velocity
		_buffer = 0.0
		_coyote = 0.0
		_jumping = true

	# Ранний отпуск — низкий прыжок.
	if _jumping and Input.is_action_just_released("jump") and velocity.y < 0.0:
		velocity.y *= jump_cut
		_jumping = false

	# ── гравитация ──
	var g := gravity_rise
	if velocity.y > 0.0:
		g = gravity_fall
	if absf(velocity.y) < apex_threshold:
		g = gravity_apex
	velocity.y = minf(velocity.y + g * delta, max_fall_speed)

	move_and_slide()

func get_facing() -> float:
	return _facing

func get_state() -> String:
	if not is_on_floor():
		return "jump" if velocity.y < 0.0 else "fall"
	if absf(velocity.x) > 6.0:
		return "run"
	return "idle"