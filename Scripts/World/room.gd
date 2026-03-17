extends Node2D
##
##	Class representing a room the player can enter and leave via Portals. [br] 
##
class_name Room
#signal PlayerDied

@onready var enemy_manager: Node2D = $EnemyManager
@onready var projectiles: Node2D = $Projectiles
@export var doors: Array[Door] 
@onready var players: Node2D = $Players
var boundaries : Vector4i


func _ready() -> void:
	boundaries = Vector4i(
	$boundaries/topLeft.global_position.x,
	$boundaries/bottomRight.global_position.x,
	$boundaries/topLeft.global_position.y,
	$boundaries/bottomRight.global_position.y)
	for door : Door in doors:
		door.parentRoom = self
		door.playerEnteredDoor.connect(exitRoom)
func exitRoom(player : Player, destinationDoor : Door) -> void:
	player.set_physics_process(false)
	players.remove_child(player)
	player.playerScreen.fadeScreen()
	await player.playerScreen.screen_fade_player.animation_finished
	destinationDoor.parentRoom.enterRoom(player)
	player.global_position = destinationDoor.arrival_pos.global_position
	player.lastSafePos = destinationDoor.arrival_pos.global_position
func enterRoom(player : Player) -> void:
	players.add_child(player)
	player.set_physics_process(true)
	player.setCameraLimits(boundaries)
	player.playerScreen.unfadeScreen()
	await player.playerScreen.screen_fade_player.animation_finished
func softResetRoom() -> void:
	pass
func hardResetRoom() -> void:
	pass
func getPlayers() -> Array[Node]:
	return self.players.get_children()
