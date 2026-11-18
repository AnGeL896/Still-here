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
var _body: Node2D
var frozen := false
var _nearby: Interactable

## Эффект приземления
var _was_on_floor := false
var _walk_t := 0.0
var _walk_tilt := 0.0
var _parts: Dictionary = {}

## Фонарик
var _flashlight_on := false

func _ready() -> void:
	add_to_group("player")
	_body = get_node_or_null("Body") as Node2D
	# top_level не нужен — Body движется вместе с Player
	# ноги для анимации
	_parts["LegL"] = _body.get_node_or_null("LegL") if _body else null
	_parts["LegR"] = _body.get_node_or_null("LegR") if _body else null
	_parts["BootL"] = _body.get_node_or_null("BootL") if _body else null
	_parts["BootR"] = _body.get_node_or_null("BootR") if _body else null
	_parts["Flashlight"] = _body.get_node_or_null("Flashlight") if _body else null
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
	if frozen:
		return
	_update_nearby()
	_animate(_delta)

func _animate(delta: float) -> void:
	if _body == null:
		return

	var on_floor := is_on_floor()
	var moving := absf(velocity.x) > 6.0 and on_floor

	# наклон тела при ходьбе
	var target_tilt := 0.0
	if moving:
		_walk_t += delta * absf(velocity.x) * 0.08
		target_tilt = sin(_walk_t) * 1.5
	else:
		_walk_t = lerpf(_walk_t, 0.0, delta * 8.0)

	_walk_tilt = lerpf(_walk_tilt, target_tilt, 1.0 - exp(-10.0 * delta))
	_body.rotation_degrees = _walk_tilt
	_body.scale.x = _facing

	# ноги — шагают в противофазе
	if _parts["LegL"] and _parts["LegR"]:
		var leg_swing := 0.0
		if moving:
			leg_swing = sin(_walk_t) * 4.0
		else:
			leg_swing = lerpf(_parts["LegL"].rotation_degrees, 0.0, delta * 10.0)
		_parts["LegL"].rotation_degrees = leg_swing
		_parts["LegR"].rotation_degrees = -leg_swing
		_parts["BootL"].rotation_degrees = leg_swing
		_parts["BootR"].rotation_degrees = -leg_swing

	# фонарик — качается при ходьбе, управляется стрелками/T
	if _parts["Flashlight"]:
		var fl := _parts["Flashlight"] as Node2D
		var spot := fl.get_node_or_null("SpotLight") as PointLight2D
		var beam := fl.get_node_or_null("FlashlightBeam") as Polygon2D

		# фонарик покачивается при ходьбе
		var fl_base_x := 5.0
		var fl_base_y := -13.0
		if moving:
			fl.position.x = fl_base_x + sin(_walk_t * 0.5) * 1.0
			fl.position.y = fl_base_y + absf(sin(_walk_t)) * 0.5
		else:
			fl.position.x = lerpf(fl.position.x, fl_base_x, delta * 6.0)
			fl.position.y = lerpf(fl.position.y, fl_base_y, delta * 6.0)

		# включён ли фонарик (переключается T)
		var on := _flashlight_on

		# угол луча (стрелки вверх/вниз)
		var target_angle := 0.0
		if Input.is_action_pressed("aim_up"):
			target_angle = -40.0
		elif Input.is_action_pressed("aim_down"):
			target_angle = 40.0
		fl.rotation_degrees = lerpf(fl.rotation_degrees, target_angle, delta * 6.0)

		# свет включается когда темно ИЛИ когда T нажат
		var dark := false
		var scene := get_tree().current_scene
		if scene:
			var path := scene.scene_file_path.to_lower()
			dark = "basement" in path or "attic" in path or "room" in path
		var want_energy := 0.0
		if on and dark:
			want_energy = 0.7
		if spot:
			spot.energy = lerpf(spot.energy, want_energy, delta * 4.0)
		if beam:
			beam.visible = spot.energy > 0.05

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
	if event.is_action_pressed("toggle_flashlight"):
		_flashlight_on = not _flashlight_on
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

	# эффект приземления
	if not _was_on_floor and is_on_floor():
		_on_land()
	_was_on_floor = is_on_floor()

func _on_land() -> void:
	# пыль из-под ног
	var dust := CPUParticles2D.new()
	dust.one_shot = true
	dust.amount = 6
	dust.lifetime = 0.4
	dust.explosiveness = 0.85
	dust.direction = Vector2(0, -1)
	dust.spread = 70.0
	dust.gravity = Vector2(0, 60)
	dust.initial_velocity_min = 12.0
	dust.initial_velocity_max = 28.0
	dust.scale_amount_min = 0.8
	dust.scale_amount_max = 1.6
	dust.color = Color(0.28, 0.26, 0.22, 0.5)
	dust.emitting = true
	get_parent().add_child(dust)
	dust.global_position = global_position + Vector2(0, 14)
	# удаляем через 1 сек
	get_tree().create_timer(1.0).timeout.connect(dust.queue_free)

	# тряска камеры
	var cam := get_node_or_null("Camera") as Camera2D
	if cam and cam.has_method("shake"):
		cam.call("shake", 2.5, 0.15)

func get_facing() -> float:
	return _facing

func get_state() -> String:
	if not is_on_floor():
		return "jump" if velocity.y < 0.0 else "fall"
	if absf(velocity.x) > 6.0:
		return "run"
	return "idle"