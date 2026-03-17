extends Node
class_name Main

@onready var character_selection: SelectContainer = $characterSelection
@export var startWorld : PackedScene
var playerScreens : Array[PlayerScreen]
var playerReady : int = 0
var saveDataPath : String = "res://Resources/data.tres"
var world2D : World
func _ready() -> void:
	$Display.visible = false
	character_selection.playersAreReady.connect(gameStart)
func gameStart(stats: Array, atlases: Array[AtlasTexture]) -> void:
	$gameWideFade.play("fade")
	await $gameWideFade.animation_finished
	world2D = startWorld.instantiate()
	playerScreens = [$Display/playerScreens.get_child(0),$Display/playerScreens.get_child(1)]
	playerScreens[0].player_viewport.add_child(world2D)
	world2D.playBackgroundMusic()
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
		players[i].setStat(Player.STATS.VITALITY, stats[i][0])
		players[i].setStat(Player.STATS.AGILITY, stats[i][1])
		players[i].setStat(Player.STATS.TECHNIQUE, stats[i][2])
		players[i].setAtlas(atlases[i])
		players[i].statsChanged.emit(players[i].stats)
		players[i].dashUsed.connect(playerScreens[i].statPanel.startRechargeBarCooldown)
	$Display.show()
	character_selection.queue_free()
	$gameWideFade.play_backwards("fade")
