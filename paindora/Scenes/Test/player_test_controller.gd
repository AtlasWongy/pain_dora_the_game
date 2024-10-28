extends Node2D
class_name PlayerTestController

@onready var player: CharacterBody2D = $'Player'

@export_category("Movement Configurations")
@export var speed: float = 50.0
@export var acceleration: float = 100.0

var direction: float

func _physics_process(delta: float) -> void:
	direction = Input.get_axis("movement_left", "movement_right")

	player.velocity.x = move_toward(
		player.velocity.x,
		direction * speed,
		acceleration
	)
