extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

const RANDOM_VOLUME_AMOUNT = 5
const RANDOM_VOLUME_TIMEOUT = 0.1

var can_dblJump = false
var button = "res://button.tscn"

var last_direction = "right"
var held_block = null
var interact_range = 100.0  # How far the player can reach to grab blocks
var block_scene = preload("res://game/scenes/block.tscn")
var vine_grabbed = false
var vine = null
var can_grab = true

# Reference to the world node for block placement
var world_node

func _ready():
	# Try to find the world node
	world_node = get_tree().get_root().get_node("World")
	# Add player group to both the player and its area
	add_to_group("player")
	$PlayerArea.add_to_group("player")
	# Set initial footstep sound
	$WalkSound/Sound.stream = preload("res://sounds/fx/walk_dirt.ogg")

func _get_gravity() -> Vector2:
	return Vector2(0, 980)

func _physics_process(delta: float) -> void:
			#VINE CODE
	var vine_release = false
	if vine_grabbed:
		global_position = vine.global_position
		if Input.is_action_just_pressed("ui_accept"):
			vine_grabbed = false
			vine = null
			$GrabZone/VineTimer.start()
			vine_release = true
		else:
			return
	# Add the gravity.
	if not is_on_floor():
		velocity += _get_gravity() * delta * 1.5
	if is_on_floor(): 
		can_dblJump = false
	
	var direction := Input.get_axis("walk_left", "walk_right")
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or vine_release):
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()

		can_dblJump = true
	
	if not is_on_floor():
		if velocity.x > 0 and %AnimationPlayer.assigned_animation != "jump_right":
			%AnimationPlayer.play("jump_right")
		elif velocity.x < 0: 
			%AnimationPlayer.play("jump_left")

	if Input.is_action_just_pressed("ui_accept") and can_dblJump:
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
		can_dblJump = false
		
	# Get the input direction and handle the movement/deceleration.
	if direction:
		velocity.x = direction * SPEED
		
		if is_on_floor() and $WalkSound/Timer.is_stopped():
			$WalkSound/Sound.play()
			$WalkSound/Timer.start()
		
		if velocity.x > 0 and is_on_floor():
			%AnimationPlayer.play("walk_right")
			last_direction = "right"
		elif velocity.x < 0 and is_on_floor():
			%AnimationPlayer.play("walk_left")
			last_direction = "left"
	else:
		if last_direction == "right":
			%AnimationPlayer.play("idle_right")
		else:
			%AnimationPlayer.play("idle_left")
		velocity.x = move_toward(velocity.x, 0, SPEED)
	if held_block:
		velocity.x = direction * SPEED * .5
	else:
		velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed("ui_focus_next"):
		if held_block:
			place_block()
		else:
			try_pick_up_block()
	
	move_and_slide()

# Try to pick up a nearby block
func try_pick_up_block():
	# Define the area to check for blocks
	var pick_direction = 1 if last_direction == "right" else -1
	var check_pos = global_position + Vector2(pick_direction * 40, 0)
	
	# Find blocks in the scene
	var blocks = get_tree().get_nodes_in_group("pickable_blocks")
	
	# Find the closest block within range
	var closest_block = null
	var min_distance = interact_range
	
	for block in blocks:
		var distance = block.global_position.distance_to(check_pos)
		if distance < min_distance:
			min_distance = distance
			closest_block = block
	
	# Try to pick up the closest block
	if closest_block:
		held_block = closest_block
		held_block.pick_up(self)

# Place the currently held block
func place_block():
	if not held_block:
		return
	
	# Calculate placement position 
	var place_direction = 1 if last_direction == "right" else -1
	var place_pos = global_position + Vector2(place_direction * 60, 40)
	
	# Place the block
	held_block.place_down(place_pos)
	held_block = null

# Spawn a new block (for testing or adding blocks to the world)
func spawn_block(position):
	if world_node:
		var new_block = block_scene.instantiate()
		world_node.add_child(new_block)
		new_block.global_position = position
		
func _on_grab_zone_area_entered(area: Area2D) -> void:
	if area.is_in_group("vine") and can_grab:
		vine_grabbed = true
		vine = area
		can_grab = false
		print("Vine!")


func _on_vine_timer_timeout() -> void:
	can_grab = true
