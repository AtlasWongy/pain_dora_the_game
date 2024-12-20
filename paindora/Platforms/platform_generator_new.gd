extends Node
class_name PlatformGeneratorNew

@export_category("Platform and Tile")
@export var platform: Platform
@export var tile: Tile

@export_category("Tile Update Settings")
@export var max_tile_num: int = 20
@export var min_tile_gap: int = 2
@export var max_tile_gap: int = 3

var atlas_tile_coordinates: Dictionary = {
	0: Vector2i(5, 0),
	1: Vector2i(6, 0),
	2: Vector2i(7, 0)
}

var color_weights: PackedFloat32Array = PackedFloat32Array([0.7, 0.15, 0.15])
var height_weights: PackedFloat32Array = PackedFloat32Array([0.5, 0.25, 0.25])

var max_tile_height: int = -1
var min_tile_height: int = 10
var tile_height: int = 9
var tile_absent_counter: int = 0

func _ready() -> void:
	generate_platform()

func generate_platform() -> Platform:
	for pos_x in range(0, 20):
		update_tile_properties(tile, pos_x)
		build_tile(tile)
	return platform

func build_tile(current_tile: Tile) -> void:
	if !current_tile.is_skipped:
		tile_absent_counter = 0
		platform.set_cell(current_tile.tile_pos, 1, current_tile.tile_color, 0)

func update_tile_properties(current_tile: Tile, x_coords: int) -> Tile:
	print("tile absent counter: ", tile_absent_counter)
	if tile_absent_counter == max_tile_gap:
		current_tile.height_changed = false
		current_tile.is_skipped = false
		current_tile.tile_pos = Vector2i(x_coords, current_tile.tile_pos.y)
		current_tile.tile_color = change_tile_color()
		return current_tile
	else:
		if current_tile.is_skipped and tile_absent_counter == 1:
			var res: Array = check_change_tile_height()
			if res[1]:
				if res[0] == "increase":
					current_tile.tile_pos = Vector2i(x_coords, current_tile.tile_pos.y + 1)
				elif res[0] == "decrease":
					current_tile.tile_pos = Vector2i(x_coords, current_tile.tile_pos.y - 1)
				current_tile.is_skipped = false
				return current_tile 
		if check_tile_should_skip():
			current_tile.is_skipped = true
			return current_tile
		else:
			current_tile.height_changed = false
			current_tile.is_skipped = false
			current_tile.tile_pos = Vector2i(x_coords, current_tile.tile_pos.y)
			current_tile.tile_color = change_tile_color()
			return current_tile
	return current_tile
	
func check_tile_should_skip() -> bool:
	if tile_absent_counter < min_tile_gap and tile_absent_counter != 0:
		tile_absent_counter += 1
		return true
	else:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		var skip_tile_weights: PackedFloat32Array = PackedFloat32Array([0.65, 0.35])
		var is_tile_skipped: Array = [true, false]
		if is_tile_skipped[rng.rand_weighted(skip_tile_weights)] == true:
			tile_absent_counter += 1
			return true
		else:
			return false

func change_tile_color() -> Vector2i:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var new_tile_color: Vector2i = atlas_tile_coordinates[rng.rand_weighted(color_weights)]
	adjust_tile_color_weights()
	return new_tile_color
	
func adjust_tile_color_weights() -> void:
	var max_val: float = 0.0

	for weight in color_weights:
		if max_val < weight:
			max_val = weight

	var max_val_idx: int = color_weights.find(max_val)

	for i in range(0, color_weights.size(), 1):
		if i == max_val_idx:
			color_weights[i] -= 0.10
		else:
			color_weights[i] += 0.05

func check_change_tile_height() -> Array:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var height_change_instructions: Array = ["unchanged", "increase", "decrease"]
	var is_height_altered: String = height_change_instructions[rng.rand_weighted(height_weights)]
	
	if is_height_altered == "unchanged":
		return [is_height_altered, false]
	elif is_height_altered == "increase" and max_tile_height < tile_height - 1:
		return [is_height_altered, true]
	elif is_height_altered == "decrease" and min_tile_height > tile_height + 1:
		return [is_height_altered, true]
	else:
		# Add a log here MAYBE
		# Maybe can take away unchange
		# I am entering here!
		print("Never suppose to enter this path")
		return [is_height_altered, false]

func change_tile_height(current_tile: Tile) -> void:
	pass

#func change_tile_height(current_tile: Tile) -> Array:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#var height_change_instructions: Array = ["unchanged", "increase", "decrease"]
	#
	#var is_height_altered: String = height_change_instructions[rng.rand_weighted(height_weights)]
	#
	#if is_height_altered == "unchanged":
		#return [current_tile, false]
	#elif is_height_altered == "increase" and max_tile_height < tile_height - 1:
		#current_tile.tile_pos.y -= 1
		#return [current_tile, true]
	#elif is_height_altered == "decrease" and min_tile_height > tile_height + 1:
		#current_tile.tile_pos.y += 1
		#return [current_tile, true]
	#else:
		#return [current_tile, false]
#extends Node
#class_name PlatformGenerator
#
#@export var platform: Platform
#@export var tile: Tile
#
#var atlas_tile_coordinates: Dictionary = {
	#0: Vector2i(5, 0),
	#1: Vector2i(6, 0),
	#2: Vector2i(7, 0)
#}
#
#var color_weights: PackedFloat32Array = PackedFloat32Array([0.7, 0.15, 0.15])
#var height_weights: PackedFloat32Array = PackedFloat32Array([0.5, 0.25, 0.25])
#
#var max_tile_height: int = -1
#var min_tile_height: int = 10
#var tile_height: int = 9
#var tile_absent_counter: int = 0
#
#func _ready() -> void:
	#generate_platform()
#
#func generate_platform() -> Platform:
	#for pos_x in range(0, 20):
		#build_tile(tile)
		#tile = update_tile_properties(tile, pos_x)
	#return platform
		#
#func build_tile(current_tile: Tile) -> void:
	#if !current_tile.is_skipped:
		#tile_absent_counter = 0can_grab = false
		#platform.set_cell(current_tile.tile_pos, 1, current_tile.tile_color, 0)
#
#func update_tile_properties(current_tile: Tile, x_coords: int) -> Tile:
	#if (tile_absent_counter == 2) and current_tile.is_skipped:
		#current_tile.height_changed = false
		#current_tile.is_skipped = false
		#current_tile.tile_pos = Vector2i(x_coords + 1, current_tile.tile_pos.y)
		#current_tile.tile_color = change_tile_color()
		#return current_tile
	#elif current_tile.height_changed:
		#if current_tile.is_skipped:
			#current_tile.is_skipped = false
			#current_tile.tile_pos = Vector2i(x_coords + 1, current_tile.tile_pos.y)
			#current_tile.tile_color = change_tile_color()
		#else:
			#current_tile.height_changed = false
		#return current_tile
	#else:
		#if !check_tile_should_skip():
			#current_tile.is_skipped = false
			#current_tile.tile_pos = Vector2i(x_coords + 1, current_tile.tile_pos.y)
			#current_tile.tile_color = change_tile_color()
		#else:
			#if change_tile_height(current_tile)[1]:
				#current_tile.height_changed = true
			#current_tile.is_skipped = true
		#return current_tile
#
#func check_tile_should_skip() -> bool:
	#if (tile_absent_counter + 1) < 3:
		#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		#var skip_tile_weights: PackedFloat32Array = PackedFloat32Array([0.65, 0.35])
		#var is_tile_skipped: Array = [true, false]
		#if is_tile_skipped[rng.rand_weighted(skip_tile_weights)] == true:
			#tile_absent_counter += 1
			#return true
		#else:
			#return false
	#else:
		#return false
		
#func change_tile_color() -> Vector2i:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#var new_tile_color: Vector2i = atlas_tile_coordinates[rng.rand_weighted(color_weights)]
	#adjust_tile_color_weights()
	#return new_tile_color
	#
#func adjust_tile_color_weights() -> void:
	#var max_val: float = 0.0
#
	#for weight in color_weights:
		#if max_val < weight:
			#max_val = weight
#
	#var max_val_idx: int = color_weights.find(max_val)
#
	#for i in range(0, color_weights.size(), 1):
		#if i == max_val_idx:
			#color_weights[i] -= 0.10
		#else:
			#color_weights[i] += 0.05
#
#func change_tile_height(current_tile: Tile) -> Array:
	#var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	#var height_change_instructions: Array = ["unchanged", "increase", "decrease"]
	#
	#var is_height_altered: String = height_change_instructions[rng.rand_weighted(height_weights)]
	#
	#if is_height_altered == "unchanged":
		#return [current_tile, false]
	#elif is_height_altered == "increase" and max_tile_height < tile_height - 1:
		#current_tile.tile_pos.y -= 1
		#return [current_tile, true]
	#elif is_height_altered == "decrease" and min_tile_height > tile_height + 1:
		#current_tile.tile_pos.y += 1
		#return [current_tile, true]
	#else:
		#return [current_tile, false]
