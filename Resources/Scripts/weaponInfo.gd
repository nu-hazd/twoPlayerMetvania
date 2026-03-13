extends Resource
class_name WeaponInformation
enum TIER {
	COMMON, RARE, EPIC, LEGENDARY
}
var damageBonusScale : Array[Curve] = [
	ResourceLoader.load("res://Resources/Weapon/Scalings/common.tres"),
	ResourceLoader.load("res://Resources/Weapon/Scalings/rare.tres"),
	ResourceLoader.load("res://Resources/Weapon/Scalings/epic.tres"),
	ResourceLoader.load("res://Resources/Weapon/Scalings/legendary.tres")
]
@export var icon : Texture2D
@export var tier : TIER = TIER.COMMON
@export var baseDamage : int = 5 
@export var staminaCost : int = 3
@export var baseCooldown : float = 2.5
