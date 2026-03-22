extends Node2D
class_name World

@export var start_room: Room 
@export var rigid_body_spawner: RigidBodySpawner 



func _enter_tree() -> void:
	for room : Room in $Rooms.get_children():
		room.rigidBodySpawner = rigid_body_spawner
func _ready() -> void:
	var players : Array[Player] = start_room.getPlayers() as Array[Player]
	for player in players:
		player.weapon_armory.weaponDropped.connect(rigid_body_spawner.spawnWeapon)
		player.weapon_armory.spawnProjectile.connect(rigid_body_spawner.spawnProjectile)
		player.currentRoomRigidBodyNode =  start_room.rigid_bodies
	for room : Room in $Rooms.get_children():
		for enemy : Enemy in room.enemy_manager.get_children():
			enemy.playerReferences = players
			enemy.weapon_armory.weaponDropped.connect(rigid_body_spawner.spawnWeapon)
			enemy.weapon_armory.spawnProjectile.connect(rigid_body_spawner.spawnProjectile)
func playBackgroundMusic() -> void:
	$bgMusic.play()
