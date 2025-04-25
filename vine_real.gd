extends Area2D

@onready var marker = $Marker2D
@export var end_position = Vector2()
@export var grabbed = false
var player


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	end_position = marker.end_position
	#if player != null:
		#if player.vine_grabbed:
			#player.position = end_position
			#player.velocity = Vector2.ZERO
			#player.velocity.x = 0
			#player.velocity.y = 0 


#func _on_body_entered(body: Node2D) -> void:
	#print("Player entered the vine!")
	#if body.is_in_group("player") and body.can_grab:
		#player = body
		##$vine_timer.start()
		#player.vine_grabbed = true
		#grabbed = true
		#print(body.name)
		#player.can_grab = false
		#print("Vine grabbed!")




#func _on_body_exited(body: Node2D) -> void:
	#if player == body:
		#grabbed = false
		#player = null
		#print("vine released!")
	#
