extends TileMapLayer
class_name PlatformProceduralGenerator

signal spawn_next_platform

@export var visibility_notifier: VisibleOnScreenNotifier2D

var atlas_tile_coordinates: Dictionary = {
	0: Vector2i(2, 0),
	1: Vector2i(3, 0),
	2: Vector2i(1, 0)
}

var weights: PackedFloat32Array = PackedFloat32Array([0.7, 0.15, 0.15])
var tile_absent_counter: int = 0

var max_tile_height: int = -1
var min_tile_height: int = 10
var tile_height: int = 9

func _ready() -> void:
	visibility_notifier.screen_exited.connect(_on_screen_exit)
	generate_platform()
		
func generate_platform() -> void:
	for i in range(0, 20):
		if tile_absent_counter == 2 or check_skip_tile() == false:
			tile_absent_counter = 0
			set_cell(Vector2i(i, tile_height), 1, generate_tile(), 0)
			adjust_weights()
			build_height()
		else:
			continue

func generate_tile() -> Vector2i:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	return atlas_tile_coordinates[rng.rand_weighted(weights)]
		
func adjust_weights() -> void:
	var max_val: float = 0.0
	
	for weight in weights:
		if max_val < weight:
			max_val = weight
	
	var max_idx: int = weights.find(max_val)
	
	for i in range(0, weights.size(), 1):
		if i == max_idx:
			weights[i] -= 0.10
		else:
			weights[i] += 0.05
			
func check_skip_tile() -> bool:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var skip_tile_weights: PackedFloat32Array = PackedFloat32Array([0.65, 0.35])
	var is_tile_skipped: Array = [true, false]
	if is_tile_skipped[rng.rand_weighted(skip_tile_weights)] == true:
		tile_absent_counter += 1
		return true
	else:
		return false
		
func build_height() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	var height_weights: PackedFloat32Array = PackedFloat32Array([0.5, 0.25, 0.25])
	var height_changed_instructions: Array = ["unchanged", "increase", "decrease"]
	
	var is_height_altered: String = height_changed_instructions[rng.rand_weighted(height_weights)]
	
	if is_height_altered == "unchanged":
		return
	elif is_height_altered == "increase" and max_tile_height < tile_height - 1:
		tile_height -= 1
	elif is_height_altered == "decrease" and min_tile_height > tile_height + 1:
		tile_height += 1
		
func _on_screen_exit() -> void:
	spawn_next_platform.emit()