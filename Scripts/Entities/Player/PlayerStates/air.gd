extends PlayerState
## A player state used while the [Player] is airborne.
##
## This state handles:
## - Airborne horizontal movement.
## - Air friction and acceleration scaling.
## - Variable vertical animation blending.
## - Double jump usage.
## - Fast-fall behavior.
## - Transition checks for dash, wall slide, and ground states.
##
## Gravity is applied every frame, and the player is moved through
## [method CharacterBody2D.move_and_slide].
class_name AirState


## The downward acceleration applied to the player each frame while airborne.
var gravity: int = 400

## The interpolation strength used when accelerating horizontally in the air.
##
## This value is further scaled by the player's [constant Player.STATS.AGILITY].
@export var airAcceleration: float = 0.02

## The interpolation strength used when slowing horizontal movement in the air.
##
## This value is further scaled by the player's [constant Player.STATS.AGILITY].
@export var airFriction: float = 0.005

##
## Initializes the airborne state.
##
## This method:
## - Enables the `"air"` animation condition.
## - Sets the air blend position based on the sign of the player's vertical velocity.
##
func onEnter() -> void:
	animHandler.set("parameters/conditions/air", true)
	animHandler.set("parameters/air/blend_position", sign(player.velocity.y))

##
## Updates airborne movement and state transitions every frame.
##
## This method:
## - Reads horizontal air input.
## - Applies horizontal acceleration or air friction using [method lerp].
## - Updates the air animation blend position from vertical velocity.
## - Consumes a buffered jump for a double jump if available.
## - Applies fast-fall when the down input is held.
## - Transitions to dash if dash is pressed and the player can dash.
## - Transitions to wall slide if a wall is detected and the player can wall jump.
## - Transitions to ground if the player lands.
## - Applies gravity to vertical velocity.
## - Moves the player using [method CharacterBody2D.move_and_slide].
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	var dirX: float = Input.get_axis(player.playerControls.left, player.playerControls.right)

	if dirX:
		player.velocity.x = lerp(
			player.velocity.x,
			dirX * player.getStat(player.STATS.AIR_SPEED),
			airAcceleration * (1 + player.getStat(Player.STATS.AGILITY) / 50.0)
		)
	else:
		player.velocity.x = lerp(
			player.velocity.x,
			0.0,
			airFriction * (1 + player.getStat(Player.STATS.AGILITY) / 50.0)
		)

	animHandler.set("parameters/air/blend_position", sign(player.velocity.y))

	if player.wantsJump and player.canDoubleJump():
		player.wantsJump = false
		player.usedDoubleJump = true
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)
		player.consumeStamina(2)

	if Input.is_action_pressed(player.playerControls.down):
		player.velocity.y += player.getStat(Player.STATS.FAST_FALL) * _delta

	if Input.is_action_just_pressed(player.playerControls.dash) && player.canDash():
		nextState = $"../dash"

	if Vector2($"../../left".is_colliding(), $"../../right".is_colliding()) and player.canWalljump():
		nextState = $"../wallSlide"

	if player.is_on_floor():
		nextState = $"../ground"

	player.velocity.y += gravity * _delta
	player.move_and_slide()

##
## Cleans up the airborne state when exiting.
##
## This method disables the `"air"` animation condition.
##
func onExit() -> void:
	animHandler.set("parameters/conditions/air", false)

##
## Handles jump-release input while airborne.
##
## When the jump action is released, the player's upward velocity is reduced,
## allowing for shorter jumps when the jump button is tapped instead of held.
##
## [param event] The input event to evaluate.
##
func _input(event: InputEvent) -> void:
	if event.is_action_released(player.playerControls.jump):
		player.velocity.y *= 0.5
