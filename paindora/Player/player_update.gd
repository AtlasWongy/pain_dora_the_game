extends CharacterBody2D

enum ColorState {RED, BLUE, YELLOW}

@onready var raycast: RayCast2D = $'PlayerRayCast'
@onready var ledge_grabber: RayCast2D = $'LedgeGrabber'
@onready var timer: Timer = $'PlayerTimer'
@onready var coyote_timer: Timer = $'CoyoteTimer'
@onready var visible_screen_notifier: VisibleOnScreenNotifier2D = $'VisibleOnScreenNotifier2D'
@onready var player_sprite: Sprite2D = $'PlayerSprite'

var gravity: float = 90.0
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
var apex_jump_timer: float = 0.05
var apex_jump_timer_start: bool = false
var tween_duration = 0.5
var initial_rot = 0.0

var color_map: Dictionary = {
	"Left": [Vector2i(2, 0), Vector4i(1.0, 0.0, 0.0, 1.0)],
	"Down": [Vector2i(3, 0), Vector4i(0.0, 0.0, 1.0, 1.0)],
	"Right": [Vector2i(1, 0), Vector4i(1.0, 1.0, 0.0, 1.0)]
}

func _ready() -> void:
	color_state = color_map["Left"][0]
	coyote_timer.wait_time = coyote_frames / 60.0
	coyote_timer.timeout.connect(_on_coyote_timer_timeout)
	visible_screen_notifier.screen_exited.connect(_on_player_screen_exited)
	player_sprite.material.set_shader_parameter("color", color_map["Left"][1])
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		apex_jump_timer_start = true
		initial_rot = rotation
		
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel()
		tween.tween_property(self, "rotation", 1.571, tween_duration * 2).as_relative().from_current()
		tween.tween_property(raycast, "rotation", -1.571, tween_duration * 2).as_relative().from_current()
		
		# # 		if tween:
# # 			tween.kill()
# # 		tween = create_tween()
# # 		tween.set_parallel()
# # 		tween.tween_property(self, "rotation", 1.571, apex_duration * 2).as_relative().from_current()
# # 		tween.tween_property(raycast, "rotation", -1.571, apex_duration * 2).as_relative().from_current()
	
	if event.is_action_released("ui_accept"):
		gravity *= gravity_modifier
		
		# Find first cycle, first quadrant equivilent
		var remaining_rotation = PI/2 - fmod(rotation, 2 * PI)
		
		if tween:
			tween.kill()
		tween = create_tween()
		tween.set_parallel()
		tween.tween_property(self, "rotation", remaining_rotation, (tween_duration / 2) * 1).as_relative()
		tween.tween_property(raycast, "rotation", -remaining_rotation, (tween_duration / 2) * 1).as_relative()
		
	if apex_jump_timer_start and (is_grounded or coyote):
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
	
	# Can test ledge grab later
	# is_ledge_grabbed = ledge_grabber.is_colliding()
	move_and_slide()
	if is_grounded:
		is_jumping = false
		# check_tile_color(raycast.get_collider(), raycast.get_collider_rid())
	#elif !is_grounded and last_floor and !is_jumping:
		#coyote = true
		#coyote_timer.start()
	#last_floor = is_grounded
	
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
	color_state = color_map[color_select][0]
	player_sprite.material.set_shader_parameter("color", color_map[color_select][1])
	
func get_color_state() -> Vector2i:
	return color_state

func evaluate_apex_time(apex_jump_timer: float) -> void:
	if apex_jump_timer > 0:
		print("Short jump, jump height ", 48.0)
		jump_height = 48.0
	else:
		print("Long jump, jump height: ", 60.0)
		jump_height = 60.0
	pass

func _on_coyote_timer_timeout() -> void:
	coyote = false
	
func _on_player_screen_exited() -> void:
	SignalBus.player_died.emit()
