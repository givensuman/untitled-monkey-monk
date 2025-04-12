extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -600.0

const RANDOM_VOLUME_AMOUNT = 5
const RANDOM_VOLUME_TIMEOUT = 0.1

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
		$JumpSound.play()

		can_dblJump = true
	
	if not is_on_floor() and direction:
		if velocity.x > 0:
			%AnimationPlayer.play("jump_right")
		elif velocity.x < 0: 
			%AnimationPlayer.play("jump_left")

	if Input.is_action_just_pressed("ui_accept") and can_dblJump:
		velocity.y = JUMP_VELOCITY
		$JumpSound.play()
		can_dblJump = false
		

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
		
		if is_on_floor() and $WalkSound/Timer.is_stopped():
			$WalkSound/Sound.volume_db = -5 + (RANDOM_VOLUME_AMOUNT * 2 * randf()) - RANDOM_VOLUME_AMOUNT
			$WalkSound/Timer.wait_time = 0.5 + (RANDOM_VOLUME_TIMEOUT * 2 * randf()) - RANDOM_VOLUME_TIMEOUT
			
			$WalkSound/Sound.play()
			$WalkSound/Timer.start()
		
		if velocity.x > 0:
			%AnimationPlayer.play("walk_right")
		elif velocity.x < 0:
			%AnimationPlayer.play("walk_left")
	else:
		%AnimationPlayer.play("idle_right")
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	
	
	move_and_slide()
