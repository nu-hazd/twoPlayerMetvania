extends Marker2D

##
## A helper node that spawns multiple [ItemPickup] or [WeaponPickup] instances with randomized spread,
## speed, and slight positional offsets.
##
## Spawned items are:
## - Instantiated from [member ITEM_SCENE].
## - Temporarily frozen during setup.
## - Added as children of [member rigidBodyNode].
## - Launched using [member RigidBody2D.linear_velocity].
## - Made visible one physics frame later.
##
## This is useful for dropping coins, upgrade items, or other pickups in a burst-like pattern.
class_name RigidBodySpawner


## The packed scene used to instantiate [ItemPickup] objects.
const ITEM_SCENE: PackedScene = preload("res://Scenes/World/Items/itemPickup.tscn")
const WEAPON_PICKUP_SCENE : PackedScene = preload("res://Scenes/World/Items/weaponPickup.tscn")

## The node that will receive spawned [ItemPickup] children.
##
## This should usually be a world or container node capable of holding spawned rigid bodies.
## It must be assigned before [method spawnItems] is called.


##
## Spawns one or more [ItemPickup] instances at a position with randomized launch behavior.
##
## For each [ItemInfo] key in [param itemsToSpawn], this method:
## - Instantiates the corresponding number of [ItemPickup] scenes.
## - Freezes each item during setup.
## - Configures the item through [method ItemPickup.setup].
## - Hides the item initially.
## - Randomizes its launch direction within [param spawnSpread].
## - Randomizes its launch speed using [param spawnSpeedRandomness].
## - Applies a small positional offset around [param pos].
## - Adds the item as a child of [member rigidBodyNode].
## - Unfreezes the item.
## - Assigns its [member RigidBody2D.linear_velocity].
##
## After waiting one physics frame, all spawned items are made visible.
##
## [param pos] The global position where items should be spawned.
## [param itemsToSpawn] A dictionary mapping each [ItemInfo] to the quantity to spawn.
## [param spawnDirection] The base launch direction used before spread randomization.
## [param spawnSpread] The angular spread, in degrees, applied around [param spawnDirection].
## [param spawnSpeed] The base launch speed assigned to spawned items.
## [param spawnSpeedRandomness] The maximum additional random speed added on top of [param spawnSpeed].

func spawnWeapon(
	weaponToSpawn : Weapon,
	pos: Vector2,
	roomRigidBodyNode : Node2D,
	spawnDirection: Vector2 = Vector2.UP,
	spawnSpread: int = 45,
	spawnSpeed: int = 100,
	spawnSpeedRandomness: int = 25
) -> void:
	var weaponPickupScene : WeaponPickup = WEAPON_PICKUP_SCENE.instantiate()
	weaponPickupScene.freeze = true
	weaponPickupScene.setup(weaponToSpawn)
	weaponPickupScene.visible = false
	var onSpawnDirection := spawnDirection.rotated(
		deg_to_rad(randf_range(-spawnSpread, spawnSpread))
	)
	var onSpawnSpeed := spawnSpeed + randi_range(0, spawnSpeedRandomness)
	var offset := Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))
	roomRigidBodyNode.add_child(weaponPickupScene)
	weaponPickupScene.global_position = pos + offset
	weaponPickupScene.freeze = false
	weaponPickupScene.linear_velocity = onSpawnDirection * onSpawnSpeed
	
	await get_tree().physics_frame

	weaponPickupScene.visible = true
		
func spawnItems(
	pos: Vector2,
	itemsToSpawn: Dictionary[ItemInfo, int],
	roomRigidBodyNode : Node2D,
	spawnDirection: Vector2 = Vector2.UP,
	spawnSpread: int = 45,
	spawnSpeed: int = 100,
	spawnSpeedRandomness: int = 25
) -> void:
	var toMakeVisible: Array[ItemPickup] = []

	for itemKey: ItemInfo in itemsToSpawn.keys():
		for i in range(itemsToSpawn[itemKey]):
			var itemScene: ItemPickup = ITEM_SCENE.instantiate()
			itemScene.freeze = true
			itemScene.setup(itemKey)
			itemScene.visible = false

			var onSpawnDirection := spawnDirection.rotated(
				deg_to_rad(randf_range(-spawnSpread, spawnSpread))
			)
			var onSpawnSpeed := spawnSpeed + randi_range(0, spawnSpeedRandomness)
			var offset := Vector2(randf_range(-2.0, 2.0), randf_range(-2.0, 2.0))

			roomRigidBodyNode.add_child(itemScene)
			itemScene.global_position = pos + offset
			itemScene.freeze = false
			itemScene.linear_velocity = onSpawnDirection * onSpawnSpeed
			toMakeVisible.push_back(itemScene)

	await get_tree().physics_frame

	for item: ItemPickup in toMakeVisible:
		item.visible = true

func spawnProjectile(
	projectileToSpawn : Projectile, 
	pos : Vector2, 
	rigidBodyNode : Node2D
	) -> void:
	rigidBodyNode.add_child(projectileToSpawn)
	projectileToSpawn.global_position = pos
	
