extends Node2D
class_name World

@export var start_room: Room 

func playBackgroundMusic() -> void:
	$bgMusic.play()
