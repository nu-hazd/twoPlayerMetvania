extends PlayerState


@export var dashDuration : float = 0.25
@export var dashSpeed : float = 300
var duration : float 
var enterDir : float
func onEnter() -> void:
	animHandler.set("parameters/conditions/dash", true)
	player.dashCooldown = float(player.getStat(Player.STATS.DASH_COOLDOWN))/100.0
	player.dashUsed.emit(player.dashCooldown)
	player.consumeStamina(5)
	player.set_collision_mask_value(2, false)
	player.iFrames = 0.25 * (1 + player.getStat(Player.STATS.AGILITY)/100.0)
	player.velocity.y = 0
	duration = dashDuration
	enterDir = Input.get_axis(player.playerControls.left,player.playerControls.right)
	if not enterDir:
		enterDir = player.lastDirection

func process(_delta : float) -> void:
	duration -= _delta
	player.velocity.x = enterDir*dashSpeed * (1 + float(player.getStat(Player.STATS.AGILITY))/400.0)
	if Input.is_action_just_pressed(player.playerControls.down):
		if player.is_on_floor():
			player.velocity.x = 0
			nextState = $"../crouch"
		else:
			nextState = $"../air"
	elif player.wantsJump and player.canDoubleJump():
		player.consumeStamina(1)
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)/3.0
		player.wantsJump = false
		player.usedDoubleJump = true
		nextState = $"../air"
	elif player.is_on_wall() and not player.canWalljump():
		nextState = $"../ground"
	elif duration <= 0:
		nextState = $"../air"
	player.move_and_slide()

func onExit() -> void:
	player.set_collision_mask_value(2, true)
	animHandler.set("parameters/conditions/dash", false)
