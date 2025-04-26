extends Node

signal zone_changed(zone_name: String)

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var transition_player: AudioStreamPlayer = $TransitionPlayer
var current_zone: String = ""
var fade_time: float = 1.0  # 1 second fade duration

# Preload the audio streams
var audio_streams = {
	"tutorial": preload("res://sounds/music/tutorial_drums.mp3"),
	"temple": preload("res://sounds/music/abandoned_temple_ambience.mp3"),
	"ruins": preload("res://sounds/music/ruins_percussion.mp3")
}

# Footstep sounds for different zones
var footstep_sounds = {
	"tutorial": preload("res://sounds/fx/walk_dirt.ogg"),
	"temple": preload("res://sounds/fx/walk_tiles.ogg"),
	"ruins": preload("res://sounds/fx/walk_tiles.ogg")
}

func _ready():
	zone_changed.connect(_on_zone_changed)
	# Start with temple music
	audio_player.stream = audio_streams["tutorial"]
	audio_player.volume_db = 0  # Set to normal volume
	audio_player.play()
	current_zone = "tutorial"
	
func _on_zone_changed(zone_name: String):
	if zone_name == current_zone:
		return
		
	current_zone = zone_name
	
	if zone_name in audio_streams:
		var tween = create_tween()
		
		if audio_player.playing:
			# Keep playing old audio in the main player and fade it out
			tween.parallel().tween_property(audio_player, "volume_db", -80, fade_time)
			
			# Start new audio in transition player
			transition_player.stream = audio_streams[zone_name]
			transition_player.volume_db = -80
			transition_player.play()
			tween.parallel().tween_property(transition_player, "volume_db", 0, fade_time)
			
			# When fade completes, swap the players
			tween.chain().tween_callback(func():
				# Stop old audio
				audio_player.stop()
				# Swap the streams
				audio_player.stream = transition_player.stream
				audio_player.volume_db = 0
				audio_player.play()
				# Reset transition player
				transition_player.stop()
				transition_player.volume_db = -80
			)
		else:
			# If no audio is playing, just start the new one with fade in
			audio_player.stream = audio_streams[zone_name]
			audio_player.volume_db = -80
			audio_player.play()
			tween.tween_property(audio_player, "volume_db", 0, fade_time)
			
		# Update footstep sound if we have one for this zone
		if zone_name in footstep_sounds:
			update_player_footsteps(zone_name)
	else:
		# Fade out when leaving all zones
		var tween = create_tween()
		if audio_player.playing:
			tween.tween_property(audio_player, "volume_db", -80, fade_time)
			tween.tween_callback(func(): audio_player.stop())
		if transition_player.playing:
			tween.parallel().tween_property(transition_player, "volume_db", -80, fade_time)
			tween.tween_callback(func(): transition_player.stop())

func update_player_footsteps(zone_name: String):
	var player = get_tree().get_first_node_in_group("player")
	if player and zone_name in footstep_sounds:
		if player.has_node("WalkSound/Sound"):
			player.get_node("WalkSound/Sound").stream = footstep_sounds[zone_name]
			print("Switched player footsteps to: ", footstep_sounds[zone_name])
			# Set a reasonable volume for footsteps (-5 dB is a good starting point)
			player.get_node("WalkSound/Sound").volume_db = -5
