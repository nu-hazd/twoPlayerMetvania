extends PlayerState


func onEnter() -> void:
	animHandler.set("parameters/conditions/crouch", true)
	player.playerScreen.shiftDown()

func process(_delta : float) -> void:
	if Input.is_action_just_released(player.playerControls.down):
		nextState = $"../ground"

func onExit() -> void:
	animHandler.set("parameters/conditions/crouch", false)
	player.playerScreen.restShift()
