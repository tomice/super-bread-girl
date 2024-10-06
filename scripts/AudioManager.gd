extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer  # Reference to the child node
@export var music_stream: AudioStream  # Assign your music file in the editor

func _ready():
	print("AudioManager is ready")
	audio_player.stream = music_stream  # Set the stream from the exported property
	#audio_player.loop = true  # Enable looping
	audio_player.play()  # Start playing the music

# Function to adjust volume
func set_volume_db(db: float) -> void:
	audio_player.volume_db = db

# Function to change the music stream if needed
func change_music(new_stream: AudioStream) -> void:
	audio_player.stop()  # Stop the current music
	audio_player.stream = new_stream  # Change to the new music stream
	audio_player.play()  # Play the new music
