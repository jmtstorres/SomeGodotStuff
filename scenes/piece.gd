extends KinematicBody2D

export var sprite_index = 0

var pos_in_board = Vector2(0,0)

var speed = 250
var tile_size = 64

var piece_offset = -110

var start_pos = Vector2()
var from_pos = Vector2()
var to_pos = Vector2()
var direction = Vector2()
var last_direction = Vector2()
var v_one = Vector2(1,1)

var snap_vector = Vector2(tile_size, tile_size/2)

var this_selected = false

func cartesian_to_isometric(cartesian):
	return Vector2(cartesian.x - cartesian.y, (cartesian.x + cartesian.y) / 2)

func to_iso_tiled(cartesian):
	return cartesian_to_isometric(cartesian)*tile_size

func isometric_to_cartesian(isometric):
	var cartesian = Vector2.ZERO
	cartesian.x = isometric.y/2 + isometric.x
	cartesian.y = isometric.y/2 - isometric.x
	return cartesian*tile_size*2

func jump_value(p0: Vector2, p1: Vector2, p2: Vector2, t: float):
	var q0 = p0.linear_interpolate(p1, t)
	var q1 = p1.linear_interpolate(p2, t)
	var r = q0.linear_interpolate(q1, t)
	return r

func position_init(position):
	global_position = position.snapped(snap_vector)
	from_pos = global_position
	to_pos = global_position
	pass

func _ready():
	global_position = global_position.snapped(snap_vector)
	from_pos = global_position
	to_pos = global_position
	#Duplicates shader, otherwise when changed, changes all pieces
	var mat = $sprite.get_material().duplicate()
	$sprite.set_material(mat)
	$smoke.set_emitting(true)
	$smoke.restart()
	pass

func is_moving()->bool:
	return global_position != to_pos


func get_position_in_board(map_position):
	var click_relative = (self.global_position - map_position).snapped(snap_vector)
	var click_iso = Vector2.ZERO
	click_iso.x = click_relative.y*2 - click_relative.x
	click_iso.y = click_relative.y*2 + click_relative.x
	return (click_iso/128).snapped(Vector2(1,1)).round()

func get_direction_frame():
	var direction = to_pos.direction_to(start_pos)
	if direction != last_direction:
		if direction.x >= 0 and direction.y >= 0:
			$sprite.frame = 2
		if direction.x <= 0 and direction.y <= 0:
			$sprite.frame = 1
		if direction.x >= 0 and direction.y <= 0:
			$sprite.frame = 0
		if direction.x <= 0 and direction.y >= 0:
			$sprite.frame = 3
		last_direction = direction
	pass

func move_along_path(dist : float):
	var distance_to_end = from_pos.distance_to(to_pos)
	var distance_total = start_pos.distance_to(to_pos)
	var ratio = distance_to_end/distance_total
	$sprite.offset = jump_value(Vector2(0,piece_offset), Vector2(0,-tile_size*3), Vector2(0,piece_offset), ratio)
	$sombra.scale = jump_value(Vector2(1,1), Vector2(0.5,0.5), Vector2(1,1), ratio)
	if distance_to_end > 15:
		global_position = from_pos.linear_interpolate(to_pos, dist/distance_to_end)
	else:
		global_position = to_pos
		$sprite.offset = Vector2(0,piece_offset)
		$sombra.scale = Vector2(0.9,0.9)
		$sfx.play()
		$smoke.restart()
		$smoke.set_emitting(true)
	dist -= distance_to_end
	from_pos = global_position
	get_direction_frame()
	pass

func _process(delta):
	var dist = speed*delta
	if global_position != to_pos:
		move_along_path(dist)
	pass

func set_to_pos(pos, map_position):
	to_pos = pos
	start_pos = global_position
	direction = from_pos.direction_to(to_pos)
	pass

#pieces should deal externally with board_positioning and
#localli convert to global_positioning
func set_to_board_pos(pos, map_position):
	pos_in_board = pos
	$lbl_pos.text = str(pos_in_board) + "\n" + str(sprite_index)
	to_pos = to_iso_tiled(pos) + map_position + Vector2(0,96)
	start_pos = global_position
	direction = from_pos.direction_to(to_pos)
	pass

func get_board_position():
	return pos_in_board
