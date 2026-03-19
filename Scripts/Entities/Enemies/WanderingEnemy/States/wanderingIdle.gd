extends WanderingEnemyState

## The amount of time in seconds this [WanderingEnemy] will take before entering [member Wander] [WanderingEnemyState]
@export var idleTimeRange : Vector2 = Vector2(3, 5)
## The amount of time in seconds the [Player] must be continously seen by [member playerDetector] in order for this [WanderingEnemy] to enter [member Chase] [WanderingEnemyState]
@export var idleNoticeTime : float  = 0.5
var playerInVision : float = 0.0
var currentIdleItem : float = 0.0
var maxIdleTime : float
func onEnter() -> void:
	state_anims.play("idle")
	enemy.velocity = Vector2.ZERO
	maxIdleTime = randf_range(idleTimeRange.x,idleTimeRange.y)
	playerInVision = 0
	currentIdleItem = 0

func process(_delta : float) -> void:

	currentIdleItem += _delta
	if enemy.player_detector.is_colliding():
		playerInVision += _delta
	else:
		playerInVision = 0
	if currentIdleItem >= maxIdleTime:
		nextState = $"../wander"
	if playerInVision >= idleNoticeTime:
		nextState = $"../chase"
	enemy.move_and_slide()

	
