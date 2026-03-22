extends Weapon
class_name SwingWeapon


var interactedEntities : Array[StatEntity]
@export var swingSpeed : float = 0.5

func _ready() -> void:
	for hitbox : WeaponHitbox in $pivot/hitboxes.get_children():
		hitbox.entityEnteredHitbox.connect(entityEnteredHitbox)



func update(user : StatEntity) -> void:
	super.update(user)
	for hitbox : WeaponHitbox in $pivot/hitboxes.get_children():
		if user is Player:
			hitbox.set_collision_mask_value(2,true) 
		else:
			hitbox.set_collision_mask_value(1,true) 

func use(direction : Vector2, _user : StatEntity) -> void:
	if not direction.x:
		if _user is Enemy:
			direction.x = 1
		if _user is Player:
			direction.x = _user.lastDirection
	self.scale.x = sign(direction.x)
	$swing.speed_scale = 1.0 / swingSpeed
	activate()
func activate() -> void:
	interactedEntities.clear()
	self.visible = true
	for hitbox : WeaponHitbox in $pivot/hitboxes.get_children():
		hitbox.activateHitbox()
	$swing.play("swing")
func deactivate() -> void:
	self.visible = false
	interactedEntities.clear()
	for hitbox : WeaponHitbox in $pivot/hitboxes.get_children():
		hitbox.deactivateHitbox()
func becomeDrop() -> void:
	deactivate()
	self.visible = false
func entityEnteredHitbox(entity : StatEntity, hitboxMultiplier : float) -> void:
	if entity not in interactedEntities:
		entity.damage(floor(getCalculatedDamge()*hitboxMultiplier)) 
		interactedEntities.push_back(entity)
