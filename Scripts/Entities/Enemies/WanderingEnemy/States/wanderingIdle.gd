extends WanderingEnemyState
class_name IdleEnemyState

##
## A wandering-enemy state where the enemy remains still for a random amount of time
## before transitioning into either its wandering or chase behavior.
##
## While in this state, the enemy:
## - Stops all movement.
## - Plays the `"idle"` animation through [member state_anims].
## - Waits a random duration within [member idleTimeRange].
## - Transitions to the wander state after the idle duration expires.
## - Transitions to the chase state if the [Player] is seen continuously for at least
##   [member idleNoticeTime] seconds through [member enemy.player_detector].
##

## The inclusive range, in seconds, used to randomly determine how long the enemy
## remains idle before entering the wander state.
@export var idleTimeRange: Vector2 = Vector2(3, 5)

## The amount of uninterrupted time, in seconds, that the [Player] must remain visible
## to the enemy before this state transitions into the chase state.
@export var idleNoticeTime: float = 0.5

## Accumulates the amount of uninterrupted time, in seconds, that the [Player] has been
## visible to [member enemy.player_detector].
##
## This value is reset to `0.0` whenever the player is no longer detected.
## It is also reset during [method onEnter].
var playerInVision: float = 0.0

## The randomly selected idle duration, in seconds, that must elapse before this state
## transitions into the wander state.
##
## This value is assigned during [method onEnter] using [member idleTimeRange].
var maxIdleTime: float

## Tracks the total amount of time, in seconds, spent in this state since the last call
## to [method onEnter].
var currentIdleTime: float = 0.0

##
## Initializes the idle state.
##
## This method:
## - Plays the `"idle"` animation.
## - Stops enemy movement by setting [member enemy.velocity] to [constant Vector2.ZERO].
## - Randomizes [member maxIdleTime] within [member idleTimeRange].
## - Resets [member playerInVision].
## - Resets [member currentIdleTime].
##
func onEnter() -> void:
	state_anims.play("idle")
	enemy.velocity = Vector2.ZERO
	maxIdleTime = randf_range(idleTimeRange.x, idleTimeRange.y)
	playerInVision = 0.0
	currentIdleTime = 0.0

##
## Updates the idle-state behavior every frame.
##
## This method:
## - Increments [member currentIdleTime].
## - Checks whether [member enemy.player_detector] is colliding with the [Player].
## - Increments [member playerInVision] only while the player remains continuously visible.
## - Transitions to the wander state once [member currentIdleTime] reaches [member maxIdleTime].
## - Transitions to the chase state once [member playerInVision] reaches [member idleNoticeTime].
## - Calls [method CharacterBody2D.move_and_slide] on the enemy.
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	currentIdleTime += _delta

	if enemy.player_detector.is_colliding():
		playerInVision += _delta
	else:
		playerInVision = 0.0

	if currentIdleTime >= maxIdleTime:
		nextState = $"../wander"

	if playerInVision >= idleNoticeTime:
		nextState = $"../chase"

	enemy.move_and_slide()
