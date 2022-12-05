extends TextEdit


onready var default_text: String = text
onready var start_button: Button = $StartWritingButton
onready var player: Player = $'/root/Main Scene/Player'
onready var timer: Timer = $WritingTimer
onready var block: ColorRect = $Block
export var points_per_second = -1

func lock():
	readonly = true
	start_button.visible = false
	block.visible = true
	timer.stop()

func lock_with_button():
	readonly = true
	start_button.visible = true
	block.visible = true
	timer.stop()

func unlock():
	readonly = false
	start_button.visible = false
	block.visible = false
	timer.start()

func _ready():
	lock_with_button()

func reset_text():
	text = default_text

func _on_StartWritingButton_pressed():
	unlock()

func _on_WritingTimer_timeout():
	player.change_score(points_per_second)


func _on_RunButton_pressed():
	lock()


func _on_Player_reset_game():
	reset_text()
	lock_with_button()
