extends SceneTree

func _save(note: NoteData, path: String) -> void:
	var err := ResourceSaver.save(note, path)
	print("saved ", path, " err=", err)

func _initialize() -> void:
	# 1. Записка во дворе — код от СЕЙФА В КВАРТИРЕ
	var n1 := NoteData.new()
	n1.id = "notice_01"
	n1.title = "Объявление"
	n1.author = "Городская служба, участок 4"
	n1.pages = PackedStringArray([
		"Уважаемые жильцы! В связи с закрытием завода и отключением теплоснабжения просим освободить помещения до 25-го числа. Ключи сдать в домоуправление.",
		"Служебная строка: код подъездного сейфа — 4-7-1. После смены кода записку уничтожить.",
		"Приписка от руки: «В 4-й квартире свет не выключать. Я обещал.»",
	])
	_save(n1, "res://data/notes/notice_01.tres")

	# 2. Записка в квартире — код от СЕЙФА В ПОДВАЛЕ
	var n2 := NoteData.new()
	n2.id = "apt4_note"
	n2.title = "Записка на столе"
	n2.author = "— не подписано"
	n2.pages = PackedStringArray([
		"Хлеб. Спички. Керосин. И лампочка в коридор — опять перегорела.",
		"В подвале счётчик. Код 2-9-4. Записать, пока не забыл.",
		"Свет не выключать. Пусть видят, что тут кто-то есть.",
	])
	_save(n2, "res://data/notes/apt4_note.tres")

	# 3. Новая записка в подвале — код от СЕЙФА НА ЧЕРДАКЕ
	var n3 := NoteData.new()
	n3.id = "basement_note"
	n3.title = "Листок из журнала"
	n3.author = "— вырвано"
	n3.pages = PackedStringArray([
		"Если полезешь на чердак — там сейф с инструментом. Код 5-1-6.",
		"Не наступай на третью стропилу, она гнилая.",
	])
	_save(n3, "res://data/notes/basement_note.tres")

	quit()