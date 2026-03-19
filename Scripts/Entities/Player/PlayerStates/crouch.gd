extends PlayerState


func onEnter() -> void:
	$oneSecond.start()
	animHandler.set("parameters/conditions/crouch", true)
	player.playerScreen.shiftDown()

func process(_delta : float) -> void:
	if Input.is_action_just_released(player.playerControls.down):
		nextState = $"../ground"
	
func onExit() -> void:
	$oneSecond.stop()
	animHandler.set("parameters/conditions/crouch", false)
	player.playerScreen.restShift()

func _on_one_second_timeout() -> void:
	player.grantStamina(player.getStat(Player.STATS.STAMINA_RECHARGE))
