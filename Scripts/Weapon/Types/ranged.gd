extends Weapon
class_name RangedWeapon

@export var loadedProjectile : PackedScene
@export var baseShootPower : int = 75

@onready var shoot: AnimationPlayer = $shoot
signal spawnProjectile(projectile : Projectile, pos : Vector2, node : Node2D)



func update(user : StatEntity) -> void:
	super.update(user)

func use(direction : Vector2, _user : StatEntity) -> void:
	if direction == Vector2.ZERO:
		if _user is Enemy:
			direction.x = 1
		if _user is Player:
			direction.x = _user.lastDirection
	$shoot.play("shoot")
	self.rotation = atan2(direction.y,direction.x)
	var projectileToSpawn : Projectile = loadedProjectile.instantiate()
	projectileToSpawn.rotation = rotation
	var speed : Vector2 = direction * baseShootPower
	var mask : int = 2
	if _user is Enemy:
		mask = 1
	projectileToSpawn.setup(mask,speed, getCalculatedDamge())
	spawnProjectile.emit(projectileToSpawn, $spawnPos.global_position, _user.currentRoomRigidBodyNode)
