extends WanderingEnemyState

## The amount of time in seconds this [WanderingEnemy] will take before returning to [member Idle] [WanderingEnemyState] if the [Player] isn't in its vision.
@export var forgetTimeRange : Vector2 = Vector2(1, 2)
## By how much [member STAT.GROUND_SPEED] will be multiplied by when calculating [member velocity].
@export var chaseSpeedFactor : float = 1.33
## If the [WanderingEnemy] bypasses [member isKoopa] while chasing the player.
@export var ignoreLedges : bool = false


## A floating point initialized upon [method onEnter]. It's value is a random decimal number between [member forgetTimeRange].x and [member forgetTimeRange].y.
var currentForgetTime : float 
## A floating point value that is incremented by [member delta] when the [WanderingEnemy]'s [member playerVision], a [RayCast2D] node, is not colliding with a [Player]. Initialized to zero upon [method onEnter]. Upon reaching [member currentForgetTime], [WanderingEnemy] returns to [member Idle]
var playerNotInVision : float = 0.0


func onEnter() -> void:
	currentForgetTime = randf_range(forgetTimeRange.x,forgetTimeRange.y)

func process(_delta : float) -> void:
	if enemy.player_detector.is_colliding():
		playerNotInVision = 0 # Reset upon collision
	else:
		playerNotInVision += _delta
	if ((not ignoreLedges) and (enemy.isKoopa and not enemy.floor_check.is_colliding())) or enemy.wall_check.is_colliding() or  playerNotInVision >= currentForgetTime:
		nextState = $"../idle"
		enemy.forcedNextDirection = -sign(enemy.velocity.x)
		enemy.velocity.x = enemy.forcedNextDirection
		enemy.updateScale()
	else:
		enemy.velocity.x = enemy.getStat(Enemy.STATS.GROUND_SPEED)*chaseSpeedFactor*sign(enemy.getClosestPlayer().global_position.x-enemy.global_position.x)
	enemy.move_and_slide()
