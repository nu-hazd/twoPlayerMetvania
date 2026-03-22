extends WanderingEnemyState
## A wandering state where a [WanderingEnemy] moves horizontally for a random duration
## until it decides to idle, notices the [Player], or reaches an obstacle or ledge.
##
## While in this state, the enemy:
## - Selects a horizontal movement direction.
## - Plays the `"wander"` animation through [member state_anims].
## - Moves using its ground speed stat.
## - Transitions to the idle state after [member maxWanderTime] expires.
## - Transitions to the chase state if the [Player] is seen continuously for at least
##   [member wanderNoticeTime] seconds.
## - Returns to idle and reverses direction if blocked by a wall, or if it is a koopa-like
##   enemy and detects no floor ahead.
##
class_name WanderEnemyState


## The inclusive range, in seconds, used to randomly determine how long the enemy
## remains in the wandering state before entering the idle state.
@export var wanderTimeRange: Vector2 = Vector2(3, 5)

## The amount of uninterrupted time, in seconds, that the [Player] must remain visible
## to [member WanderingEnemy.player_detector] before this state transitions into the chase state.
@export var wanderNoticeTime: float = 0.5

## The horizontal movement direction used during wandering.
##
## This is typically `-1` for left or `1` for right.
var wanderDirection: int = 1

## Accumulates the amount of uninterrupted time, in seconds, that the [Player] has been
## visible to [member enemy.player_detector].
##
## This value resets to `0.0` whenever the player is no longer detected.
var playerInVision: float = 0.0

## Tracks the elapsed time, in seconds, spent in this wandering cycle.
##
## This value is reset during [method onEnter] and incremented every frame in
## [method process].
var currentWonderTime: float = 0.0

## The randomly selected duration, in seconds, that the enemy will spend wandering
## before transitioning back to the idle state.
##
## This value is assigned during [method onEnter] using [member wanderTimeRange].
var maxWanderTime: float

##
## Initializes the wandering state.
##
## This method:
## - Chooses a random horizontal direction.
## - Replaces a zero direction with `1`.
## - Uses [member enemy.forcedNextDirection] if one has been preset.
## - Plays the `"wander"` animation.
## - Randomizes [member maxWanderTime] within [member wanderTimeRange].
## - Resets [member playerInVision].
## - Resets [member currentWonderTime].
## - Sets horizontal velocity using the enemy's ground speed stat.
##
func onEnter() -> void:
	wanderDirection = sign(randi_range(-100, 100))
	if wanderDirection == 0:
		wanderDirection = 1
	if enemy.forcedNextDirection:
		wanderDirection = enemy.forcedNextDirection

	state_anims.play("wander")
	maxWanderTime = randf_range(wanderTimeRange.x, wanderTimeRange.y)
	playerInVision = 0.0
	currentWonderTime = 0.0
	enemy.velocity.x = enemy.getStat(Enemy.STATS.GROUND_SPEED) * wanderDirection

##
## Updates the wandering-state behavior every frame.
##
## This method:
## - Updates the enemy's facing scale through [method enemy.updateScale].
## - Increments [member currentWonderTime].
## - Tracks continuous player visibility through [member enemy.player_detector].
## - Transitions to the idle state when [member currentWonderTime] reaches [member maxWanderTime].
## - Transitions to the chase state when [member playerInVision] reaches [member wanderNoticeTime].
## - Returns to the idle state and reverses direction if blocked by a wall.
## - Returns to the idle state and reverses direction if the enemy is koopa-like and no
##   floor is detected ahead.
## - Calls [method CharacterBody2D.move_and_slide] on the enemy.
##
## When reversing direction due to terrain or collision, [member enemy.forcedNextDirection]
## is updated so the next state entry preserves the new intended direction.
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	enemy.updateScale()
	currentWonderTime += _delta

	if enemy.player_detector.is_colliding():
		playerInVision += _delta
	else:
		playerInVision = 0.0

	if currentWonderTime >= maxWanderTime:
		nextState = $"../idle"

	if playerInVision >= wanderNoticeTime:
		nextState = $"../chase"
		enemy.forcedNextDirection = sign(enemy.velocity.x)
	elif (enemy.isKoopa and not enemy.floor_check.is_colliding()) or enemy.wall_check.is_colliding():
		nextState = $"../idle"
		enemy.forcedNextDirection = -sign(enemy.velocity.x)
		enemy.velocity.x = enemy.forcedNextDirection
		enemy.updateScale()
	enemy.move_and_slide()
