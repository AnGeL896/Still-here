extends Node

## Соединяет источник питания с потребителем.
## Стоит в сцене, чтобы не хардкодить связи в коде.

@export var source_path: NodePath
@export var consumer_path: NodePath

func _ready() -> void:
	var src := get_node_or_null(source_path)
	var dst := get_node_or_null(consumer_path)
	if src == null or dst == null:
		push_warning("Circuit: не нашёл узлы")
		return

	var initial := false
	if src.has_method("is_powered"):
		initial = bool(src.call("is_powered"))

	if src.has_signal("power_changed"):
		src.power_changed.connect(_on_power)
	if dst.has_method("set_powered"):
		dst.call("set_powered", initial)

func _on_power(v: bool) -> void:
	var dst := get_node_or_null(consumer_path)
	if dst and dst.has_method("set_powered"):
		dst.call("set_powered", v)