extends Chest
class_name WeaponChest



@export var droppedWeapon : PackedScene


signal spawnWeapon(weapon : Weapon, pos : Vector2, rigidBodyNode : Node2D)

func _ready() -> void:
	match tier:
		TIER.COMMON:
			origin =  Vector2(16,656)
		TIER.RARE:
			origin =  Vector2(304,656)
		TIER.LEGENDARY:
			origin =  Vector2(448,656)
	$Sprite2D.region_rect.position = origin

func opened() -> void:
	$openDetection.monitoring = false
	spawnWeapon.emit(droppedWeapon.instantiate(),global_position, rigidBodyNode)


func _on_open_detection_body_entered(body: Node2D) -> void:
	if body is Player:
		$open.play("open")
