extends Chest
class_name ItemChest

enum TYPE { COINS, VITALITY, TECHNIQUE, AGILITY }

@export var type : TYPE = TYPE.COINS
@export var droppedItems : Dictionary[ItemInfo,int]

signal spawnItems(pos : Vector2, items :  Dictionary[ItemInfo,int], rigidBodyNode : Node2D)

func _ready() -> void:
	match tier:
		TIER.COMMON:
			origin =  Vector2(16,544)
		TIER.RARE:
			origin = Vector2(176,544)
		TIER.LEGENDARY:
			origin = Vector2(256, 544)
	match type:
		TYPE.COINS:
			origin.y = 544
		TYPE.VITALITY:
			origin.y = 576
		TYPE.TECHNIQUE:
			origin.y = 608
		TYPE.AGILITY:
			origin.y = 640
	$Sprite2D.region_rect.position = origin

func opened() -> void:
	$openDetection.monitoring = false
	spawnItems.emit(self.global_position,droppedItems, rigidBodyNode)


func _on_open_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		$open.play("open")
