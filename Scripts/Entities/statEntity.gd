extends CharacterBody2D
class_name StatEntity

@export var scalingCurves : Array[Curve] = []
@onready var weapon_armory: WeaponArmory = $WeaponArmory
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
@export var baseStats : Array[int] = [
	0,
	0,		0,
	1,		1,		1,
	10,		5,		1,
	50,		100,  	300,	-125,	300,
	0,		0,		0	]
var stats : Array[int]
var iFrames : float = 0.0

func _ready() -> void:
	stats = baseStats.duplicate(true)
	updateStats()
	weapon_armory.initSystem()
	stats[STATS.CURRENT_HEALTH] = stats[STATS.MAX_HEALTH]
	stats[STATS.CURRENT_STAMINA] = 0

func getStat(stat : STATS) -> int:
	return self.stats[stat]
func setStat(stat : STATS, newValue : int) -> void:
	self.stats[stat] = newValue
	updateStats()
func improveAttribute(attribute : STATS, amount : int) -> void:
	if attribute in [STATS.VITALITY, STATS.AGILITY, STATS.TECHNIQUE]:
		self.setStat(attribute, clampi(getStat(attribute)+amount,0,100))
		updateStats()
	else:
		push_warning("Improve Attribute function took in non-attribute STAT value #%f" % attribute)
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
	statsChanged.emit(stats)
