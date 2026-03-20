extends PlayerState

#### A player state used while the [Player] is dashing.
##
## This state:
## - Applies a fixed horizontal dash velocity based on the entry direction.
## - Grants temporary invincibility frames.
## - Applies a dash cooldown and emits [signal Player.dashUsed].
## - Temporarily disables collision mask layer `2`.
## - Allows transitions into crouch, air, or other movement states depending on input and context.
##
## The dash lasts for [member dashDuration] seconds unless interrupted by a transition.
class_name DashState


## The maximum duration of the dash, in seconds.
@export var dashDuration: float = 0.25

## The base horizontal dash speed.
##
## The final dash speed is further scaled by the player's [constant Player.STATS.AGILITY].
@export var dashSpeed: float = 300

## The remaining duration of the current dash, in seconds.
##
## This value is initialized during [method onEnter] and decreased every frame in
## [method process].
var duration: float

## The horizontal direction chosen when the dash begins.
##
## This is usually `-1` for left or `1` for right. If no directional input is held on
## entry, [member Player.lastDirection] is used instead.
var enterDir: float

##
## Initializes the dash state.
##
## This method:
## - Enables the `"dash"` animation condition.
## - Sets [member Player.dashCooldown] based on [constant Player.STATS.DASH_COOLDOWN].
## - Emits [signal Player.dashUsed].
## - Consumes stamina for the dash.
## - Temporarily disables collision mask layer `2`.
## - Grants temporary invincibility frames scaled by agility.
## - Resets vertical velocity to `0`.
## - Initializes [member duration].
## - Determines [member enterDir] from input or [member Player.lastDirection].
##
func onEnter() -> void:
	animHandler.set("parameters/conditions/dash", true)
	player.dashCooldown = float(player.getStat(Player.STATS.DASH_COOLDOWN)) / 100.0
	player.dashUsed.emit(player.dashCooldown)
	player.consumeStamina(5)
	player.set_collision_mask_value(2, false)
	player.iFrames = 0.25 * (1 + player.getStat(Player.STATS.AGILITY) / 100.0)
	player.velocity.y = 0
	duration = dashDuration
	enterDir = Input.get_axis(player.playerControls.left, player.playerControls.right)
	if not enterDir:
		enterDir = player.lastDirection

##
## Updates dash behavior every frame.
##
## This method:
## - Decreases the remaining [member duration].
## - Applies dash velocity based on [member enterDir], [member dashSpeed], and agility.
## - Transitions to crouch if the down input is pressed while on the floor.
## - Transitions to air if the down input is pressed while airborne.
## - Allows a reduced-height double jump if a buffered jump is available.
## - Transitions to ground if the player is on a wall and cannot wall jump.
## - Transitions to air when the dash duration expires.
## - Moves the player using [method CharacterBody2D.move_and_slide].
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	duration -= _delta
	player.velocity.x = enterDir * dashSpeed * (1 + float(player.getStat(Player.STATS.AGILITY)) / 400.0)

	if Input.is_action_just_pressed(player.playerControls.down):
		if player.is_on_floor():
			player.velocity.x = 0
			nextState = $"../crouch"
		else:
			nextState = $"../air"
	elif player.wantsJump and player.canDoubleJump():
		player.consumeStamina(1)
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER) / 3.0
		player.wantsJump = false
		player.usedDoubleJump = true
		nextState = $"../air"
	elif player.is_on_wall() and not player.canWalljump():
		nextState = $"../ground"
	elif duration <= 0:
		nextState = $"../air"

	player.move_and_slide()

##
## Cleans up the dash state when exiting.
##
## This method:
## - Re-enables collision mask layer `2`.
## - Disables the `"dash"` animation condition.
##
func onExit() -> void:
	player.set_collision_mask_value(2, true)
	animHandler.set("parameters/conditions/dash", false)
