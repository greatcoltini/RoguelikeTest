extends Node

@export var music_player: AudioStreamPlayer
@export var sound_player: AudioStreamPlayer


func _init():
	music_player.stream = preload("res://assets/audio/Ludum Dare 30 - 07.ogg")
	sound_player.stream = preload("res://assets/audio/Modern10.wav")

func _ready():
	pass # Replace with function body.

func play_button_sound():
	#sound_player.play()
	pass

func play_music_sound():
	music_player.play()
