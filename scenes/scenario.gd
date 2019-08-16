extends Node2D

export (int) var speed = 250

var velocity = Vector2()
var last_direction = "down"
var main_char:KinematicBody2D
var main_char_position:Vector2

func _ready():
	main_char = create_piece(Vector2(0,0))
	pass

func create_piece(position)->KinematicBody2D:
	var piece = load("res://scenes/piece.tscn")
	var piece_node = piece.instance()
	$character_group.add_child(piece_node)
	piece_node.set_to_board_pos(position, $map.global_position)
	return piece_node

func get_input():
	var direction = rad2deg($joypad.left_input.angle())
	var to_add:Vector2 = Vector2(0,0)
	
	velocity = $joypad.left_input
	rotation = $joypad.right_input.angle()
	
	#These angles shoud be adjusted to match character needs
	if (velocity.x != 0) or (velocity.y != 0):
		#RIGHT--------------------------------------
		if (direction <= 0 and direction > -45) or (direction >= 0 and direction < 45):
			last_direction = "right"
			to_add += Vector2(1, 0)
		#UP-----------------------------------------
		if direction <= -45 and direction > -135:
			last_direction = "up"
			to_add += Vector2(0, -1)
		#LEFT---------------------------------------
		if (direction <= -135 and direction > -180) or (direction >= 135 and direction < 180):
			last_direction = "left"
			to_add += Vector2(-1, 0)
		#DOWN---------------------------------------
		if direction >= 45 and direction < 135:
			last_direction = "down"
			to_add += Vector2(0, 1)
	
	if not main_char.is_moving():
		var new_pos = to_add + main_char.get_board_position()
		main_char.set_to_board_pos(new_pos, $map.global_position)
	pass

func _physics_process(delta):
	get_input()
	pass