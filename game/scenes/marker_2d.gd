extends Marker2D
class_name Vine

var pivot_point:Vector2
@export var end_position = Vector2()
@export var max_arm_length: float = 200.0
var arm_length: float
var angle

@onready var vineArea = $".."

@export var gravity = .4*60
@export var damping = 0.995
var angular_velocity = 0.0
var angular_acceleration = 0.0
var max_angular_acceleration = 0.0006
var max_angle = .9
var min_angle = -.9
@onready var vine_sprite = $"../Sprite2D"
@onready var grab_zone = $"../CollisionShape2D"
@onready var vine_collision = $"../CollisionShape2D"



func set_start_position(start_pos:Vector2, end_pos:Vector2):
	pivot_point = start_pos
	end_position = end_pos
	arm_length = min(Vector2.ZERO.distance_to(end_position - pivot_point), max_arm_length)
	angle = Vector2.ZERO.angle_to(end_position-pivot_point) - deg_to_rad(-90)
	angular_velocity = 0.0
	angular_acceleration = 0.0
func _ready() -> void:
	set_start_position(global_position,end_position)
	# Connect to the parent Area2D's body_entered signal
	vineArea.connect("body_entered", Callable(self, "_on_grab_zone_body_entered"))

func process_velocity(delta:float)->void:
	angular_acceleration = ((-gravity*delta)/arm_length) *sin(angle)
	if angular_acceleration > max_angular_acceleration:
		angular_acceleration = max_angular_acceleration
	angular_velocity += angular_acceleration
	angular_velocity *= damping
	angle += angular_velocity
	if angle > max_angle:
		angle = max_angle
	elif angle < min_angle:
		angle = min_angle
	
	end_position = pivot_point + Vector2(arm_length*sin(angle), arm_length*cos(angle))
	
	var sprite_height = vine_sprite.texture.get_height() 
	
	vine_sprite.global_position = (end_position - sprite_height / 2 * Vector2(sin(angle), cos(angle))) + Vector2(20,-20)
	vine_sprite.rotation = -angle 
	
	vine_collision.global_position = vine_sprite.global_position + Vector2(-20,20)
	vine_collision.rotation = vine_sprite.rotation

func add_angular_velocity(force:float)->void:
	angular_velocity += force

func game_input()->void:
	var dir:float = 0
	if Input.is_action_just_pressed("walk_right"):
		dir +=1
	elif Input.is_action_just_pressed("walk_left"):
		dir -=1
	add_angular_velocity(dir*.02)

func _physics_process(delta: float) -> void:
	if vineArea.grabbed:
		game_input()	
	process_velocity(delta)
	#queue_redraw()
#func _draw() -> void:
	#draw_line(Vector2.ZERO, end_position - pivot_point, Color.WHITE, 1.0, false)
	#draw_circle(end_position-pivot_point, 3.0, Color.RED)
