extends AcceptDialog
class_name WinDialog

signal add_player(name, score)

var score: int

func activate(score: int) -> void:
	self.score = score
	dialog_text = 'Udało Ci się dojść do końca z wynikiem %d!\nPodaj Swoje imię' % score
	popup_centered()

func add_player() -> void:
	var name = $LineEdit.text
	emit_signal('add_player', name, score)
	$LineEdit.text = ''


func _on_WinDialog_confirmed():
	add_player()
