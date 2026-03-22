extends Node2D
##
##	A asbtract super-class containing methods that inheriting Weapons must implement.
##	
##	A weapon will always be used by a [StatEntity] user. 
class_name Weapon
@export var info : WeaponInformation

var userTechnique : int
var currentCooldown : float = 0.0

func update(_user : StatEntity) -> void:
	userTechnique = _user.getTechnique()
func use(_direction : Vector2, _user : StatEntity) -> void:
	pass

func becomeDrop() -> void:
	pass
func applyCooldown(time : float) -> void:
	currentCooldown = time
func getCalculatedDamge() -> int:
	var baseDamage : int = info.baseDamage
	var userBonusDamage : float = WeaponInformation.damageBonusScale[info.tier].sample(userTechnique)
	return floor(baseDamage * (1 + userBonusDamage))
