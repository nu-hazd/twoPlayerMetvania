extends PlayerState

var gravity : int = 300

func onEnter() -> void:
	animHandler.set("parameters/conditions/air", true)
	animHandler.set("parameters/air/blend_position", sign(player.velocity.y))

func process(_delta : float) -> void:
	var dirX : float = Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1])
	player.velocity.x = player.getStat(Player.STATS.AIR_SPEED)*dirX
	animHandler.set("parameters/air/blend_position",sign(player.velocity.y))
	if Input.is_action_just_pressed(player.playerControls.playerInputArray[2]):
		player.velocity.y += player.getStat(Player.STATS.FAST_FALL)*_delta
	player.velocity.y += gravity*_delta
	if player.is_on_floor():
		nextState = $"../ground"
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/air", false)

func _input(event: InputEvent) -> void:
	if event.is_action_released(player.playerControls.playerInputArray[3]):
		player.velocity.y *= 0.5
