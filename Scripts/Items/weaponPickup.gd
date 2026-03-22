extends RigidBody2D
class_name WeaponPickup


var player : Player
var heldWeapon : Weapon 
var attractionForceMagnitude: int = 100
var ignoreOthers : bool = false
func _ready() -> void:
	set_physics_process(false)
	$disablePickup.start()
	$pickupRange.monitoring = false
	$texture.texture = heldWeapon.info.icon
	$eliminate.start()

func setup(weapon : Weapon):
	heldWeapon = weapon
	weapon.becomeDrop()
	
func _physics_process(_delta: float) -> void:
	if player:
		self.apply_central_force(
			(player.global_position - global_position).normalized() * attractionForceMagnitude
		)
func _on_pickup_range_body_entered(body: Node2D) -> void:
	if body is Player and not ignoreOthers:
		ignoreOthers = true
		$pickupRange.set_deferred("monitoring", false)
		$gravitateRange.set_deferred("monitoring",false)
		body.weapon_armory.call_deferred("addWeapon", heldWeapon)
		call_deferred("queue_free")
func _on_gravitate_range_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		set_physics_process(true)

func _on_gravitate_range_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		set_physics_process(false)
func _on_disable_pickup_timeout() -> void:
	$pickupRange.monitoring = true
func _on_eliminate_timeout() -> void:
	$dissappear.play("dissappear")
