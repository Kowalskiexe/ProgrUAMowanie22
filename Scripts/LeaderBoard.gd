extends ColorRect
class_name LeaderBoard

var players = []
onready var text: Label = $LeaderBoardText

func show():
	self.visible = true

func hide():
	self.visible = false

class MyCustomSorter:
	static func sort_descending(a, b):
		return a.score > b.score


func generate_text():
	players.sort_custom(MyCustomSorter, 'sort_descending')
	var list = []
	var i = 1
	for p in players:
		list.append('%d. %s %d\n' % [i, p.name, p.score])
		i += 1
	return ''.join(list)

func add(name: String, score: int) -> void:
	players.append({"name": name, "score": score})
	updateText()

func _ready():
	updateText()

func updateText() -> void:
	text.text = generate_text()

func _on_ExitButton_pressed():
	hide()


func _on_ShowLeaderBoardButton_pressed():
	show()

func _on_WinDialog_add_player(name, score):
	add(name, score)
