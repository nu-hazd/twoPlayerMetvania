extends Enemy
##
## An [Enemy] who walks horizontally, chasing a [Player] upon [member visionRange] colliding.
##
## Whether this [Enemy] walks off borders is determined by the [member isKoopa] boolean value.
class_name WanderingEnemy
@export var isKoopa : bool = true 
@onready var player_detector: RayCast2D = $playerDetector
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var floor_check: RayCast2D = $floorCheck
@onready var wall_check: RayCast2D = $wallCheck
@onready var contactKnockback : int = 200

var forcedNextDirection : int = 0
var inContactRange : Array[Player]

func _ready() -> void:
	super._ready()
	if not isKoopa:
		floor_check.enabled = false
func _physics_process(delta: float) -> void:
	updateScale()
	velocity += get_gravity()*delta
	for plyr : Player in inContactRange:
		if not plyr.isInvincible():
			plyr.damage(self.getStat(STATS.TECHNIQUE))
			var dir : Vector2 = (plyr.global_position - global_position).normalized()
			dir.y *= 0.33
			plyr.velocity = dir*contactKnockback
	state_machine.process(delta)
func updateScale() -> void:
	if velocity.x:
		sprite_2d.scale.x = sign(velocity.x)
		player_detector.scale.x = sign(velocity.x)
		wall_check.scale.x = sign(velocity.x)
		floor_check.scale.x = sign(velocity.x)

func _on_contact_damage_body_entered(body: Node2D) -> void:
	if body is Player:
		inContactRange.push_back(body)

func _on_contact_damage_body_exited(body: Node2D) -> void:
	if body is Player and inContactRange.has(body):
		inContactRange.erase(body)
