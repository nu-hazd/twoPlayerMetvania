extends Weapon
class_name ThrustingWeapon

##
##	IMPORTANT:
##	All thrusting weapons must configure [member thrust], defining a distance and time, calling deactivate() upun finishing.
@onready var thrust: AnimationPlayer = $thrust
@export var doTipperParticles : bool = true
@onready var tipper_effect: CPUParticles2D = $pivot/displacement/hitboxes/high/tipperEffect
var interactedEntities : Array[StatEntity]

func _ready() -> void:
	for hitbox : WeaponHitbox in $pivot/displacement/hitboxes.get_children():
		hitbox.entityEnteredHitbox.connect(entityEnteredHitbox)
	self.visible = true
	$pivot/displacement/sprite.visible = false


func update(user : StatEntity) -> void:
	super.update(user)
	for hitbox : WeaponHitbox in $pivot/displacement/hitboxes.get_children():
		if user is Player:
			hitbox.set_collision_mask_value(2,true) 
		else:
			hitbox.set_collision_mask_value(1,true) 

func use(direction : Vector2, _user : StatEntity) -> void:
	if direction == Vector2.ZERO:
		if _user is Enemy:
			direction.x = 1
		if _user is Player:
			direction.x = _user.lastDirection
	if not visible:
		visible = true
	$pivot.rotation = atan2(direction.y,direction.x)
	activate()
func activate() -> void:
	interactedEntities.clear()
	$pivot/displacement/sprite.visible = true
	$thrust.play("thrust")
func deactivate() -> void:
	$pivot/displacement/sprite.visible = false
	interactedEntities.clear()
	for hitbox : WeaponHitbox in $pivot/displacement/hitboxes.get_children():
		hitbox.monitoring = false
		hitbox.set_physics_process(false)
		hitbox.entitiesInHitbox.clear()
func becomeDrop() -> void:
	deactivate()
	self.visible = false
func entityEnteredHitbox(entity : StatEntity, hitboxMultiplier : float) -> void:
	if entity not in interactedEntities:
		print(getCalculatedDamge()*hitboxMultiplier)
		entity.damage(floor(getCalculatedDamge()*hitboxMultiplier)) 
		interactedEntities.push_back(entity)
		if hitboxMultiplier > 1.0 and doTipperParticles:
			tipper_effect.global_rotation = $pivot.global_rotation
			tipper_effect.emitting = true
		
