extends Marker2D
class_name ItemSpawner

const ITEM_SCENE: PackedScene = preload("res://Scenes/World/Items/itemPickup.tscn")
var rigidBodyNode : Node2D
func spawnItems(pos : Vector2, itemsToSpawn : Dictionary[ItemInfo,int], spawnDirection : Vector2 = Vector2.UP, spawnSpread : int = 45, spawnSpeed : int = 100, spawnSpeedRandomness : int = 25) -> void:
	var toMakeVisible : Array[ItemPickup] = []
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
			rigidBodyNode.add_child(itemScene)
			itemScene.global_position = pos + offset
			itemScene.freeze = false
			itemScene.linear_velocity = onSpawnDirection * onSpawnSpeed
			toMakeVisible.push_back(itemScene)
	await get_tree().physics_frame
	for item : ItemPickup in toMakeVisible:
		item.visible = true
	
