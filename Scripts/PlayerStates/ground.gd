extends PlayerState
class_name GroundState
@export var groundAcceleration : float = 0.05
@export var groundFriction : float = 0.33
var hasntMoved : float = 0.5
var staminaRecharge : float = 0.0
func onEnter() -> void:
	player.usedDoubleJump = false
	animHandler.set("parameters/conditions/ground", true)
	animHandler.set("parameters/ground/blend_position",sign(player.velocity.x))

func process(_delta : float) -> void:
	hasntMoved -= _delta
	if player.velocity:
		hasntMoved = 0.5
	if hasntMoved <= 0:
		staminaRecharge += _delta
		if staminaRecharge >= 1:
			player.grantStamina(player.getStat(Player.STATS.STAMINA_RECHARGE))
			staminaRecharge = 0
	if not player.is_on_floor():
		nextState = $"../air"
	if player.wantsJump and player.getStat(Player.STATS.CURRENT_STAMINA) >= 1:
		player.wantsJump = 0
		player.consumeStamina(2)
		player.velocity.y = player.getStat(Player.STATS.JUMP_POWER)
	if Input.is_action_just_pressed(player.playerControls.dash) and player.canDash():
			nextState = $"../dash"
	var dirX : float = Input.get_axis(player.playerControls.left,player.playerControls.right)
	if dirX:
		player.velocity.x = lerp(player.velocity.x, dirX * player.getStat(player.STATS.GROUND_SPEED), groundAcceleration)
	else:
		player.velocity.x = lerp(player.velocity.x, 0.0, groundFriction)
	animHandler.set("parameters/ground/blend_position", player.velocity.x)
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/ground", false)
