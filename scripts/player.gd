extends CharacterBody2D

@export var movement_data : PlayerMovementData
var can_move = true
var air_jump = false
var just_wall_jumped = false
var was_wall_normal = Vector2.ZERO
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var coyote_jump_timer = $CoyoteJumpTimer
@onready var starting_position = global_position
@onready var wall_jump_timer: Timer = $WallJumpTimer

# Main physics
# TODO: Clean this up. A lot of this logic can be grouped better
# I think we only need apply_gravity(), handle_movement(), handle_jump(), and update_animations()
func _physics_process(delta: float) -> void:
	if not can_move:
		return
	apply_gravity(delta)
	handle_wall_jump()
	handle_jump()
	var direction := Input.get_axis("move_left", "move_right")
	handle_acceleration(direction, delta)
	handle_air_acceleration(direction, delta)
	apply_friction(direction, delta)
	apply_air_resistance(direction, delta)
	
	# Capture state before physics engine update
	var was_on_floor = is_on_floor()
	var was_on_wall = is_on_wall_only()
	
	if was_on_wall:
		was_wall_normal = get_wall_normal()
	move_and_slide()
	
	if was_on_floor and not is_on_floor() and velocity.y >= 0:
		coyote_jump_timer.start()
	just_wall_jumped = false
	
	if was_on_wall and not is_on_wall():
		wall_jump_timer.start()
	update_animations(direction)

func apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * movement_data.gravity_scale * delta

func handle_jump():
	if is_on_floor():
		air_jump = true
	
	if is_on_floor() or coyote_jump_timer.time_left > 0.0:
		if Input.is_action_pressed("jump"):
			velocity.y = movement_data.jump_velocity
			coyote_jump_timer.stop() # Prevents additional height during coyote jump
	elif not is_on_floor():
		if Input.is_action_just_released("jump") and velocity.y < movement_data.jump_velocity / 2:
			velocity.y = movement_data.jump_velocity / 2
		
		if Input.is_action_just_pressed("jump") and air_jump and not just_wall_jumped:
			velocity.y = movement_data.jump_velocity * 0.8
			air_jump = false

func handle_wall_jump():
	if not is_on_wall_only() and wall_jump_timer.time_left <= 0.0:
		return

	var wall_normal = get_wall_normal()
	if wall_jump_timer.time_left > 0.0:
		wall_normal = was_wall_normal
	
	if Input.is_action_just_pressed("jump"):
		velocity.x = wall_normal.x * movement_data.speed
		velocity.y = movement_data.jump_velocity
		just_wall_jumped = true

func handle_acceleration(direction, delta):
	if not is_on_floor():
		return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.acceleration * delta)

func handle_air_acceleration(direction, delta):
	if is_on_floor():
		return
	if direction != 0:
		velocity.x = move_toward(velocity.x, movement_data.speed * direction, movement_data.air_acceleration * delta)

func apply_friction(direction, delta):
	if direction == 0 and is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.friction * delta)

func apply_air_resistance(direction, delta):
	if direction == 0 and not is_on_floor():
		velocity.x = move_toward(velocity.x, 0, movement_data.air_resistance)

func update_animations(direction):
	if direction != 0:
		animated_sprite_2d.flip_h = direction < 0
		animated_sprite_2d.play("run")
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		animated_sprite_2d.play("jump")

func set_input_enabled(enabled: bool) -> void:
	can_move = enabled

func _on_hazard_detector_area_entered(area: Area2D) -> void:
	global_position = starting_position
