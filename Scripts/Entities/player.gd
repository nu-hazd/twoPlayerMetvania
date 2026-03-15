extends StatEntity
class_name Player

var rom : Room
@export var playerControls : PlayerControls
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D
var playerScreen : PlayerScreen
#enum STAT_MODIFIER {
	#MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE
#}
var playerName : String = "Rogue"
var dashCooldown : float = 0.0
var oneSecondInterval : float = 1.0
var lastDirection : int = 1
var usedDoubleJump : bool = false
var wantsJump : float = 0.0
var disableWalljump : float = 0
var lastSafePos : Vector2
func _ready() -> void:
	super._ready()
	for state : PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()
func _physics_process(delta: float) -> void:
	weapon_armory.useDirection = Input.get_vector(playerControls.left,playerControls.right,playerControls.up,playerControls.down)
	if not weapon_armory.useDirection.x:
		weapon_armory.useDirection = Vector2(lastDirection,weapon_armory.useDirection.y)
	if Input.is_action_just_pressed(playerControls.useWeapon1):
		weapon_armory.useWeapon(0)
	if Input.is_action_just_pressed(playerControls.useWeapon2):
		weapon_armory.useWeapon(1)
	if Input.is_action_just_pressed(playerControls.jump):
		wantsJump = 0.1
	if velocity.x:
		lastDirection = sign(velocity.x)
		$Sprite2D.scale.x = sign(velocity.x)
	if is_on_floor():
		lastSafePos = global_position
	tickCooldowns(delta)
	state_machine.process(delta)

func tickCooldowns(delta : float) -> void:
	dashCooldown = max(0, dashCooldown-delta)
	iFrames = max(0, iFrames-delta)
	wantsJump = max(0, wantsJump-delta)
	disableWalljump = max(0, disableWalljump-delta)
	oneSecondInterval = max(0, oneSecondInterval-delta)
	if oneSecondInterval == 0:
		grantStamina(getStat(STATS.STAMINA_RECHARGE))
		oneSecondInterval = 1

func canDash() -> bool:
	return stats[STATS.HAS_DASH] != 0 and dashCooldown == 0.0 and getStat(STATS.CURRENT_STAMINA) >= 2
func canWalljump() -> bool:
	return stats[STATS.HAS_WALL_JUMP] && not disableWalljump
func canDoubleJump() -> bool:
	return stats[STATS.HAS_DOUBLE_JUMP] and getStat(STATS.CURRENT_STAMINA) >= 2 and not usedDoubleJump
func randomizeStats() -> void:
	setStat(STATS.HAS_DASH, 1)
	setStat(STATS.HAS_DOUBLE_JUMP, 1)
	setStat(STATS.HAS_WALL_JUMP, 1)
	improveAttribute(STATS.VITALITY, randi_range(0, 10))
	improveAttribute(STATS.TECHNIQUE, randi_range(0, 10))
	improveAttribute(STATS.AGILITY, 0)
func setCameraLimits(boundaries : Vector4i) -> void:
	var camera : Camera2D = playerScreen.player_cam
	camera.limit_left = boundaries[0]
	camera.limit_right = boundaries[1]
	camera.limit_top = boundaries[2]
	camera.limit_bottom = boundaries[3]
