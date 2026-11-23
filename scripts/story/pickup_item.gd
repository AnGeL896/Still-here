extends Interactable
class_name PickupItem

## Предмет на полу/столе. E — подобрать.

@export var item_id := ""
@export var item_name := "Предмет"
## Уникальный ключ для сохранения. Пусто = имя узла.
@export var pickup_id := ""

func _ready() -> void:
	super._ready()
	if pickup_id == "":
		pickup_id = name
	prompt = "E — взять: " + item_name
	once = true

	# уже подбирали в прошлый раз — не возвращаем
	if Story.has_flag("picked_" + pickup_id):
		_used = true
		enabled = false
		visible = false
		set_process(false)

func interact(_player: Node) -> void:
	if not can_interact():
		return
	Inventory.add(item_id, 1, item_name)
	Story.set_flag("picked_" + pickup_id)
	_used = true
	enabled = false
	visible = false
	set_process(false)