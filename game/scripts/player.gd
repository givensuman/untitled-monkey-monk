extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

var can_dblJump = false
var button = "res://button.tscn"


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 1.5
	if is_on_floor(): 
		can_dblJump = false
	
	var direction := Input.get_axis("ui_left", "ui_right")
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		if direction:
			if velocity.x > 0 and velocity.y == 0:
				%AnimationPlayer.play("jump_right")
			elif velocity.x < 0 and velocity.y < 0: 
				$AnimationPlayer.play("jump_left")
		can_dblJump = true
		# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and can_dblJump:
		velocity.y = JUMP_VELOCITY
		can_dblJump = false
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		if velocity.x > 0:
			$AnimationPlayer.play("walk_right")
		elif velocity.x < 0:
			$AnimationPlayer.play("walk_left")
	else:
		%AnimationPlayer.play("idle_right")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	
	move_and_slide()
