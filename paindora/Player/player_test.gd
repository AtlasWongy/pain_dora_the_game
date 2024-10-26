extends CharacterBody2D
class_name PlayerTest

@onready var raycast: RayCast2D = $'PlayerRayCast'
@onready var ledge_grabber: RayCast2D = $'LedgeGrabber'
@onready var timer: Timer = $'PlayerTimer'
@onready var coyote_timer: Timer = $'CoyoteTimer'
@onready var visible_screen_notifier: VisibleOnScreenNotifier2D = $'VisibleOnScreenNotifier2D'
@onready var player_sprite: Sprite2D = $'PlayerSprite'

var color_map: Dictionary = {
	"Left": [Vector2i(2, 0), Vector4i(1.0, 0.0, 0.0, 1.0)],
	"Down": [Vector2i(3, 0), Vector4i(0.0, 0.0, 1.0, 1.0)],
	"Right": [Vector2i(1, 0), Vector4i(1.0, 1.0, 0.0, 1.0)]
}

var speed: float = 50.0
var acceleration: float = 100.0
var direction: float
var target_velocity: Vector2
var fall_gravity: float = 100.0
var jump_gravity: float = fall_gravity
var jump_height: float = 48.0
var apex_duration: float = 0.5
var color_state: Vector2i
var is_grounded: bool

func _ready() -> void:
	color_state = color_map["Left"][0]
	player_sprite.material.set_shader_parameter("color", color_map["Left"][1])
	visible_screen_notifier.screen_exited.connect(_on_player_screen_exited)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		velocity.y = - (2 * jump_height) / apex_duration
		jump_gravity = - (velocity.y / apex_duration)
			
	if event.is_action_released("ui_accept"):
		pass
		
	if event.is_action_pressed("change_color"):
		change_color(event)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += jump_gravity * delta
	#else:
		#print("Implement fall gravity here")
	
	direction = Input.get_axis("movement_left", "movement_right")
	var target_vel = direction * speed
	velocity.x = move_toward(velocity.x, target_vel, acceleration)
	
	move_and_slide()
	
	if is_on_floor() and raycast.is_colliding():
		check_tile_color(raycast.get_collider(), raycast.get_collider_rid())
	
func check_tile_color(tile_map: TileMapLayer, rid: RID) -> void:
	var tile_color: Vector2i = tile_map.get_cell_atlas_coords(tile_map.get_coords_for_body_rid(rid))
	if color_state != tile_color:
		if timer.is_stopped():
			timer.start()
		await timer.timeout
		if color_state != tile_color:
			print("Can send death signal")
	
func change_color(event: InputEvent):
	var color_select: String = OS.get_keycode_string(event.physical_keycode)
	color_state = color_map[color_select][0]
	player_sprite.material.set_shader_parameter("color", color_map[color_select][1])
	
func _on_player_screen_exited():
	SignalBus.player_died.emit()
