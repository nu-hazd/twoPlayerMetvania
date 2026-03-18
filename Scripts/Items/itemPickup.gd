extends RigidBody2D
class_name ItemPickup
var player : Player
var type : TYPES
var attractionForceMagnitude : int = 100
enum TYPES {
	S_COIN, M_COIN, L_COIN, XL_COIN,
	VIT_UP, AGI_UP, TEC_UP,
}

func _ready() -> void:
	set_physics_process(false)
func setup(info: ItemInfo):
	$pickupRange/sprite.region_rect.position = info.coords
	self.mass = info.mass
	print($pickupRange/sprite.region_rect)
	$pickupRange.scale = info.scale
	type = info.type
	if int(type) <= 3:
		$anims.play("coins")
	else:
		$anims.play("ups")
func _physics_process(_delta: float) -> void:
	if player:
		print(position)
		self.apply_central_force(
			(player.global_position - global_position).normalized() * attractionForceMagnitude)

func _on_pickup_range_body_entered(body: Node2D) -> void:
	if body is Player:
		set_physics_process(false)
		player = body
		match type:
			TYPES.S_COIN:
				player.giveCoins(1)
			TYPES.M_COIN:
				player.giveCoins(5)
			TYPES.L_COIN:
				player.giveCoins(25)
			TYPES.XL_COIN:
				player.giveCoins(100)
			TYPES.VIT_UP:
				player.improveAttribute(Player.STATS.VITALITY,1)
			TYPES.AGI_UP:
				player.improveAttribute(Player.STATS.AGILITY,1)
			TYPES.TEC_UP:
				player.improveAttribute(Player.STATS.TECHNIQUE,1)
		queue_free()
			
func _on_gravitate_range_body_entered(body: Node2D) -> void:
	if body is Player and not player:
		player = body
		set_physics_process(true)
		
func _on_gravitate_range_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		set_physics_process(false)
