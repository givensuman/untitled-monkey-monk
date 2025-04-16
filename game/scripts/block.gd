extends RigidBody2D

# Signals for interaction
signal picked_up
signal placed_down

# Properties
var is_picked_up = false
var original_collision_layer
var original_collision_mask
var pickup_offset = Vector2(0, -50)  # Offset when held

func _ready():
	# Store original collision properties
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask

# Called when the player picks up the block
func pick_up(new_parent):
	if is_picked_up:
		return
		
	is_picked_up = true
	emit_signal("picked_up")
	
	# Disable physics while being carried
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
	# Change parent to the player
	var global_pos = global_position
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = new_parent.global_position + pickup_offset
	
# Called when the player places the block
func place_down(pos = null):
	if not is_picked_up:
		return
		
	is_picked_up = false
	emit_signal("placed_down")
	
	# Re-enable physics
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	freeze = false
	
	# Change parent back to the world
	var world = get_tree().get_root().get_node("World") # Adjust path as needed
	var global_pos = global_position
	get_parent().remove_child(self)
	world.add_child(self)
	
	if pos:
		global_position = pos
	
# Update position when carried
func _process(delta):
	if is_picked_up:
		global_position = get_parent().global_position + pickup_offset
		
# Optional: Check if the block can be placed (no collision at target position)
func can_place_at(pos):
	# This is a simple check - you might need more sophisticated logic
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = pos
	query.collision_mask = original_collision_mask
	var result = space_state.intersect_point(query)
	
	return result.size() == 0