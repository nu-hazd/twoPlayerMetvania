extends WanderingEnemyState

## The amount of time in seconds this [WanderingEnemy] will take before returning to [member Idle] [WanderingEnemyState] if the [Player] isn't in its vision.
@export var forgetTimeRange : Vector2 = Vector2(1, 2)
## By how much [member STAT.GROUND_SPEED] will be multiplied by when calculating [member velocity].
@export var chaseSpeedFactor : float = 1.33
## If the [WanderingEnemy] bypasses [member isKoopa] while chasing the player.
@export var ignoreLedges : bool = false

var playerInVision : float = 0.0
var currentForgetTime : float 

func onEnter() -> void:
	currentForgetTime = randf_range(forgetTimeRange.x,forgetTimeRange.y)

func process(_delta : float) -> void:
	if enemy.player_detector.is_colliding():
		playerInVision = 0
	else:
		playerInVision += _delta
	if ((not ignoreLedges) and (enemy.isKoopa and not enemy.floor_check.is_colliding())) or enemy.wall_check.is_colliding() or  playerInVision >= currentForgetTime:
		nextState = $"../idle"
		enemy.forcedNextDirection = -sign(enemy.velocity.x)
		enemy.velocity.x = enemy.forcedNextDirection
		enemy.updateScale()
	else:
		enemy.velocity.x = enemy.getStat(Enemy.STATS.GROUND_SPEED)*chaseSpeedFactor*sign(enemy.getClosestPlayer().global_position.x-enemy.global_position.x)
	enemy.move_and_slide()
