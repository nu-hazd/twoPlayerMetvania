extends WanderingEnemyState

## The amount of time in seconds this [WanderingEnemy] will take before entering [Idle] [WanderingEnemyState]
@export var wanderTimeRange : Vector2 = Vector2(3, 5)
## The amount of time in seconds the [Player] must be continously seen by [visionRange] in order for this [WanderingEnemy] to enter [Chase] [WanderingEnemyState]
@export var wanderNoticeTime : float = 0.5
var wanderDirection : int = 1
var playerInVision : float = 0.0
var currentWonderItem : float = 0.0
var maxWanderTime : float
func onEnter() -> void:
	wanderDirection = sign(randi_range(-100,100))
	if wanderDirection == 0:
		wanderDirection = 1
	if enemy.forcedNextDirection:
		wanderDirection = enemy.forcedNextDirection
	state_anims.play("wander")
	maxWanderTime = randf_range(wanderTimeRange.x,wanderTimeRange.y)
	playerInVision = 0
	currentWonderItem = 0
	enemy.velocity.x = enemy.getStat(Enemy.STATS.GROUND_SPEED)*wanderDirection

func process(_delta : float) -> void:
	enemy.updateScale()
	currentWonderItem += _delta
	if enemy.player_detector.is_colliding():
		playerInVision += _delta
	else:
		playerInVision = 0
	if currentWonderItem >= maxWanderTime:
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
