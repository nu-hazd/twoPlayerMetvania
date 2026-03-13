extends Weapon
class_name MeleeWeapon

var interactedEntities : Array[CharacterBody2D]
@onready var hitboxes : Array = $rotationPivot/hitboxes.get_children()

func _ready() -> void:
	self.visible = false
	for child : WeaponHitbox in hitboxes:
		child.entityEnteredHitbox.connect(onWeaponHitboxContact)
func use(_direction : Vector2) -> void:
	self.scale.x = sign(_direction.x)
	self.visible = true
	$swing.play("attack")
func setUpWeapon(user : CharacterBody2D) -> void:
	var collisionMasks : Array[int] = []
	if user is Player:
		userTechnique = user.getStat(Player.STATS.TECHNIQUE)
		collisionMasks.push_back(2)
	elif user is Enemy:
		collisionMasks.push_back(1)
	else:
		collisionMasks.push_back(1)
		collisionMasks.push_back(2)
	for hitbox : WeaponHitbox in hitboxes:
		for mask : int in collisionMasks:
			hitbox.set_collision_mask_value(mask, true)
func onWeaponHitboxContact(entity, _hitboxID : String) -> void:
	if entity not in interactedEntities:
		if entity is Enemy:
			entity.damage( floor(info.baseDamage * (1 + info.damageBonusScale[info.tier].sample(userTechnique))))
		if entity is Player:
			if not entity.isInvincible():
				entity.damage(floor(info.baseDamage * (1 + info.damageBonusScale[info.tier].sample(userTechnique))))
		interactedEntities.append(entity)
func clearInteractedEntities() -> void:
	interactedEntities.clear()
