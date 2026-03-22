extends RigidBody2D
class_name Projectile


var interactedEntities : Array[StatEntity]

var projectileDamage : float 
@onready var lifetime: Timer = $lifetime
@export var piercing : bool = false
@export var destroyUponWall : bool = true
var entityDetector : Area2D
var collisionMask : int
func _ready() -> void:
	entityDetector = $entityDetector
	lifetime.start()
	for i in range(1,3):
		entityDetector.set_collision_layer_value(i, false)
		entityDetector.set_collision_mask_value(i, false)
	$entityDetector.set_collision_mask_value(collisionMask, true)

func setup(mask : int, initialVelocity : Vector2, damage : int) -> void:
	projectileDamage = damage
	collisionMask = mask
	apply_central_impulse(initialVelocity)

func _physics_process(_delta: float) -> void:
	if linear_velocity.length() > 1.0:
		rotation = linear_velocity.angle()

func _on_entity_detector_body_entered(body: Node2D) -> void:
	if body is StatEntity and not interactedEntities.has(body):
		interactedEntities.push_back(body)
		body.damage(projectileDamage)
		if not piercing:
			call_deferred("queue_free")
func _on_wall_detector_body_entered(_body: Node2D) -> void:
	if destroyUponWall:
		$queueDeletion.start()
	call_deferred("set_freeze_enabled", true)
func _on_lifetime_timeout() -> void:
	$queueDeletion.start()
func _on_queue_deletion_timeout() -> void:
	call_deferred("queue_free")
