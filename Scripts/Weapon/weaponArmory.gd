extends Node2D
class_name WeaponArmory

static var cooldownReductionCurve : Curve = preload("res://Resources/Weapon/Scalings/weaponCooldown.tres")
@export var user : StatEntity
@export var weaponSlots : int = 2
var currentUseDirection : Vector2 = Vector2.RIGHT
var currentWeapons : Array[Weapon]
var ignorePickupTime : float = 2.0
var ignorePickup : float = 0.0


signal spawnProjectile(projectile : Projectile, pos : Vector2, rigBodyNode : Node2D)
signal weaponOnCooldown(cooldownTime : float, index : int)
signal weaponsChanged( newWeapons : Array[Weapon])
signal weaponDropped(weapon : Weapon, pos : Vector2, rigidBodyNode : Node2D)

func setupWeapons() -> void:
	for weapon in get_children():
		if weapon is Weapon:
			addWeapon(weapon)
			weapon.update(user)

func _process(delta: float) -> void:
	ignorePickup = max(0, ignorePickup-delta)
	for weapon : Weapon in currentWeapons:
		weapon.currentCooldown = max(0, weapon.currentCooldown-delta)

func addWeapon(weapon : Weapon) -> void:
	ignorePickup = ignorePickupTime
	if currentWeapons.size() == weaponSlots:
		dropWeapon()
	currentWeapons.push_back(weapon)
	if weapon not in get_children():	
		add_child(weapon)
	weapon.position = Vector2.ZERO
	weapon.update(user)
	if weapon is RangedWeapon:
		weapon.spawnProjectile.connect(rangedWeaponSpawnProjectile)
	weaponsChanged.emit(currentWeapons)

func useWeapon(index : int) -> void:
	if index < 0 or index >= currentWeapons.size():
		push_warning("Attempting to use weapon at index: %s, currentWeapon size is %s" % [index, currentWeapons.size()])
	else:
		var weaponToUse : Weapon = currentWeapons[index]
		if canUse(weaponToUse):
			weaponToUse.use(currentUseDirection,user)
			var cooldown : float = weaponToUse.info.baseCooldown * (1 - cooldownReductionCurve.sample(user.getTechnique()))
			weaponToUse.applyCooldown(cooldown)
			user.consumeStamina(weaponToUse.info.staminaCost)
			weaponOnCooldown.emit(cooldown,index)

func canUse( weapon : Weapon) -> bool:
	return weapon.currentCooldown == 0 and user.getStat(StatEntity.STATS.CURRENT_STAMINA) >= weapon.info.staminaCost
func getWeapons() -> Array[Weapon]:
	return currentWeapons
func dropWeapon() -> void:
	if currentWeapons.size() > 0:
		var weaponToDrop : Weapon = currentWeapons.pop_front()
		self.remove_child(weaponToDrop)
		weaponOnCooldown.emit(0 , 0)
		weaponDropped.emit(weaponToDrop, self.global_position,user.currentRoomRigidBodyNode)
		if weaponToDrop is RangedWeapon:
			weaponToDrop.spawnProjectile.disconnect(rangedWeaponSpawnProjectile)
		weaponsChanged.emit(currentWeapons)

func rangedWeaponSpawnProjectile(projectile : Projectile, pos : Vector2, rigBodyNode : Node2D) -> void:
	spawnProjectile.emit(projectile,pos,rigBodyNode)
