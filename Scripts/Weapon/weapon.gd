extends Node2D
class_name Weapon

@export var info : WeaponInformation
var currentCooldDown : float = 0.0
var userTechnique : int = 0

func canUse(userStamina : int) -> bool:
	return not currentCooldDown and info.staminaCost <= userStamina
func use(_direction : Vector2) -> void:
	pass
func setUpWeapon(_user : CharacterBody2D) -> void:
	pass
func applyCooldown() -> void:
	self.visible = false
	currentCooldDown = info.baseCooldown
