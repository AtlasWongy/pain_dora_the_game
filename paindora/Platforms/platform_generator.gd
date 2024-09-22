extends Node
class_name PlatformGenerator

@export var platform: Platform
@export var tile: Tile

var atlas_tile_coordinates: Dictionary = {
	0: Vector2i(2, 0),
	1: Vector2i(3, 0),
	2: Vector2i(1, 0)
}

var color_weights: PackedFloat32Array = PackedFloat32Array([0.7, 0.15, 0.15])

var max_tile_height: int = -1
var min_tile_height: int = 10
var tile_height: int = 9
var tile_absent_counter: int = 0

func _ready() -> void:
	generate_platform()
# 	Might need to connect off view port signal

func generate_platform() -> void:
	for pos_x in range(0, 5):
		build_tile(tile)
		tile = update_tile_properties(tile, pos_x)
		
func build_tile(current_tile: Tile) -> void:
	if !current_tile.is_skipped:
		tile_absent_counter = 0
		platform.set_cell(current_tile.tile_pos, 0, current_tile.tile_color, 0)

func update_tile_properties(current_tile: Tile, x_coords: int) -> Tile:
	if (tile_absent_counter == 2) and current_tile.is_skipped:
		current_tile.is_skipped = false
		current_tile.tile_pos = Vector2i(x_coords + 1, current_tile.tile_pos.y)
		current_tile.tile_color = change_tile_color()
		return current_tile
	else:
		if !check_tile_should_skip():
			current_tile.is_skipped = false
			current_tile.tile_pos = Vector2i(x_coords + 1, current_tile.tile_pos.y)
			current_tile.tile_color = change_tile_color()
		else:
			current_tile.is_skipped = true
		return current_tile

func check_tile_should_skip() -> bool:
	if (tile_absent_counter + 1) < 3:
		var rng: RandomNumberGenerator = RandomNumberGenerator.new()
		var skip_tile_weights: PackedFloat32Array = PackedFloat32Array([0.65, 0.35])
		var is_tile_skipped: Array = [true, false]
		if is_tile_skipped[rng.rand_weighted(skip_tile_weights)] == true:
			tile_absent_counter += 1
			return true
		else:
			return false
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

func change_tile_height() -> bool:
	return true