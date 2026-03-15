extends Node
class_name Main

@export var startWorld : PackedScene
var playerScreens : Array[PlayerScreen]

func _ready() -> void:
	var world2D : World = startWorld.instantiate()
	playerScreens = [$Display/playerScreens.get_child(0),$Display/playerScreens.get_child(1)]
	playerScreens[0].player_viewport.add_child(world2D)
	playerScreens[1].player_viewport.world_2d = playerScreens[0].player_viewport.world_2d
	var players : Array[Node] = world2D.start_room.getPlayers()
	for p in players:
		if p is not Player:
			push_error("Non player in start room players node.")
	for i in range(2):
		players[i].remote_transform_2d.remote_path = playerScreens[i].player_cam.get_path()
		players[i].statsChanged.connect(playerScreens[i].statPanel.updateStatPanel)
		players[i].weapon_armory.weaponOnCooldown.connect(playerScreens[i].statPanel.startWeaponCooldown)
		players[i].weapon_armory.updateHUD.connect(playerScreens[i].statPanel.updateWeaponHUD)
		players[i].playerScreen = playerScreens[i]
		players[i].setCameraLimits(world2D.start_room.boundaries)
		players[i].weapon_armory.updateWeapons()
		players[i].statsChanged.emit(players[i].stats)
