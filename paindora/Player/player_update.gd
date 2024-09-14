extends CharacterBody2D

enum ColorState {RED, BLUE, YELLOW}

@onready var raycast: RayCast2D = $'PlayerRayCast'
@onready var ledge_grabber: RayCast2D = $'LedgeGrabber'
@onready var timer: Timer = $'PlayerTimer'
@onready var coyote_timer: Timer = $'CoyoteTimer'

var gravity: float = 45.0
var fall_gravity: float = 45.0
var gravity_modifier: float = 2
var jump_height: float = 48.0
var apex_duration: float = 0.5
var tween: Tween
var color_state: Vector2i
var current_tile_atlas: Vector2i
var is_grounded: bool
var is_jumping: bool
var is_ledge_grabbed: bool
var coyote_frames: float = 6.0
var coyote: bool = false
var last_floor = false
var jump_timer: float = 0.0

var color_map: Dictionary = {
	"Left": Vector2i(2, 0),
	"Down": Vector2i(3, 0),
	"Right": Vector2i(1, 0)
}

func _ready() -> void:
	color_state = color_map["Left"]
	coyote_timer.wait_time = coyote_frames / 60.0
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		jump_timer = 0.1
		
	if event.is_action_released("ui_accept"):
		gravity *= gravity_modifier
	
	if jump_timer > 0.0 and (is_grounded or coyote):
		velocity.y = - (2 * jump_height / apex_duration)
		gravity = - (velocity.y / apex_duration)
		is_jumping = true

	if event.is_action_pressed("change_color"):
		change_color(event)

func _physics_process(delta: float) -> void:
	if !is_grounded:
		velocity.y += gravity * delta
	velocity = velocity.lerp(velocity, 5.0 * delta)
	is_grounded = raycast.is_colliding()
	is_ledge_grabbed = ledge_grabber.is_colliding()
	move_and_slide()
	if is_grounded:
		is_jumping = false
		jump_timer = 0.0
		check_tile_color(raycast.get_collider(), raycast.get_collider_rid())
	elif !is_grounded and last_floor and !is_jumping:
		coyote = true
		coyote_timer.start()
	last_floor = is_grounded
	jump_timer -= delta
	
func grab_edge() -> void:
	velocity.y -= jump_height

func check_tile_color(tile_map: TileMapLayer, rid: RID) -> void:
	var tile_color: Vector2i = tile_map.get_cell_atlas_coords(tile_map.get_coords_for_body_rid(rid))
	if get_color_state() != tile_color:
		if timer.is_stopped():
			timer.start()
		await timer.timeout
		if get_color_state() != tile_color:
			get_tree().paused = true
    	
func change_color(event: InputEvent) -> void:
	var color_select: String = OS.get_keycode_string(event.physical_keycode)
	color_state = color_map[color_select]
	
func get_color_state() -> Vector2i:
	return color_state
	
func _on_coyote_timer_timeout() -> void:
	coyote = false