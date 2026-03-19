extends StatEntity
##
##	[StatEntity] controlled by an array of [InputEventAction] within a [PlayerControls].
##
##	Contains a [WeaponArmory] and utilizes a [StateMachine] for movement and actions.
##
class_name Player

@warning_ignore("unused_signal")
signal dashUsed(cd : float)
@export var playerControls : PlayerControls ## A [PlayerControls] resource that holds the string to an array of [InputEventAction]
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D ## Node responsible for controlling [Camera2D] movement.

var playerScreen : PlayerScreen ## A reference to the Player's [PlayerScreen]. Utilized for screen fades and UI.

var lastDirection : int = 1 ## An [int] representing the last non-zero direction the player's [member velocity] was. Either 1 for right or -1 for left.
var usedDoubleJump : bool = false ## Not to be confused with [member STATS.HAS_DOUBLE_JUMP], this value represents wheter the player has consumed their usage of the double-jump. This value is reset upon Player touching the ground or touching a wall (must have [member STATS.HAS_WALL_JUMP]).

var dashCooldown : float = 0.0 ## Value acting as a timer. Is ticked down by [method tickCooldowns]. 
var oneSecondInterval : float = 1.0 ## Value acting as a one second timer. Is ticked down by [method tickCooldowns]. 
var wantsJump : float = 0.0 ## A jump buffer set to a non-zero decimal value upon a jump [InputEventAction].  Is ticked down by [method tickCooldowns].
var disableWalljump : float = 0 ## Value acting as a timer, where a positive non-zero value represents disabling the wall jump [RayCast2D] nodes.

var lastSafePos : Vector2 ## A value representing the last safe [member global_position] the Player was in. It is set upon the Pl

func _ready() -> void:
	super._ready()
	for state : PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()
func _physics_process(delta: float) -> void:
	weapon_armory.useDirection = Input.get_vector(playerControls.left,playerControls.right,playerControls.up,playerControls.down)
	if not weapon_armory.useDirection.x:
		weapon_armory.useDirection = Vector2(lastDirection,weapon_armory.useDirection.y)
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

## Called every physics frame. Reduces the value of all cooldown variables by [param delta].
func tickCooldowns(delta : float) -> void:
	dashCooldown = max(0, dashCooldown-delta)
	iFrames = max(0, iFrames-delta)
	wantsJump = max(0, wantsJump-delta)
	disableWalljump = max(0, disableWalljump-delta)
	oneSecondInterval = max(0, oneSecondInterval-delta)
	if oneSecondInterval == 0:
		grantStamina(getStat(STATS.STAMINA_RECHARGE))
		oneSecondInterval = 1
## Update the [Sprite2D] texture. Utilized for diverse SpriteSheets.
func setAtlas(newAtlas : AtlasTexture) -> void:
	$Sprite2D.texture = newAtlas
## Returns [member true] if [member STATS.HAS_DASH] is 1, [member dashCooldown] is 0 and [member STATS.CURRENT_STAMINA] is greater than 2.
func canDash() -> bool:
	return stats[STATS.HAS_DASH] != 0 and dashCooldown == 0.0 and getStat(STATS.CURRENT_STAMINA) >= 2
func canWalljump() -> bool:
	return stats[STATS.HAS_WALL_JUMP] && not disableWalljump
func canDoubleJump() -> bool:
	return stats[STATS.HAS_DOUBLE_JUMP] and getStat(STATS.CURRENT_STAMINA) >= 2 and not usedDoubleJump
func getCoins() -> int:
	return getStat(STATS.SOULS)
func giveCoins(amount : int) -> void:
	setStat(STATS.SOULS, getStat(STATS.SOULS)+amount)
func takeCoins(amount : int) -> void:
	setStat(STATS.SOULS, max(0, STATS.SOULS - amount))
func setCameraLimits(boundaries : Vector4i) -> void:
	var camera : Camera2D = playerScreen.player_cam
	camera.limit_left = boundaries[0]
	camera.limit_right = boundaries[1]
	camera.limit_top = boundaries[2]
	camera.limit_bottom = boundaries[3]
