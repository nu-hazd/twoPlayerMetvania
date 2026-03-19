extends Node2D
class_name World

@export var start_room: Room 


func _ready() -> void:
	var players : Array[Player] = start_room.getPlayers() as Array[Player]
	for room : Room in $Rooms.get_children():
		for enemy : Enemy in room.enemy_manager.get_children():
			enemy.playerReferences = players

func playBackgroundMusic() -> void:
	$bgMusic.play()
