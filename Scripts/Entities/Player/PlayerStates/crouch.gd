extends PlayerState

##
## A player state used while the [Player] is crouching.
##
## This state:
## - Starts a timer for periodic stamina restoration.
## - Enables the crouch animation condition.
## - Shifts the player's screen downward through [member player.playerScreen].
## - Returns to the ground state when the down input is released.
##
## When the state exits, it restores the screen position and disables the crouch animation.
##
class_name CrouchState

##
## Initializes the crouch state.
##
## This method:
## - Starts the `$oneSecond` timer.
## - Enables the `"crouch"` animation condition.
## - Shifts the player's screen downward through [method player.playerScreen.shiftDown].
##
func onEnter() -> void:
	$oneSecond.start()
	animHandler.set("parameters/conditions/crouch", true)
	player.playerScreen.shiftDown()

##
## Updates crouch-state behavior every frame.
##
## This method transitions back to the ground state when the player releases
## the down input.
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	if Input.is_action_just_released(player.playerControls.down):
		nextState = $"../ground"

##
## Cleans up the crouch state when exiting.
##
## This method:
## - Stops the `$oneSecond` timer.
## - Disables the `"crouch"` animation condition.
## - Restores the player's screen position through [method player.playerScreen.restShift].
##
func onExit() -> void:
	$oneSecond.stop()
	animHandler.set("parameters/conditions/crouch", false)
	player.playerScreen.restShift()

##
## Called when the `$oneSecond` timer times out.
##
## This restores stamina equal to the player's [constant Player.STATS.STAMINA_RECHARGE].
##
func _on_one_second_timeout() -> void:
	player.grantStamina(player.getStat(Player.STATS.STAMINA_RECHARGE))
