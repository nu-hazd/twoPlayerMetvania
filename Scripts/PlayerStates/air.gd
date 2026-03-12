extends PlayerState

var gravity : int = 300
@export var airAcceleration : float = 0.02
@export var airFriction : float = 0.001

func onEnter() -> void:
	animHandler.set("parameters/conditions/air", true)
	animHandler.set("parameters/air/blend_position", sign(player.velocity.y))

func process(_delta : float) -> void:
	var dirX : float = Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1])
	if dirX:
		player.velocity.x = lerp(player.velocity.x, dirX * player.getStat(player.STATS.AIR_SPEED), airAcceleration)
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, airFriction)
	animHandler.set("parameters/air/blend_position",sign(player.velocity.y))
	if player.wantsJump and player.canDoubleJump():
		player.wantsJump = false
		player.usedDoubleJump = true
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)/1.3
		player.consumeStamina(1)
	if Input.is_action_just_pressed(player.playerControls.playerInputArray[2]):
		player.velocity.y += player.getStat(Player.STATS.FAST_FALL)*_delta
	if Input.is_action_just_pressed(player.playerControls.playerInputArray[4]) && player.canDash():
		nextState = $"../dash"
	if Vector2($"../../left".is_colliding(), $"../../right".is_colliding()) and player.canWalljump():
		nextState = $"../wallSlide"
	if player.is_on_floor():
		nextState = $"../ground"
	player.velocity.y += gravity*_delta
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/air", false)

func _input(event: InputEvent) -> void:
	if event.is_action_released(player.playerControls.playerInputArray[3]):
		player.velocity.y *= 0.5
