extends Area2D
class_name WeaponHitbox

signal entityEnteredHitbox(entity : CharacterBody2D, hitboxID : String)


func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		entityEnteredHitbox.emit(body, self.name)
