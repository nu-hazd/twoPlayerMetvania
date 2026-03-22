extends Node2D
##
##	Class representing a room the player can enter and leave via Portals. [br] 
##
class_name Room
#signal PlayerDied


@onready var enemy_manager: Node2D = $EnemyManager
@onready var rigid_bodies : Node2D = $RigidBodies
@onready var rigidBodySpawner: RigidBodySpawner 
@onready var chests: Node2D = $Chests
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
	for chest : Chest in chests.get_children():
		chest.rigidBodyNode = rigid_bodies
		if chest is ItemChest:
			chest.spawnItems.connect(rigidBodySpawner.spawnItems)
		if chest is WeaponChest:
			chest.spawnWeapon.connect(rigidBodySpawner.spawnWeapon)
	for enemy : Enemy in enemy_manager.get_children():
		enemy.rigidBodyNode = rigid_bodies
		enemy.enemyDied.connect(rigidBodySpawner.spawnItems)
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
	player.currentRoomRigidBodyNode = rigid_bodies
	player.set_physics_process(true)
	player.setCameraLimits(boundaries)
	player.playerScreen.unfadeScreen()
	var center : Vector2 = Vector2((boundaries[1]-boundaries[0])/2.0/16.0,(boundaries[3]-boundaries[2])/2.0/16.0)
	player.playerScreen.statPanel.updateCoords(center)
	await player.playerScreen.screen_fade_player.animation_finished
func softResetRoom() -> void:
	pass
func hardResetRoom() -> void:
	pass
func getPlayers() -> Array[Player]:
	var returnVal : Array[Player]
	for player in players.get_children():
		if player is Player:
			returnVal.push_back(player)
	return returnVal
