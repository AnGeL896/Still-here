extends Interactable
class_name NoteInteractable

## Записка на стене/столе. Открывает UI чтения.

@export var note: NoteData

func _ready() -> void:
	super._ready()
	if prompt == "E":
		prompt = "E — прочитать"

func interact(player: Node) -> void:
	if not can_interact():
		return
	if once:
		_used = true
	if note == null:
		return
	Story.mark_note_read(note.id)
	Story.set_flag("read_" + note.id)
	UI.show_note(note)