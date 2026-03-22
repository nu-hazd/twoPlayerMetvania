extends Resource
class_name WeaponInformation
enum TIER {
	COMMON, RARE, EPIC, LEGENDARY
}
static var damageBonusScale : Array[Curve] = [
	preload("res://Resources/Weapon/Scalings/common.tres"),
	preload("res://Resources/Weapon/Scalings/rare.tres"),
	preload("res://Resources/Weapon/Scalings/epic.tres"),
	preload("res://Resources/Weapon/Scalings/legendary.tres")
]
@export var icon : Texture2D
@export var tier : TIER = TIER.COMMON
@export var baseDamage : int = 5 
@export var staminaCost : int = 3
@export var baseCooldown : float = 2.5
