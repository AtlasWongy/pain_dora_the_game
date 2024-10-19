extends Node2D
class_name PlatformHandler

@export var platform_generator: PackedScene

@onready var initial_platform: Platform = $'../PlatformHandler/InitialPlatform'

var current_platform: Platform
var next_platform: Platform
var platform_movement_speed: float = -50.0

func _ready() -> void:
	current_platform = initial_platform
	current_platform.spawn_next_platform.connect(_on_spawn_next_platform)
	next_platform = spawn_platform()
	
func _physics_process(delta: float) -> void:
	current_platform.global_position.x += platform_movement_speed * delta
	next_platform.global_position.x += platform_movement_speed * delta
	
func spawn_platform() -> Platform:
	next_platform = platform_generator.instantiate().generate_platform()
	next_platform.reparent(self)
	next_platform.global_position = Vector2(320.0, 0.0)
	return next_platform
	
func _on_spawn_next_platform() -> void:
	current_platform.spawn_next_platform.disconnect(_on_spawn_next_platform)
	current_platform.queue_free()
	current_platform = next_platform
	current_platform.spawn_next_platform.connect(_on_spawn_next_platform)
	next_platform = spawn_platform()
	
