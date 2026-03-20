extends CharacterBody2D
## A base character entity that stores and manages combat, movement, and progression stats.
##
## This class provides:
## - A stat array indexed through [enum STATS].
## - Attribute scaling through [member scalingCurves].
## - Health and stamina management.
## - Access to a [StateMachine] through [member state_machine].
## - Access to a [WeaponArmory] through [member weapon_armory].
## - A [signal statsChanged] signal emitted whenever derived stats are recalculated.
##
## Derived stats such as maximum health, stamina recharge, and movement values are
## recalculated in [method updateStats] based on the core attributes:
## - [constant STATS.VITALITY]
## - [constant STATS.AGILITY]
## - [constant STATS.TECHNIQUE]
##
class_name StatEntity


## Curves used to scale derived stats from the entity's core attributes.
##
## Specific indices are used by [method updateStats] to calculate values such as
## maximum health, stamina recharge, and speed-related stats.
@export var scalingCurves: Array[Curve] = []

## Reference to the entity's [WeaponArmory].
@onready var weapon_armory: WeaponArmory = $WeaponArmory

## Reference to the entity's [StateMachine].
@onready var state_machine: StateMachine = $StateMachine

## Emitted whenever the entity's [member stats] array has been recalculated.
##
## [param newStats] The updated stats array.
signal statsChanged(newStats: Array[int])

##
## Enumeration used to index entries in [member baseStats] and [member stats].
##
## Includes currencies, current resource values, core attributes, derived combat values,
## movement stats, and unlock flags.
##
enum STATS {
	SOULS,
	CURRENT_HEALTH, CURRENT_STAMINA,
	VITALITY, AGILITY, TECHNIQUE,
	MAX_HEALTH, MAX_STAMINA, STAMINA_RECHARGE,
	GROUND_SPEED, AIR_SPEED, FAST_FALL, JUMP_POWER, DASH_COOLDOWN,
	HAS_DOUBLE_JUMP, HAS_DASH, HAS_WALL_JUMP
}

## The entity's baseline stat values.
##
## These values are duplicated into [member stats] during [method _ready], after which
## [method updateStats] recalculates all derived values.
@export var baseStats: Array[int] = [
	0,
	0,		0,
	1,		1,		1,
	10,		5,		1,
	50,		100,	300,	-125,	300,
	0,		0,		0
]

## The entity's current live stat values.
##
## This array is initialized from [member baseStats] and then modified over time through
## methods such as [method setStat], [method heal], [method damage], and [method updateStats].
var stats: Array[int]

## The remaining invincibility-frame duration, in seconds.
##
## While greater than `0.0`, [method isInvincible] returns `true`.
var iFrames: float = 0.0

##
## Initializes the entity's stats, visual shader state, and weapon system.
##
## This method:
## - Disables the sprite shader's `"enabled"` parameter.
## - Copies [member baseStats] into [member stats].
## - Recalculates derived stats through [method updateStats].
## - Initializes the [member weapon_armory].
## - Sets current health and stamina to their maximum values.
##
func _ready() -> void:
	var spr: Sprite2D = $Sprite2D
	var mat: ShaderMaterial = spr.material
	mat.set_shader_parameter("enabled", false)
	stats = baseStats.duplicate(true)
	updateStats()
	weapon_armory.initSystem()
	stats[STATS.CURRENT_HEALTH] = stats[STATS.MAX_HEALTH]
	stats[STATS.CURRENT_STAMINA] = stats[STATS.MAX_STAMINA]

##
## Returns the current value of a given stat.
##
## [param stat] The [enum STATS] entry to retrieve.
## [return] The current value stored for that stat.
##
func getStat(stat: STATS) -> int:
	return self.stats[stat]

##
## Sets a stat to a new value and recalculates dependent stats.
##
## [param stat] The [enum STATS] entry to modify.
## [param newValue] The new value to assign.
##
func setStat(stat: STATS, newValue: int) -> void:
	self.stats[stat] = newValue
	updateStats()

##
## Increases one of the core attributes by a given amount.
##
## Only the following attributes are considered valid:
## - [constant STATS.VITALITY]
## - [constant STATS.AGILITY]
## - [constant STATS.TECHNIQUE]
##
## The resulting value is clamped between `0` and `100`.
##
## [param attribute] The attribute to improve.
## [param amount] The amount to add.
##
## If a non-attribute stat is provided, a warning is pushed.
##
func improveAttribute(attribute: STATS, amount: int) -> void:
	if attribute in [STATS.VITALITY, STATS.AGILITY, STATS.TECHNIQUE]:
		self.setStat(attribute, clampi(getStat(attribute) + amount, 1, 100))
	else:
		push_warning("Improve Attribute function took in non-attribute STAT value #%f" % attribute)

##
## Restores health up to [constant STATS.MAX_HEALTH].
##
## This method plays the `"heal"` sound or animation on `$hitAndHeal` and clamps the
## result between `0` and the entity's maximum health.
##
## [param amount] The amount of health to restore.
##
func heal(amount: int) -> void:
	$hitAndHeal.play("heal")
	setStat(
		STATS.CURRENT_HEALTH,
		clamp(getStat(STATS.CURRENT_HEALTH) + amount, 0, getStat(STATS.MAX_HEALTH))
	)

##
## Reduces health down to a minimum of `0`.
##
## If this entity is a [Player], its [member iFrames] value is set to at least `0.35`
## seconds before applying damage.
##
## This method plays the `"hit"` sound or animation on `$hitAndHeal` and clamps the
## result between `0` and the entity's maximum health.
##
## [param amount] The amount of damage to apply.
##
func damage(amount: int) -> void:
	if self is Player:
		self.iFrames = max(0.35, self.iFrames)
	$hitAndHeal.play("hit")
	setStat(
		STATS.CURRENT_HEALTH,
		clamp(getStat(STATS.CURRENT_HEALTH) - amount, 0, getStat(STATS.MAX_HEALTH))
	)

##
## Returns whether this entity is currently invincible.
##
## [return] `true` if [member iFrames] is greater than `0.0`, otherwise `false`.
##
func isInvincible() -> bool:
	return iFrames > 0

##
## Reduces current stamina down to a minimum of `0`.
##
## [param consumed] The amount of stamina to subtract.
##
func consumeStamina(consumed: int) -> void:
	setStat(
		STATS.CURRENT_STAMINA,
		clampi(getStat(STATS.CURRENT_STAMINA) - consumed, 0, getStat(STATS.MAX_STAMINA))
	)

##
## Restores stamina up to [constant STATS.MAX_STAMINA].
##
## [param granted] The amount of stamina to add.
##
func grantStamina(granted: int) -> void:
	setStat(
		STATS.CURRENT_STAMINA,
		clampi(getStat(STATS.CURRENT_STAMINA) + granted, 0, getStat(STATS.MAX_STAMINA))
	)

##
## Recalculates all derived stats based on current attributes and scaling curves.
##
## This method updates:
## - [constant STATS.MAX_HEALTH]
## - [constant STATS.MAX_STAMINA]
## - [constant STATS.STAMINA_RECHARGE]
## - [constant STATS.GROUND_SPEED]
## - [constant STATS.AIR_SPEED]
## - [constant STATS.FAST_FALL]
## - [constant STATS.DASH_COOLDOWN]
##
## It also adjusts current health and stamina so they remain valid relative to their
## recalculated maximums, then emits [signal statsChanged].
##
## Scaling sources used:
## - Vitality affects maximum health and maximum stamina.
## - Technique affects stamina recharge.
## - Agility affects ground speed, air speed, fast fall, and dash cooldown.
##
func updateStats() -> void:
	var prev: int = stats[STATS.MAX_HEALTH]
	stats[STATS.MAX_HEALTH] = baseStats[STATS.MAX_HEALTH] + int(scalingCurves[0].sample(stats[STATS.VITALITY]))
	if prev < stats[STATS.MAX_HEALTH]:
		stats[STATS.CURRENT_HEALTH] += stats[STATS.MAX_HEALTH] - prev
	else:
		stats[STATS.CURRENT_HEALTH] = min(stats[STATS.CURRENT_HEALTH], stats[STATS.MAX_HEALTH])

	var prev2: int = stats[STATS.MAX_STAMINA]
	stats[STATS.MAX_STAMINA] = baseStats[STATS.MAX_STAMINA] + int(scalingCurves[0].sample(stats[STATS.VITALITY]))
	if prev2 < stats[STATS.MAX_STAMINA]:
		stats[STATS.CURRENT_STAMINA] += stats[STATS.MAX_STAMINA] - prev
	else:
		stats[STATS.CURRENT_STAMINA] = min(stats[STATS.CURRENT_STAMINA], stats[STATS.MAX_STAMINA])

	stats[STATS.STAMINA_RECHARGE] = baseStats[STATS.STAMINA_RECHARGE] + floor(scalingCurves[2].sample(stats[STATS.TECHNIQUE]))
	stats[STATS.GROUND_SPEED] = baseStats[STATS.GROUND_SPEED] + int(scalingCurves[3].sample(stats[STATS.AGILITY]))
	stats[STATS.AIR_SPEED] = baseStats[STATS.AIR_SPEED] + int(scalingCurves[4].sample(stats[STATS.AGILITY]))
	stats[STATS.FAST_FALL] = baseStats[STATS.FAST_FALL] + int(scalingCurves[5].sample(stats[STATS.AGILITY]))
	stats[STATS.DASH_COOLDOWN] = baseStats[STATS.DASH_COOLDOWN] - int((100 * scalingCurves[7].sample(stats[STATS.AGILITY])))

	statsChanged.emit(stats)
