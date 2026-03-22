extends Area2D
class_name WeaponHitbox

signal entityEnteredHitbox(entity : StatEntity, multiplier : float)
@export var multiplier : float = 1.0
var entitiesInHitbox : Array[StatEntity]


func _physics_process(_delta: float) -> void:
	for entity : StatEntity in entitiesInHitbox:
		if not entity.isInvincible():
			entityEnteredHitbox.emit(entity, multiplier)
			entitiesInHitbox.erase(entity)


func _on_body_entered(body: Node2D) -> void:
	if body is StatEntity:
		entitiesInHitbox.push_back(body)
		set_physics_process(true)

func deactivateHitbox() -> void:
	self.set_physics_process(false)
	self.monitoring = false
	entitiesInHitbox.clear()
func activateHitbox() -> void:
	self.set_physics_process(true)
	entitiesInHitbox.clear()
	self.monitoring = true

func _on_body_exited(body: Node2D) -> void:
	if body is StatEntity:
		if entitiesInHitbox.has(body):
			entitiesInHitbox.erase(body)
