extends CharacterBody2D
class_name Player


@export var scalingCurves : Array[Curve] = []
@export var playerControls : PlayerControls
@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D
@onready var state_machine: StateMachine = $StateMachine
signal statsChanged(newStats : Array[float])
enum STATS {
	SOULS,
	CURRENT_HEALTH, CURRENT_STAMINA,
	VITALITY,	AGILITY,	TECHNIQUE,
	MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE,
	GROUND_SPEED, AIR_SPEED, FAST_FALL, JUMP_POWER, DASH_COOLDOWN,
	DOUBLE_JUMPS, HAS_DASH, HAS_WALL_JUMP
}
#enum STAT_MODIFIER {
	#MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE
#}
@export var baseStats : Array[int] = [
	0,
	0,		0,
	1,		1,		1,
	10,		5,		100,
	100,	90,		300,	-200,	250,
	0,		0,		0	]
var stats : Array[int]

var dashCooldown : float = 0.0
func _ready() -> void:
	stats = baseStats
	updateStats()
	for state : PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()
func _physics_process(delta: float) -> void:
	dashCooldown = max(0, dashCooldown-delta)
	if velocity.x:
		$Sprite2D.scale.x = sign(velocity.x)
	state_machine.process(delta)

func canDash() -> bool:
	return stats[STATS.HAS_DASH] != 0 and dashCooldown == 0.0


func getStat(stat : STATS) -> float:
	return self.stats[stat]
func setStat(stat : STATS, newValue : float) -> void:
	self.stats[stat] = newValue
	statsChanged.emit(stats)
func improveAttribute(attribute : STATS, amount : int) -> void:
	if attribute in [STATS.VITALITY, STATS.AGILITY, STATS.TECHNIQUE]:
		self.setStat(attribute, clampf(getStat(attribute)+amount,0.0,100.0))
		updateStats()
	else:
		push_warning("Improve Attribute function took in non-attribute STAT value #%f" % amount)

func heal(amount : int) -> void:
	setStat(STATS.CURRENT_HEALTH, clamp(getStat(STATS.CURRENT_HEALTH) + amount,0, getStat(STATS.MAX_HEALTH)))
func damage(amount : int) -> void:
	setStat(STATS.CURRENT_HEALTH, clamp(getStat(STATS.CURRENT_HEALTH) - amount,0, getStat(STATS.MAX_HEALTH)))

func updateStats() -> void:
	stats[STATS.MAX_HEALTH] = baseStats[STATS.MAX_HEALTH] + scalingCurves[0].sample(stats[STATS.VITALITY])
	stats[STATS.MAX_STAMINA] = baseStats[STATS.MAX_STAMINA] + scalingCurves[1].sample(stats[STATS.VITALITY])
	stats[STATS.STAMINA_RECHARGE] = baseStats[STATS.STAMINA_RECHARGE] + scalingCurves[2].sample(stats[STATS.AGILITY])
	stats[STATS.GROUND_SPEED] = baseStats[STATS.GROUND_SPEED] + scalingCurves[3].sample(stats[STATS.AGILITY])
	stats[STATS.AIR_SPEED] =baseStats[STATS.AIR_SPEED] + scalingCurves[4].sample(stats[STATS.AGILITY])
	stats[STATS.FAST_FALL] =baseStats[STATS.FAST_FALL] + scalingCurves[5].sample(stats[STATS.AGILITY])
	stats[STATS.JUMP_POWER] = baseStats[STATS.JUMP_POWER] - scalingCurves[6].sample(stats[STATS.AGILITY])
	stats[STATS.DASH_COOLDOWN] = baseStats[STATS.MAX_HEALTH] - (100*scalingCurves[7].sample(stats[STATS.AGILITY]))
