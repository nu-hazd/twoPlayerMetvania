extends Node2D
class_name WeaponArmory

const weaponCooldownReduction : Curve = preload("res://Resources/Weapon/Scalings/weaponCooldown.tres")
@export var user : StatEntity
@export var weaponSlots : int = 2
var useDirection : Vector2 = Vector2.RIGHT
@export var currentWeapons : Array[Weapon]
signal weaponOnCooldown(num : int, cd : float)
signal updateHUD(weapons :  Array[Weapon])
func initSystem() -> void:
	for child : Weapon in self.get_children():
		currentWeapons.push_back(child)
	updateWeapons()
func _process(delta: float) -> void:
	for weapon : Weapon in currentWeapons:
		weapon.currentCooldDown = max(0, weapon.currentCooldDown - delta)
func useWeapon(weaponNumber : int) -> void:
	if weaponNumber < currentWeapons.size() and weaponNumber >= 0:
		var weaponToUse : Weapon = currentWeapons[weaponNumber]
		if user is Player:
			if weaponToUse.canUse(user.getStat(Player.STATS.CURRENT_STAMINA)):
				user.consumeStamina(weaponToUse.info.staminaCost)
				weaponToUse.applyCooldown(weaponToUse.info.baseCooldown / (1 + weaponCooldownReduction.sample(user.getStat(StatEntity.STATS.TECHNIQUE))))
				weaponOnCooldown.emit(weaponNumber, weaponToUse.currentCooldDown)
				weaponToUse.use(useDirection)
		else:
			weaponToUse.use(useDirection)
func updateWeapons() -> void:
	updateHUD.emit(currentWeapons)
	for weapon : Weapon in currentWeapons:
		if user is Player:
			weapon.userTechnique = user.getStat(Player.STATS.TECHNIQUE)
		elif user is Enemy:
			weapon.userTechnique = user.technique
		weapon.setUpWeapon(user)
