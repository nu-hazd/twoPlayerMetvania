extends PlayerState

##
## A player state used while the [Player] is standing or moving on the ground.
##
## This state handles:
## - Ground movement acceleration and friction.
## - Resetting double-jump usage on landing.
## - Jump initiation from the floor.
## - Dash initiation from the floor.
## - Entering the crouch state.
## - Updating ground movement animation blending.
##
## Horizontal motion is applied using [method lerp], then the player is moved with
## [method CharacterBody2D.move_and_slide].
class_name GroundState


## The interpolation strength used when accelerating horizontally on the ground.
##
## This value is further scaled by the player's [constant Player.STATS.AGILITY].
@export var groundAcceleration: float = 0.05

## The interpolation strength used when slowing horizontal movement on the ground.
##
## This value is further scaled by the player's [constant Player.STATS.AGILITY].
@export var groundFriction: float = 0.33

## A short timer used to prevent immediate repeated crouch transitions.
##
## While greater than `0.0`, pressing down again triggers the alternate branch that
## nudges the player's position instead of re-entering crouch immediately.
var justCrouched: float = 0.0

##
## Initializes the ground state.
##
## This method:
## - Resets [member Player.usedDoubleJump].
## - Enables the `"ground"` animation condition.
## - Sets the ground blend position based on the player's horizontal velocity.
##
func onEnter() -> void:
	player.usedDoubleJump = false
	animHandler.set("parameters/conditions/ground", true)
	animHandler.set("parameters/ground/blend_position", sign(player.velocity.x))

##
## Updates ground movement and state transitions every frame.
##
## This method:
## - Decreases [member justCrouched].
## - Transitions to the air state if the player leaves the floor.
## - Consumes a buffered jump if the player has enough stamina.
## - Transitions to dash if dash is pressed and the player can dash.
## - Transitions to crouch if the down input is pressed and the crouch delay is inactive.
## - Applies horizontal acceleration or friction based on input.
## - Updates the ground animation blend position from horizontal velocity.
## - Moves the player using [method CharacterBody2D.move_and_slide].
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	justCrouched = max(0, justCrouched - _delta)

	if not player.is_on_floor():
		nextState = $"../air"

	if player.wantsJump and player.getStat(Player.STATS.CURRENT_STAMINA) >= 1:
		player.wantsJump = 0
		player.consumeStamina(2)
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)

	if Input.is_action_just_pressed(player.playerControls.dash) and player.canDash():
		nextState = $"../dash"

	if Input.is_action_just_pressed(player.playerControls.down):
		if not justCrouched:
			nextState = $"../crouch"
			justCrouched = 0.1
		else:
			player.position.y += 1

	var dirX: float = Input.get_axis(player.playerControls.left, player.playerControls.right)

	if dirX:
		player.velocity.x = lerp(
			player.velocity.x,
			dirX * player.getStat(player.STATS.GROUND_SPEED),
			groundAcceleration * (1 + player.getStat(Player.STATS.AGILITY) / 50.0)
		)
	else:
		player.velocity.x = lerp(
			player.velocity.x,
			0.0,
			groundFriction * (1 + player.getStat(Player.STATS.AGILITY) / 50.0)
		)

	animHandler.set("parameters/ground/blend_position", player.velocity.x)
	player.move_and_slide()

##
## Cleans up the ground state when exiting.
##
## This method disables the `"ground"` animation condition.
##
func onExit() -> void:
	animHandler.set("parameters/conditions/ground", false)
