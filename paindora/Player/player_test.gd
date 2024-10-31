extends CharacterBody2D
class_name PlayerTest

@onready var raycast: RayCast2D = $'PlayerRayCast'
@onready var ledge_grabber: RayCast2D = $'LedgeGrabber'
@onready var timer: Timer = $'PlayerTimer'
@onready var coyote_timer: Timer = $'CoyoteTimer'
@onready var visible_screen_notifier: VisibleOnScreenNotifier2D = $'VisibleOnScreenNotifier2D'
@onready var player_sprite: Sprite2D = $'PlayerSprite'

@export_category("Jump Settings")
@export var jump_gravity: float = 100.0
@export var jump_height: float = 48.0
@export var apex_duration: float = 0.5
@export var coyote_frames: float = 6.0

var color_map: Dictionary = {
	"Left": [Vector2i(5, 0), Vector4(0.675, 0.196, 0.196, 1.0)],
	"Down": [Vector2i(6, 0), Vector4(0.357, 0.431, 0.882, 1.0)],
	"Right": [Vector2i(7, 0), Vector4(0.984, 0.949, 0.212, 1.0)]
}

var can_coyote: bool = false
var can_grab: bool = true
var is_jumping: bool = false
var is_on_floor_last_frame: bool = false
var is_ledge_grabbed: bool = false
var jump_timer: float
var color_state: Vector2i

func _ready() -> void:
	color_state = color_map["Left"][0]
	player_sprite.material.set_shader_parameter("color", color_map["Left"][1])
	coyote_timer.wait_time = coyote_frames / 60.0
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	visible_screen_notifier.screen_exited.connect(_on_player_screen_exited)

func _input(event: InputEvent) -> void:
	
	if event.is_action_pressed("ui_accept"):
		if is_on_floor() or can_coyote:
			velocity.y = - (2 * jump_height) / apex_duration
			jump_gravity = - (velocity.y / apex_duration)
			is_jumping = true
		
	if event.is_action_released("ui_accept"):
		jump_gravity *= 2
		
	if event.is_action_pressed("change_color"):
		change_color(event)

func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += jump_gravity * delta
	else:
		is_jumping = false
		can_grab = true
	
	move_and_slide()
	
	if is_on_floor() and raycast.is_colliding():
		check_tile_color(raycast.get_collider(), raycast.get_collider_rid())

	if is_on_floor_last_frame and !is_on_floor() and !is_jumping:
		coyote_timer.start()
		can_coyote = true
	
	if ledge_grabber.is_colliding() and !is_on_floor() and can_grab:
		if velocity.y > 0:
			can_grab = false
			velocity.y = - (velocity.y)
	
	is_on_floor_last_frame = is_on_floor()
	
func check_tile_color(tile_map: TileMapLayer, rid: RID) -> void:
	var tile_color: Vector2i = tile_map.get_cell_atlas_coords(tile_map.get_coords_for_body_rid(rid))
	if color_state != tile_color:
		if timer.is_stopped():
			timer.start()
		await timer.timeout
		
		if color_state != tile_color:
			SignalBus.player_died.emit()
	
func change_color(event: InputEvent) -> void:
	var color_select: String = OS.get_keycode_string(event.physical_keycode)
	color_state = color_map[color_select][0]
	player_sprite.material.set_shader_parameter("color", color_map[color_select][1])

func _on_coyote_timer_timeout() -> void:
	can_coyote = false

func _on_player_screen_exited() -> void:
	SignalBus.player_died.emit()
