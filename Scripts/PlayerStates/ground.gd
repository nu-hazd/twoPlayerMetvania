extends PlayerState

func onEnter() -> void:
	animHandler.set("parameters/conditions/ground", true)
	animHandler.set("parameters/ground/blend_position",sign(player.velocity.x))

func process(_delta : float) -> void:
	if not player.is_on_floor():
		nextState = $"../air"
	if Input.is_action_just_pressed(player.playerControls.playerInputArray[3]):
		player.velocity.y += player.getStat(Player.STATS.JUMP_POWER)
	var dirX : float = Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1])
	player.velocity.x = player.getStat(Player.STATS.GROUND_SPEED)*dirX
	animHandler.set("parameters/ground/blend_position",sign(player.velocity.x))
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/ground", false)
