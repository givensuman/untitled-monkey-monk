extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0
const FLY_SPEED = 1800

const RANDOM_VOLUME_AMOUNT = 5
const RANDOM_VOLUME_TIMEOUT = 0.1

var spawn_position: Vector2
var button = "res://button.tscn"
var is_flying = false

var last_direction = "right"
var held_block: Node = null
var interact_range = 100.0  # How far the player can reach to grab blocks

var block_scene = preload("res://game/scenes/block.tscn")
var vine_grabbed = false
var vine = null
var can_grab = true
var gorilla_unlocked = false
var spider_unlocked = false
var jetpack_unlocked = false

var last_checkpoint: Node = null
# Reference to the world node for block placement
var world_node

func _ready():
	# Try to find the world node
	world_node = get_tree().get_root().get_node("World")
	# Add player group to both the player and its area
	add_to_group("player")
	$PlayerArea.add_to_group("player")
	# Set initial footstep sound
	$Sounds/WalkSound/Sound.stream = preload("res://sounds/fx/walk_dirt.ogg")
	# Store initial spawn position
	spawn_position = global_position
	# Connect area entered signal for spike detection
	$PlayerArea.area_entered.connect(_on_player_area_entered)
	#hide labels
	$"../gorilla_statue/gorilla_label2".hide()
	$"../jetpack_statue/jetpack_label".hide()
	# Set initial checkpoint
	last_checkpoint = get_tree().get_root().get_node("World/Tutorial/Checkpoint")

# Called when the gorilla ability is unlocked
func _on_gorilla_ability_unlocked() -> void:
	print("gorilla unlocked!")
	gorilla_unlocked = true

func respawn():
	# Drop any held block first
	if held_block:
		held_block.place_down()
		held_block = null
	
	# Reset all blocks in the scene
	var blocks = get_tree().get_nodes_in_group("pickable_blocks")
	for block in blocks:
		block.reset_to_initial_position()
	
	# Reset player position and velocity
	global_position = spawn_position
	velocity = Vector2.ZERO

func get_last_checkpoint():
	return last_checkpoint

func update_checkpoint(checkpoint: Node) -> bool:
	if checkpoint != last_checkpoint:
		last_checkpoint = checkpoint
		spawn_position = checkpoint.global_position
		return true
	return false

func _get_gravity() -> Vector2:
	return Vector2(0, 980)

func _physics_process(delta: float) -> void:
			#VINE CODE
	var vine_release = false
	if vine_grabbed:
		%AnimationPlayer.play("vine_swinging")
		position = vine.end_position  # Now we can access `end_position` properly
		velocity = Vector2.ZERO
		velocity.x = 0
		velocity.y = 0 
		if Input.is_action_just_pressed("ui_accept"):
			$Sounds/Vine/Swing.play()
			vine.grabbed = false
			vine_grabbed = false
			vine = null
			$vine_timer.start()
			vine_release = true
			velocity.y = JUMP_VELOCITY
			return
		else:
			velocity = Vector2.ZERO
	# Add the gravity.
	if not is_on_floor():
		velocity += _get_gravity() * delta * 1.5
	
	var direction := Input.get_axis("walk_left", "walk_right")
	
	if not is_on_floor() and Input.is_action_pressed("ui_accept") and jetpack_unlocked:
		is_flying = true
		velocity.y = lerp(velocity.y, 0.0, 0.1)
		velocity.y -= FLY_SPEED * delta
	else:
		is_flying = false
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and (is_on_floor() or vine_release):
		velocity.y = JUMP_VELOCITY
		$Sounds/JumpSound.play()

	if not is_on_floor() and Input.is_action_pressed("ui_accept") and jetpack_unlocked:
		is_flying = true
		velocity.y = lerp(velocity.y, 0.0, 0.1)
		velocity.y -= FLY_SPEED * delta
	else:
		is_flying = false
		
	# Get the input direction and handle the movement/deceleration.
	if direction:
		velocity.x = direction * SPEED
		
		if is_on_floor() and $Sounds/WalkSound/Timer.is_stopped():
			$Sounds/WalkSound/Sound.play()
			$Sounds/WalkSound/Timer.start()
	
	# Handle animations based on state and movement
	if held_block:
		velocity.x = direction * SPEED * .5
		if direction != 0:
			last_direction = "right" if direction > 0 else "left"
			%AnimationPlayer.play("lift_walk_" + last_direction)
		else:
			%AnimationPlayer.stop()
			%AnimationPlayer.play("lift_walk_" + last_direction)
			%AnimationPlayer.pause()
	else:
		velocity.x = direction * SPEED
		if direction != 0 and is_on_floor():
			last_direction = "right" if direction > 0 else "left"
			%AnimationPlayer.play("walk_" + last_direction)
		elif not is_on_floor():
			if velocity.x > 0 and %AnimationPlayer.assigned_animation != "jump_right":
				%AnimationPlayer.play("jump_right")
			elif velocity.x < 0 and %AnimationPlayer.assigned_animation != "jump_left": 
				%AnimationPlayer.play("jump_left")
		elif is_on_floor():
			%AnimationPlayer.play("idle_" + last_direction)
	
	if Input.is_action_just_pressed("ui_focus_next") and gorilla_unlocked:
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
	
	# Place the block (placement position is now handled in block.gd)
	held_block.place_down()
	held_block = null

# Spawn a new block (for testing or adding blocks to the world)
func spawn_block(block_position):
	if world_node:
		var new_block = block_scene.instantiate()
		world_node.add_child(new_block)
		new_block.global_position = block_position
		
#func _on_grab_zone_area_entered(area: Area2D) -> void:
	#if area.is_in_group("vine") and can_grab:
		#vine_grabbed = true
		#vine = area
		#can_grab = false
		#print("Vine!")


func _on_vine_timer_timeout() -> void:
	can_grab = true

func _on_player_area_entered(area: Area2D) -> void:
	if area.get_parent().name == "Spikes":
		respawn()


func _on_grab_area_area_entered(area: Area2D) -> void:
	print("Player entered the vine!")
	if area.is_in_group("vine") and can_grab and spider_unlocked:
		$vine_timer.start()
		vine_grabbed = true
		vine = area
		can_grab = false
		vine.grabbed = true
		$Sounds/Vine/Grab.play()
		print("Vine grabbed")


func _on_gorilla_statue_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("gorilla entered!")
		gorilla_unlocked = true
		$"../gorilla_statue/gorilla_label2".show()
	


func _on_jetpack_statue_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("jetpack entered!")
		jetpack_unlocked = true
		$"../jetpack_statue/jetpack_label".show()


func _on_spider_statue_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("spider entered!")
		spider_unlocked = true
		$"../spider_statue/spider_label".show()
