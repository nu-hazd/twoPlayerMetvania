extends Enemy
##
## An [Enemy] that patrols horizontally and can pursue a [Player] when detected.
##
## This enemy:
## - Walks left or right while using its wandering-state logic.
## - Uses [member player_detector] to detect a [Player].
## - Can be configured to avoid walking off ledges through [member isKoopa].
## - Damages players that remain inside its contact-damage area.
##
## Whether this enemy turns around at ledges is controlled by [member isKoopa].
class_name WanderingEnemy

## If `true`, this enemy treats ledges as obstacles and turns around instead of walking off them.
##
## If `false`, [member floor_check] is disabled in [method _ready].
@export var isKoopa: bool = true

## The [RayCast2D] used to detect the player in front of the enemy.
@onready var player_detector: RayCast2D = $playerDetector

## Reference to the visible [Sprite2D] used for horizontal facing updates.
@onready var sprite_2d: Sprite2D = $Sprite2D

## The [RayCast2D] used to check whether there is floor ahead of the enemy.
##
## This is disabled when [member isKoopa] is `false`.
@onready var floor_check: RayCast2D = $floorCheck

## The [RayCast2D] used to detect walls in front of the enemy.
@onready var wall_check: RayCast2D = $wallCheck

## The knockback strength applied to a [Player] when damaged through contact.
@export var contactKnockback: int = 0

## Forces the next horizontal movement direction used by wandering-state logic.
##
## Expected values are typically:
## - `-1` for left
## - `1` for right
## - `0` for no forced direction
var forcedNextDirection: int = 0

## Players currently inside this enemy's contact-damage area.
##
## Each player in this array is checked every physics frame and damaged if they are not
## currently invincible.
var inContactRange: Array[Player]

##
## Initializes the wandering enemy.
##
## This method:
## - Calls [method Enemy._ready].
## - Disables [member floor_check] when [member isKoopa] is `false`.
##
func _ready() -> void:
	super._ready()
	if not isKoopa:
		floor_check.enabled = false
	updateStats()

##
## Updates physics behavior for the wandering enemy every physics frame.
##
## This method:
## - Updates the enemy's facing direction through [method updateScale].
## - Applies gravity to [member velocity].
## - Damages all [Player] instances in [member inContactRange] if they are not invincible.
## - Applies contact knockback to damaged players.
## - Advances the enemy state machine through [member state_machine].
##
## Knockback direction is calculated from this enemy toward the player, with the Y
## component reduced to make the launch shallower.
##
## [param delta] The physics-frame delta time in seconds.
##
func _physics_process(delta: float) -> void:
	updateScale()
	velocity += get_gravity() * delta

	for plyr: Player in inContactRange:
		if not plyr.isInvincible():
			plyr.damage(self.getStat(STATS.TECHNIQUE))
			var dir: Vector2 = (plyr.global_position - global_position).normalized()
			dir.y *= 0.33
			if contactKnockback != 0:
				plyr.velocity = dir * contactKnockback

	state_machine.process(delta)

##
## Updates horizontal facing for the enemy and its detection raycasts.
##
## When [member velocity.x] is non-zero, this method flips:
## - [member sprite_2d]
## - [member player_detector]
## - [member wall_check]
## - [member floor_check]
##
## to match the sign of horizontal movement.
##
func updateScale() -> void:
	if velocity.x:
		sprite_2d.scale.x = sign(velocity.x)
		player_detector.scale.x = sign(velocity.x)
		wall_check.scale.x = sign(velocity.x)
		floor_check.scale.x = sign(velocity.x)

##
## Called when a body enters the contact-damage area.
##
## If the body is a [Player], it is added to [member inContactRange].
##
## [param body] The [Node2D] that entered the contact-damage area.
##
func _on_contact_damage_body_entered(body: Node2D) -> void:
	if body is Player:
		inContactRange.push_back(body)

##
## Called when a body exits the contact-damage area.
##
## If the body is a [Player] and is present in [member inContactRange], it is removed.
##
## [param body] The [Node2D] that exited the contact-damage area.
##
func _on_contact_damage_body_exited(body: Node2D) -> void:
	if body is Player and inContactRange.has(body):
		inContactRange.erase(body)
