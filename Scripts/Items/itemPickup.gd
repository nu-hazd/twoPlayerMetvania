extends RigidBody2D

##
## A world item pickup that can be attracted toward a nearby [Player] and grants a reward
## when collected.
##
## This class supports multiple pickup types through [enum TYPES], including:
## - Coin rewards of different sizes.
## - Attribute-increase pickups for vitality, agility, and technique.
##
## When a [Player] enters the gravitation area, the pickup begins applying force toward
## the player. When a [Player] enters the pickup area, the reward is granted and the
## pickup removes itself from the scene.
class_name ItemPickup


## The [Player] currently attracting or collecting this pickup.
##
## This is assigned when a player enters the gravitation or pickup ranges.
var player: Player

## The type of reward represented by this pickup.
var type: TYPES

## The magnitude of the attraction force applied toward [member player] while the player
## is inside the gravitation range.
var attractionForceMagnitude: int = 100

##
## Enumerates all pickup types supported by this item.
##
## Coin pickups:
## - [constant TYPES.S_COIN]
## - [constant TYPES.M_COIN]
## - [constant TYPES.L_COIN]
## - [constant TYPES.XL_COIN]
##
## Attribute pickups:
## - [constant TYPES.VIT_UP]
## - [constant TYPES.AGI_UP]
## - [constant TYPES.TEC_UP]
##
enum TYPES {
	S_COIN, M_COIN, L_COIN, XL_COIN,
	VIT_UP, AGI_UP, TEC_UP,
}

##
## Initializes the pickup by disabling physics processing until attraction is needed.
##
func _ready() -> void:
	set_physics_process(false)
	$eliminate.start()

##
## Configures this pickup from an [ItemInfo] resource.
##
## This method:
## - Temporarily disables pickup monitoring on `$pickupRange`.
## - Sets the displayed sprite region from [param info.coords].
## - Sets this rigid body's [member mass].
## - Sets the pickup range scale from [param info.scale].
## - Assigns the pickup [member type].
## - Plays the appropriate animation depending on whether the pickup is a coin or an
##   attribute-up item.
##
## [param info] The [ItemInfo] resource containing setup data for this pickup.
##
func setup(info: ItemInfo):
	$pickupRange.monitoring = false
	$pickupRange/sprite.region_rect.position = info.coords
	self.mass = info.mass
	$pickupRange.scale = info.scale
	type = info.type

	if int(type) <= 3:
		$anims.play("coins")
	else:
		$anims.play("ups")

##
## Applies attraction force toward the current [member player] while physics processing
## is enabled.
##
## The force direction is calculated from this pickup's [member global_position] toward
## the player's [member Node2D.global_position], normalized and scaled by
## [member attractionForceMagnitude].
##
## [param _delta] The physics-frame delta time in seconds.
##
func _physics_process(_delta: float) -> void:
	if player:
		self.apply_central_force(
			(player.global_position - global_position).normalized() * attractionForceMagnitude
		)

##
## Called when a body enters the pickup range.
##
## If the entering body is a [Player], this method:
## - Stops physics processing.
## - Assigns [member player].
## - Grants the reward associated with [member type].
## - Removes the pickup from the scene using [method Node.queue_free].
##
## Coin rewards:
## - [constant TYPES.S_COIN] gives `1`
## - [constant TYPES.M_COIN] gives `5`
## - [constant TYPES.L_COIN] gives `25`
## - [constant TYPES.XL_COIN] gives `100`
##
## Attribute rewards:
## - [constant TYPES.VIT_UP] increases [constant Player.STATS.VITALITY]
## - [constant TYPES.AGI_UP] increases [constant Player.STATS.AGILITY]
## - [constant TYPES.TEC_UP] increases [constant Player.STATS.TECHNIQUE]
##
## [param body] The [Node2D] that entered the pickup range.
##
func _on_pickup_range_body_entered(body: Node2D) -> void:
	if body is Player:
		set_physics_process(false)
		player = body

		match type:
			TYPES.S_COIN:
				player.giveCoins(1)
			TYPES.M_COIN:
				player.giveCoins(5)
			TYPES.L_COIN:
				player.giveCoins(25)
			TYPES.XL_COIN:
				player.giveCoins(100)
			TYPES.VIT_UP:
				player.improveAttribute(Player.STATS.VITALITY, 1)
			TYPES.AGI_UP:
				player.improveAttribute(Player.STATS.AGILITY, 1)
			TYPES.TEC_UP:
				player.improveAttribute(Player.STATS.TECHNIQUE, 1)

		queue_free()

##
## Called when a body enters the gravitation range.
##
## If the entering body is a [Player] and this pickup is not already assigned to one,
## this method stores the player reference and enables physics processing so attraction
## force begins being applied.
##
## [param body] The [Node2D] that entered the gravitation range.
##
func _on_gravitate_range_body_entered(body: Node2D) -> void:
	if body is Player and not player:
		player = body
		set_physics_process(true)

##
## Called when a body exits the gravitation range.
##
## If the exiting body is a [Player], this method clears [member player] and disables
## physics processing so attraction force stops being applied.
##
## [param body] The [Node2D] that exited the gravitation range.
##
func _on_gravitate_range_body_exited(body: Node2D) -> void:
	if body is Player:
		player = null
		set_physics_process(false)

##
## Called when the pickup-disable timer times out.
##
## This re-enables monitoring on `$pickupRange`, allowing the pickup to be collected.
##
func _on_disable_pickup_timeout() -> void:
	$pickupRange.monitoring = true


func _on_eliminate_timeout() -> void:
	$dissappear.play("dissappear")
