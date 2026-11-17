extends Resource
class_name NoteData

## Одна записка. Текст правится в инспекторе, без кода.

@export var id := ""
@export var title := ""
@export var author := ""
@export var pages: PackedStringArray = PackedStringArray()