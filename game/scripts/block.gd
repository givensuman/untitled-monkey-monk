extends RigidBody2D

# Signals for interaction
signal picked_up
signal placed_down

# Properties
var is_picked_up = false
var original_collision_layer
var original_collision_mask
var pickup_offset = Vector2(0, -50)  # Offset when held
var grid_size = 64  # Size for grid snapping (based on block size)
var placement_distance = 100  # Distance in front of player to place block
var ground_level = 600  # Default ground level, will be adjusted based on physics
var initial_position: Vector2  # Store initial position for respawn

# References
@onready var outline = $Outline
@onready var placement_preview = $PlacementPreview
@onready var pickup_indicator = $PickupIndicator
@onready var pickup_sound = $PickUpSound
@onready var place_sound = $PlaceDownSound

func _ready():
	# Store original collision properties and position
	original_collision_layer = collision_layer
	original_collision_mask = collision_mask
	initial_position = global_position
	
	# Disable indicators initially
	if outline:
		outline.visible = false
	if placement_preview:
		placement_preview.visible = false
	if pickup_indicator:
		pickup_indicator.visible = false

# Called when the player picks up the block
func pick_up(new_parent):
	if is_picked_up:
		return
	
	# Check if this block has another block on top of it
	if has_block_on_top():
		return
		
	is_picked_up = true
	emit_signal("picked_up")
	
	# Play pickup sound
	if pickup_sound:
		pickup_sound.play()
	
	# Disable physics while being carried
	freeze = true
	collision_layer = 0
	collision_mask = 0
	
	# Make outline visible when picked up
	if outline:
		outline.visible = true
	if placement_preview:
		placement_preview.visible = true
	
	# Change parent to the player
	get_parent().remove_child(self)
	new_parent.add_child(self)
	global_position = new_parent.global_position + pickup_offset

# Called when the player places the block
func place_down():
	if not is_picked_up:
		return
		
	is_picked_up = false
	emit_signal("placed_down")
	
	if place_sound:
		place_sound.play()
	
	# Hide indicators when placed
	if outline:
		outline.visible = false
	if placement_preview:
		placement_preview.visible = false
	
	# Calculate placement position based on player's direction
	var player = get_parent()
	var direction = 1 if player.last_direction == "right" else -1
	var place_pos = player.global_position + Vector2(placement_distance * direction, 0)
	
	# Check for block below and snap if needed
	place_pos = get_snap_position(place_pos)
	
	# Change parent back to the world
	var world = get_tree().get_root().get_node("World")
	get_parent().remove_child(self)
	world.add_child(self)
	
	# Position the block
	global_position = place_pos
	
	# Reset velocity before unfreezing
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Re-enable physics
	freeze = false
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	return true

# Update position when carried and update placement preview
func _process(_delta):
	if is_picked_up:
		global_position = get_parent().global_position + pickup_offset
		update_placement_preview()
	else:
		update_pickup_indicator()

# Get position to snap to, avoiding overlaps with other blocks
func get_snap_position(pos: Vector2) -> Vector2:
	var space_state = get_world_2d().direct_space_state
	
	# First check for direct collisions with other blocks
	var shape = RectangleShape2D.new()
	shape.size = Vector2(grid_size - 2, grid_size - 2)
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = original_collision_mask
	query.exclude = [self]
	
	var results = space_state.intersect_shape(query)
	
	# Check for block collisions and stack if found
	for result in results:
		var collider = result.collider
		if collider.is_in_group("pickable_blocks"):
			# Stack on top of the colliding block
			var stack_pos = Vector2(
				collider.global_position.x,
				collider.global_position.y - grid_size
			)
			
			# Verify the stacked position isn't occupied
			query.transform = Transform2D(0, stack_pos)
			var stack_results = space_state.intersect_shape(query)
			var can_stack = true
			
			for stack_result in stack_results:
				if stack_result.collider.is_in_group("pickable_blocks"):
					can_stack = false
					break
			
			if can_stack:
				return stack_pos
	
	# If no valid stack position found, snap to grid
	return Vector2(round(pos.x / grid_size) * grid_size, round(pos.y / grid_size) * grid_size)

func update_placement_preview():
	if !placement_preview:
		return
		
	# Calculate position in front of player based on direction
	var player = get_parent()
	var direction = 1 if player.last_direction == "right" else -1
	var preview_pos = player.global_position + Vector2(placement_distance * direction, 0)
	
	# Check for block below and snap if needed
	preview_pos = get_snap_position(preview_pos)
	# Raise the preview by 25% of grid size to prevent ground clipping
	placement_preview.global_position = preview_pos - Vector2(9, grid_size)

func update_pickup_indicator():
	if !pickup_indicator:
		return
		
	var player = get_tree().get_root().get_node("World/Player")
	if !player:
		pickup_indicator.visible = false
		return
		
	# Check if player has held_block property and if it has a value
	if "held_block" in player and player.held_block:
		pickup_indicator.visible = false
		return
		
	# Get all blocks and find the closest one
	var blocks = get_tree().get_nodes_in_group("pickable_blocks")
	var pick_direction = 1 if player.last_direction == "right" else -1
	var check_pos = player.global_position + Vector2(pick_direction * 40, 0)
	
	var closest_block = null
	var min_distance = player.interact_range
	
	for block in blocks:
		var distance = block.global_position.distance_to(check_pos)
		if distance < min_distance:
			min_distance = distance
			closest_block = block
	
	# Only show pickup indicator if this is the closest block
	pickup_indicator.visible = (closest_block == self)

# Snap a position to the grid
func snap_to_grid(pos):
	var snapped_x = round(pos.x / grid_size) * grid_size
	# Important: Make sure y position is aligned with the ground
	# Add a tiny offset to ensure blocks sit ON the ground, not clipping through it
	var snapped_y = round(pos.y / grid_size) * grid_size - 1.0
	return Vector2(snapped_x, snapped_y)
		
# Check if the block can be placed at the target position
func can_place_at(pos):
	var space_state = get_world_2d().direct_space_state
	
	# Create a rectangle shape for the query that matches the block's collision shape
	var shape = RectangleShape2D.new()
	shape.size = Vector2(grid_size - 2, grid_size - 2)  # Slightly smaller to allow stacking
	
	# Setup the query parameters
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, pos)
	query.collision_mask = original_collision_mask
	query.exclude = [self]  # Exclude self from collision check
	
	# Check for collisions with other objects
	var result = space_state.intersect_shape(query)
	
	# Filter the results to only consider other blocks for proper stacking
	var has_collision = false
	for collision in result:
		var collider = collision.collider
		if collider.is_in_group("pickable_blocks"):
			# Check if we're trying to stack on top of a block
			var height_diff = abs(pos.y - collider.global_position.y)
			if abs(pos.x - collider.global_position.x) < 5 && height_diff < grid_size + 5:
				has_collision = true
				break
	
	return !has_collision
	
# Check if there's a block on top of this one
func has_block_on_top():
	var space_state = get_world_2d().direct_space_state
	
	# Position to check (slightly above the block)
	var check_pos = global_position - Vector2(0, grid_size)
	
	# Setup the query
	var query = PhysicsPointQueryParameters2D.new()
	query.position = check_pos
	query.collision_mask = original_collision_mask
	query.exclude = [self]
	
	var result = space_state.intersect_point(query)
	
	# Check if any of the colliding objects are blocks
	for collision in result:
		if collision.collider.is_in_group("pickable_blocks"):
			return true
	
	return false

# Add new function to reset block position
func reset_to_initial_position():
	if is_picked_up:
		# If currently being held, remove from player
		get_parent().remove_child(self)
		var world = get_tree().get_root().get_node("World")
		world.add_child(self)
		is_picked_up = false
	
	# Reset physics state
	freeze = false
	collision_layer = original_collision_layer
	collision_mask = original_collision_mask
	
	# Reset position and velocity
	global_position = initial_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0
	
	# Reset visuals
	if outline:
		outline.visible = false
	if placement_preview:
		placement_preview.visible = false
	if pickup_indicator:
		pickup_indicator.visible = false
