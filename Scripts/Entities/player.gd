extends CharacterBody2D
class_name Player


@export var scalingCurves : Array[Curve] = []
@export var playerControls : PlayerControls
@onready var weapon_armory: WeaponArmory = $WeaponArmory
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D
@onready var state_machine: StateMachine = $StateMachine
signal statsChanged(newStats : Array[int])
enum STATS {
	SOULS,
	CURRENT_HEALTH, CURRENT_STAMINA,
	VITALITY,	AGILITY,	TECHNIQUE,
	MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE,
	GROUND_SPEED, AIR_SPEED, FAST_FALL, JUMP_POWER, DASH_COOLDOWN,
	HAS_DOUBLE_JUMP, HAS_DASH, HAS_WALL_JUMP
}
#enum STAT_MODIFIER {
	#MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE
#}
@export var baseStats : Array[int] = [
	0,
	0,		0,
	1,		1,		1,
	10,		5,		1,
	100,	90,		300,	-200,	250,
	0,		0,		0	]
var stats : Array[int]

var playerName : String = "Rogue"
var dashCooldown : float = 0.0
var iFrames : float = 0.0
var oneSecondInterval : float = 1.0
var lastDirection : int = 1
var usedDoubleJump : bool = false
var wantsJump : float = 0.0
var disableWalljump : float = 0
func _ready() -> void:
	stats = baseStats
	randomizeStats()
	updateStats()
	stats[STATS.CURRENT_HEALTH] = stats[STATS.MAX_HEALTH]
	stats[STATS.CURRENT_STAMINA] = 0
	for state : PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()
func _physics_process(delta: float) -> void:
	weapon_armory.useDirection = Input.get_vector(playerControls.playerInputArray[0],playerControls.playerInputArray[1],playerControls.playerInputArray[5],playerControls.playerInputArray[3])
	if not weapon_armory.useDirection.x:
		weapon_armory.useDirection = Vector2(lastDirection,weapon_armory.useDirection.y)
	if Input.is_action_just_pressed(playerControls.playerInputArray[6]):
		weapon_armory.useWeapon(0)
	if Input.is_action_just_pressed(playerControls.playerInputArray[7]):
		weapon_armory.useWeapon(1)
	
	if Input.is_action_just_pressed(playerControls.playerInputArray[3]):
		wantsJump = 0.1
	if velocity.x:
		lastDirection = sign(velocity.x)
		$Sprite2D.scale.x = sign(velocity.x)
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
	return stats[STATS.HAS_DOUBLE_JUMP] and getStat(STATS.CURRENT_STAMINA) >= 1 and not usedDoubleJump
func getStat(stat : STATS) -> int:
	return self.stats[stat]
func setStat(stat : STATS, newValue : int) -> void:
	self.stats[stat] = newValue
	statsChanged.emit(stats)
func improveAttribute(attribute : STATS, amount : int) -> void:
	if attribute in [STATS.VITALITY, STATS.AGILITY, STATS.TECHNIQUE]:
		self.setStat(attribute, clampi(getStat(attribute)+amount,0,100))
	else:
		push_warning("Improve Attribute function took in non-attribute STAT value #%f" % amount)

func heal(amount : int) -> void:
	setStat(STATS.CURRENT_HEALTH, clamp(getStat(STATS.CURRENT_HEALTH) + amount,0, getStat(STATS.MAX_HEALTH)))
func damage(amount : int) -> void:
	setStat(STATS.CURRENT_HEALTH, clamp(getStat(STATS.CURRENT_HEALTH) - amount,0, getStat(STATS.MAX_HEALTH)))
func isInvincible() -> bool:
	return iFrames > 0
func consumeStamina(consumed : int) -> void:
	setStat(STATS.CURRENT_STAMINA, clampi(getStat(STATS.CURRENT_STAMINA)-consumed,0,getStat(STATS.MAX_STAMINA)))
func grantStamina(granted : int) -> void:
	setStat(STATS.CURRENT_STAMINA, clampi(getStat(STATS.CURRENT_STAMINA)+granted,0,getStat(STATS.MAX_STAMINA)))


func updateStats() -> void:
	stats[STATS.MAX_HEALTH] = baseStats[STATS.MAX_HEALTH] + int(scalingCurves[0].sample(stats[STATS.VITALITY]))
	stats[STATS.MAX_STAMINA] = baseStats[STATS.MAX_STAMINA] + int(scalingCurves[1].sample(stats[STATS.VITALITY]))
	stats[STATS.STAMINA_RECHARGE] = baseStats[STATS.STAMINA_RECHARGE] + floor(scalingCurves[2].sample(stats[STATS.TECHNIQUE]))
	stats[STATS.GROUND_SPEED] = baseStats[STATS.GROUND_SPEED] + int(scalingCurves[3].sample(stats[STATS.AGILITY]))
	stats[STATS.AIR_SPEED] =baseStats[STATS.AIR_SPEED] + int(scalingCurves[4].sample(stats[STATS.AGILITY]))
	stats[STATS.FAST_FALL] =baseStats[STATS.FAST_FALL] + int(scalingCurves[5].sample(stats[STATS.AGILITY]))
	stats[STATS.JUMP_POWER] = baseStats[STATS.JUMP_POWER] - int(scalingCurves[6].sample(stats[STATS.AGILITY]))
	stats[STATS.DASH_COOLDOWN] = baseStats[STATS.DASH_COOLDOWN] - int((100*scalingCurves[7].sample(stats[STATS.AGILITY])))
func randomizeStats() -> void:
	setStat(STATS.HAS_DASH, 1)
	setStat(STATS.HAS_DOUBLE_JUMP, 1)
	setStat(STATS.HAS_WALL_JUMP, 1)
	improveAttribute(STATS.VITALITY, randi_range(0, 10))
	improveAttribute(STATS.TECHNIQUE, randi_range(0, 10))
	improveAttribute(STATS.AGILITY, randi_range(0, 10))
