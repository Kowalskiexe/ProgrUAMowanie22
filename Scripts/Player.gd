extends Node2D
class_name Player

export var score = 1000 setget set_score
var starting_score = score
export var step_cost = 100
export var bonus_score = 500
export var step = 32
onready var map: Map = $'/root/Main Scene/TileMap'
onready var score_label: Label = $'/root/Main Scene/CanvasLayer/ScoreLabel'
onready var code_field: TextEdit = $'/root/Main Scene/CanvasLayer/CodeField'
onready var syntax_error_dialog: AcceptDialog = $'/root/Main Scene/CanvasLayer/SyntaxErrorDialog'
onready var endgame_dialog: AcceptDialog = $'/root/Main Scene/CanvasLayer/EndgameDialog'
onready var timer: Timer = $Timer
onready var starting_postion = position

func endgame_popup(title: String, message: String) -> void:
	endgame_dialog.window_title = title
	endgame_dialog.dialog_text = message
	endgame_dialog.popup_centered()

func find_opening_brace(lines, current_line_num):
	var extra_closing = 0
	for i in range(current_line_num - 1, -1, -1):
		if lines[i] == '}':
			extra_closing += 1
		if lines[i].ends_with('{'):
			if extra_closing == 0:
				return i
			extra_closing -= 1
	syntax_error('Brak { dla } na linii %d' % current_line_num + 1)

func run():
	print('start')
	var code = code_field.text
	var lines = code.split('\n')
	for i in range(lines.size()):
		lines[i] = lines[i].strip_edges()
	var current_line_num = 0
	var jumps_counter = {}
	while current_line_num < lines.size():
		var line = lines[current_line_num]
		code_field.cursor_set_line(current_line_num)
		var matched: bool = false
		
		# empty line
		if line == '':
			matched = true
		
		# comment
		if line.begins_with('#'):
			matched = true
		
		# loop beginning
		if line.begins_with('repeat'):
			var args = line.split(' ')
			if args[-1] != '{':
				syntax_error('Brak { na końcu linii %d' % (current_line_num + 1))
				return
			var times = int(args[1])
			if times == 0:
				syntax_error('Zła liczba powtórzeń (%s) na linii %d' % [args[1], current_line_num + 1])
				return
			jumps_counter[current_line_num] = times - 1
			matched = true
		
		# loop end
		if line == '}':
			var closing = current_line_num
			current_line_num = find_opening_brace(lines, current_line_num)
			if jumps_counter[current_line_num] == 0:
				# jump back to the closing brace
				current_line_num = closing
			else:
				jumps_counter[current_line_num] -= 1
			matched = true
		
		# move commands
		match line:
			'move_north':
				print('going north')
				if can_move_to(position + step_north):
					move_north()
					just_moved()
			'move_south':
				print('going south')
				if can_move_to(position + step_south):
					move_south()
					just_moved()
			'move_east':
				print('going east')
				if can_move_to(position + step_east):
					move_east()
					just_moved()
			'move_west':
				print('going west')
				if can_move_to(position + step_west):
					move_west()
					just_moved()
			_:
				if not matched:
					syntax_error('Nieznana komenda %s na linii %d' % [line, current_line_num + 1])
					return
		current_line_num += 1
		yield()
	print('finished')
	var finished_at = map.get_tile_name(position)
	if finished_at == 'end':
		print('winner with score %d' % score)
		endgame_popup('Zwycięstwo!', 'Udało Ci się dojść do końca z wynikiem %d' % score)
	else:
		print('lost')
		endgame_popup('Porażka!', 'Nie udało Ci się dojść do końca.')
	reset()

func get_indentation(line: String) -> int:
	var out = 0
	while out < line.length() and line[out] == '\t':
		out += 1
	return out

func syntax_error(message: String) -> void:
	syntax_error_dialog.popup_centered()
	syntax_error_dialog.dialog_text = message
	reset()

func set_score(new_score) -> void:
	score = new_score
	score_label.set_text('WYNIK: %d' % score)

var step_north = Vector2(0, -step)
var step_south = Vector2(0, step)
var step_west = Vector2(-step, 0)
var step_east = Vector2(step, 0)

func _process(_delta):
	return
	if Input.is_action_just_pressed("move_north") and can_move_to(position + step_north):
		move_north()
		just_moved()
	if Input.is_action_just_pressed("move_south") and can_move_to(position + step_south):
		move_south()
		just_moved()
	if Input.is_action_just_pressed("move_east") and can_move_to(position + step_east):
		move_east()
		just_moved()
	if Input.is_action_just_pressed("move_west") and can_move_to(position + step_west):
		move_west()
		just_moved()

var disabled_hearts = []
func just_moved() -> void:
	var tile_name = map.get_tile_name(position)
	if tile_name == 'bonus':
		set_score(score + bonus_score)
		# disable bonus
		var cellv = map.get_tilev(position)
		map.set_cell(cellv.x, cellv.y, map.tile_set.find_tile_by_name('normal'))
		disabled_hearts.append(cellv)
	set_score(score - step_cost)

func can_move_to(pos: Vector2) -> bool:
	var tile_name: String = map.get_tile_name(pos)
	return tile_name != '' and tile_name != 'blocked'

func move_north():
	position += step_north

func move_south():
	position += step_south

func move_west():
	position += step_west

func move_east():
	position += step_east

func reset():
	position = starting_postion
	set_score(starting_score)
	timer.stop()
	# reset hearts
	for cellv in disabled_hearts:
		map.set_cell(cellv.x, cellv.y, map.tile_set.find_tile_by_name('bonus'))
	disabled_hearts.clear()

var co
func _on_RunButton_pressed():
	co = run()
	timer.start()

func _on_Timer_timeout():
	if co is GDScriptFunctionState and co.is_valid():
		co = co.resume()


func _on_StopButton_pressed():
	reset()
