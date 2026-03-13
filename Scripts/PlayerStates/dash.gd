extends PlayerState


@export var dashDuration : float = 0.25
@export var dashSpeed : float = 300
var duration : float 
var enterDir : float
func onEnter() -> void:
	animHandler.set("parameters/conditions/dash", true)
	player.dashCooldown = float(player.getStat(Player.STATS.DASH_COOLDOWN))/100.0
	player.consumeStamina(2)
	player.set_collision_mask_value(2, false)
	player.iFrames = 0.25
	player.velocity.y = 0
	duration = dashDuration
	enterDir = Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1])
	if not enterDir:
		enterDir = player.lastDirection

func process(_delta : float) -> void:
	duration -= _delta
	player.velocity.x = enterDir*dashSpeed
	if player.wantsJump:
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)/3.0
		player.velocity.x =enterDir*dashSpeed*2
		player.wantsJump = false
		nextState = $"../air"
	if player.is_on_wall() and not player.canWalljump():
		nextState = $"../ground"
	if duration <= 0:
		nextState = $"../air"
	player.move_and_slide()

func onExit() -> void:
	player.set_collision_mask_value(2, true)
	animHandler.set("parameters/conditions/dash", false)
