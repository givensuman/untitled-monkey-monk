extends Area2D

@export var damage = 1  # Amount of damage to deal to the player

func _ready():
	# Make sure collision is enabled
	monitoring = true
	monitorable = true
	# Connect the body entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	# Check if the colliding body is the player
	if body.is_in_group("player"):
		$HurtSound.play()
		body.respawn()
