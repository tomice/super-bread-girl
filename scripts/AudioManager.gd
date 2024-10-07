extends Node

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer 
@export var music_stream: AudioStream

func _ready():
	print("AudioManager is ready")
	audio_player.stream = music_stream
	#audio_player.loop = true  # FIXME: Should be looping music, but this throws an error?
	audio_player.play()

# Adjust volume
func set_volume_db(db: float) -> void:
	audio_player.volume_db = db

# Change music stream
func change_music(new_stream: AudioStream) -> void:
	audio_player.stop()
	audio_player.stream = new_stream
	audio_player.play()
