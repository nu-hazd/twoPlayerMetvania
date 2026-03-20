extends PlayerState

##
## A player state used while the [Player] is sliding against a wall.
##
## This state handles:
## - Reduced falling speed while clinging to a wall.
## - Stronger downward pull while the player is moving upward.
## - Wall jump execution.
## - Dash transitions away from the wall.
## - Manual uncling movement when directional input moves away from the wall.
##
## The active wall side is determined from the left and right wall-detection nodes.
class_name WallSlideState


## The downward acceleration applied while wall sliding when the player is already falling.
@export var clingGravity: int = 100

## The downward acceleration applied while wall sliding when the player is still moving upward.
##
## This causes upward motion to be canceled faster than normal downward sliding.
@export var clingGravityIfUp: int = 300

## The horizontal speed applied when the player presses away from the wall without
## transitioning immediately into another state.
@export var unclingSpeed: int = 50

## The wall direction detected when this state begins.
##
## This value is computed as:
## - `1` when colliding with the right wall detector
## - `-1` when colliding with the left wall detector
## - `0` when neither side is detected
var enterWallDir: float

##
## Initializes the wall-slide state.
##
## This method:
## - Clears any pending [member nextState].
## - Resets [member Player.usedDoubleJump].
## - Detects which wall the player entered from.
## - Falls back to the ground state if no wall is detected.
## - Enables the `"cling"` animation condition.
##
func onEnter() -> void:
	nextState = null
	player.usedDoubleJump = false
	enterWallDir = int($"../../right".is_colliding()) - int($"../../left".is_colliding())

	if not enterWallDir:
		nextState = $"../ground"

	animHandler.set("parameters/conditions/cling", true)

##
## Updates wall-slide behavior and state transitions every frame.
##
## This method:
## - Recomputes the current wall-contact direction.
## - Transitions to air if the player is no longer touching a wall.
## - Performs a wall jump if a buffered jump is available and enough stamina remains.
## - Transitions to dash if dash is pressed, the player can dash, and input is directed
##   away from the wall entered on.
## - Applies horizontal movement away from the wall when input is directed away from the wall.
## - Transitions when the player reaches the floor.
## - Applies cling gravity based on whether the player is moving upward or downward.
## - Moves the player using [method CharacterBody2D.move_and_slide].
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	var collidingWithWalls: int = int($"../../right".is_colliding()) - int($"../../left".is_colliding())

	if not collidingWithWalls:
		nextState = $"../air"
	elif player.wantsJump and player.getStat(Player.STATS.CURRENT_STAMINA) >= 2:
		player.consumeStamina(2)
		player.wantsJump = 0
		player.velocity = Vector2(
			-sign(collidingWithWalls) * player.getStat(Player.STATS.GROUND_SPEED) / 1.5,
			player.getStat(Player.STATS.JUMP_POWER)
		)
		nextState = $"../air"
	elif Input.is_action_just_pressed(player.playerControls.dash) and player.canDash() and Input.get_axis(player.playerControls.left, player.playerControls.right) != enterWallDir:
		nextState = $"../dash"
	elif Input.get_axis(player.playerControls.left, player.playerControls.right) != enterWallDir:
		player.velocity.x = Input.get_axis(player.playerControls.left, player.playerControls.right) * unclingSpeed
	elif player.is_on_floor():
		nextState = $"../ground"

	if player.velocity.y < 0:
		player.velocity.y += clingGravityIfUp * _delta
	else:
		player.velocity.y += clingGravity * _delta

	player.move_and_slide()

##
## Cleans up the wall-slide state when exiting.
##
## This method:
## - Temporarily disables wall jumping through [member Player.disableWalljump].
## - Disables the `"cling"` animation condition.
##
func onExit() -> void:
	player.disableWalljump = 0.1
	animHandler.set("parameters/conditions/cling", false)
