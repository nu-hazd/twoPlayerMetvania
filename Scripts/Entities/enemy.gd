extends StatEntity
##
##	Asbtract class representing all Enemies.
##	Contains useful methods for decision making, pathfinding.

class_name Enemy
@onready var health_bar: ProgressBar = $healthBar
@export var onDeatItemDrops : Dictionary[ItemInfo,int]
@onready var death_anim: AnimationPlayer = $deathAnim

var playerReferences : Array[Player]
signal enemyDied(pos : Vector2, items : Dictionary[ItemInfo,int])

func _ready() -> void:
	super._ready()
	for state : EnemyState in state_machine.get_children():
		state.enemy = self
	state_machine.currentState.onEnter()
	self.statsChanged.connect(updateHealthbar)
	updateHealthbar(self.stats)
func startDeath() -> void:
	state_machine.currentState = $StateMachine/death
	death_anim.play("death")
	velocity = Vector2.ZERO
	set_physics_process(false)
func dead() -> void:
	enemyDied.emit(self.global_position, onDeatItemDrops)
	self.queue_free()
func updateHealthbar(_sts : Array[int]) -> void:
	if getStat(STATS.CURRENT_HEALTH) <= 0:
		startDeath()
	$healthBar.value = getStat(STATS.CURRENT_HEALTH)
	$healthBar.max_value = getStat(STATS.MAX_HEALTH)
func getClosestPlayer() -> Player:
	if global_position.distance_to(playerReferences[0].global_position) <= global_position.distance_to(playerReferences[1].global_position):
		return playerReferences[0]
	else:
		return playerReferences[1]
		
