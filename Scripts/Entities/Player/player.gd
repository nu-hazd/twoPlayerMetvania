extends StatEntity

## A [StatEntity] controlled through a [PlayerControls] resource.
##
## The player contains a [WeaponArmory] for weapon usage and a [StateMachine] for
## movement and action states. It also manages cooldowns, buffered inputs, camera
## behavior, and various mobility checks such as dashing, wall jumping, and double jumping.
class_name Player

## Emitted when the player uses a dash.
##
## [param cd] The dash cooldown duration applied after the dash is used.
@warning_ignore("unused_signal")
signal dashUsed(cd: float)

## A [PlayerControls] resource containing the input actions used by this player.
@export var playerControls: PlayerControls

## Node responsible for forwarding this player's transform, usually for camera follow behavior.
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D

## A reference to the player's [PlayerScreen].
##
## This is used for screen fades, UI access, and camera management.
var playerScreen: PlayerScreen

## The last non-zero horizontal direction of the player's [member velocity].
##
## This should be either `1` for right or `-1` for left.
var lastDirection: int = 1

## Tracks whether the player has already consumed their double jump.
##
## This is separate from [constant STATS.HAS_DOUBLE_JUMP], which represents whether
## the player has the ability at all. This value is typically reset when the player
## touches the floor or touches a wall while wall-jumping is available.
var usedDoubleJump: bool = false

## A timer representing the remaining dash cooldown, in seconds.
##
## This value is reduced by [method tickCooldowns].
var dashCooldown: float = 0.0

## A timer used to trigger stamina regeneration roughly once per second.
##
## This value is reduced by [method tickCooldowns] and reset to `1.0` when it reaches `0`.
var oneSecondInterval: float = 1.0

## A jump input buffer timer, in seconds.
##
## This is set when the jump action is pressed and reduced by [method tickCooldowns].
var wantsJump: float = 0.0

## A timer that disables wall-jump detection while greater than `0`.
##
## This value is reduced by [method tickCooldowns].
var disableWalljump: float = 0

## The last safe [member global_position] recorded while the player was standing on the floor.
var lastSafePos: Vector2

##
## Initializes the player and all attached [PlayerState] children.
##
## This method:
## - Calls [method StatEntity._ready].
## - Assigns this player reference to every [PlayerState] child under `$StateMachine`.
## - Starts the player's [member state_machine].
##
func _ready() -> void:
	super._ready()
	for state: PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()

func setupSignals() -> void:
		statsChanged.connect(playerScreen.statPanel.updateStatPanel)
		weapon_armory.weaponOnCooldown.connect(playerScreen.statPanel.startWeaponCooldown)
		weapon_armory.weaponsChanged.connect(playerScreen.statPanel.updateWeaponHUD)
		dashUsed.connect(playerScreen.statPanel.startRechargeBarCooldown)
		weapon_armory.weaponsChanged.emit(weapon_armory.currentWeapons)

##
## Processes player input and updates state logic every physics frame.
##
## This method:
## - Updates [member weapon_armory.useDirection] from movement inputs.
## - Falls back to [member lastDirection] if no horizontal aim input is given.
## - Triggers weapon usage when weapon inputs are pressed.
## - Buffers jump input through [member wantsJump].
## - Updates [member lastDirection] and sprite facing based on horizontal velocity.
## - Stores [member lastSafePos] whenever the player is on the floor.
## - Ticks internal cooldowns through [method tickCooldowns].
## - Updates the active player state through [member state_machine].
##
## [param delta] The physics-frame delta time in seconds.
##
func _physics_process(delta: float) -> void:
	weapon_armory.currentUseDirection = Input.get_vector(
		playerControls.left,
		playerControls.right,
		playerControls.up,
		playerControls.down
	)

	if Input.is_action_just_pressed(playerControls.useWeapon1):
		weapon_armory.useWeapon(0)

	if Input.is_action_just_pressed(playerControls.useWeapon2):
		weapon_armory.useWeapon(1)

	if Input.is_action_just_pressed(playerControls.jump):
		wantsJump = 0.1

	if velocity.x:
		lastDirection = sign(velocity.x)
		$Sprite2D.scale.x = sign(velocity.x)

	if is_on_floor():
		lastSafePos = global_position

	tickCooldowns(delta)
	state_machine.process(delta)

##
## Reduces all active cooldown and buffer timers.
##
## This method updates:
## - [member dashCooldown]
## - [member iFrames]
## - [member wantsJump]
## - [member disableWalljump]
## - [member oneSecondInterval]
##
## When [member oneSecondInterval] reaches `0`, the player regenerates stamina equal to
## [constant STATS.STAMINA_RECHARGE] and the timer resets to `1.0`.
##
## [param delta] The elapsed time in seconds to subtract from timers.
##
func tickCooldowns(delta: float) -> void:
	dashCooldown = max(0, dashCooldown - delta)
	iFrames = max(0, iFrames - delta)
	wantsJump = max(0, wantsJump - delta)
	disableWalljump = max(0, disableWalljump - delta)
	oneSecondInterval = max(0, oneSecondInterval - delta)

	if oneSecondInterval == 0:
		grantStamina(getStat(STATS.STAMINA_RECHARGE))
		oneSecondInterval = 1

##
## Updates the player's [Sprite2D] texture atlas.
##
## This is useful when swapping spritesheets or alternate character appearances.
##
## [param newAtlas] The new [AtlasTexture] to assign to `$Sprite2D.texture`.
##
func setAtlas(newAtlas: AtlasTexture) -> void:
	$Sprite2D.texture = newAtlas

##
## Returns whether the player can currently dash.
##
## The player can dash only if:
## - [constant STATS.HAS_DASH] is non-zero.
## - [member dashCooldown] is `0.0`.
## - [constant STATS.CURRENT_STAMINA] is at least `2`.
##
## [return] `true` if the player can dash, otherwise `false`.
##
func canDash() -> bool:
	return stats[STATS.HAS_DASH] != 0 and dashCooldown == 0.0 and getStat(STATS.CURRENT_STAMINA) >= 2

##
## Returns whether the player can currently wall jump.
##
## The player can wall jump only if:
## - [constant STATS.HAS_WALL_JUMP] is enabled.
## - [member disableWalljump] is not active.
##
## [return] `true` if the player can wall jump, otherwise `false`.
##
func canWalljump() -> bool:
	return stats[STATS.HAS_WALL_JUMP] && not disableWalljump

##
## Returns whether the player can currently use a double jump.
##
## The player can double jump only if:
## - [constant STATS.HAS_DOUBLE_JUMP] is enabled.
## - [constant STATS.CURRENT_STAMINA] is at least `2`.
## - [member usedDoubleJump] is `false`.
##
## [return] `true` if the player can double jump, otherwise `false`.
##
func canDoubleJump() -> bool:
	return stats[STATS.HAS_DOUBLE_JUMP] and getStat(STATS.CURRENT_STAMINA) >= 2 and not usedDoubleJump

##
## Returns the player's current coin count.
##
## Coins are stored in [constant STATS.SOULS].
##
## [return] The current number of coins.
##
func getCoins() -> int:
	return getStat(STATS.SOULS)

##
## Adds coins to the player's total.
##
## [param amount] The number of coins to add.
##
func giveCoins(amount: int) -> void:
	setStat(STATS.SOULS, getStat(STATS.SOULS) + amount)

##
## Removes coins from the player's total, clamped to a minimum of `0`.
##
## [param amount] The number of coins to remove.
##
func takeCoins(amount: int) -> void:
	setStat(STATS.SOULS, max(0, STATS.SOULS - amount))

##
## Sets the movement limits of the player's camera.
##
## The boundaries are applied to [member playerScreen.player_cam] in the following order:
## - `x`: left
## - `y`: right
## - `z`: top
## - `w`: bottom
##
## [param boundaries] A [Vector4i] containing the camera limits.
##
func setCameraLimits(boundaries: Vector4i) -> void:
	var camera: Camera2D = playerScreen.player_cam
	camera.limit_left = boundaries[0]
	camera.limit_right = boundaries[1]
	camera.limit_top = boundaries[2]
	camera.limit_bottom = boundaries[3]
