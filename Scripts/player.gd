extends CharacterBody2D
class_name Player

@onready var remote_transform_2d: RemoteTransform2D = $RemoteTransform2D
@export var playerControls : PlayerControls
@onready var state_machine: StateMachine = $StateMachine

@export var vitality : int = 1 # Max health, inventory space, 
@export var technique : int = 1 # Weapon damage, weapon attack speed
@export var dexterity : int = 1 # Move speed, jump height, dash cooldown, turn speed, air control
# var arcane : int = 1 # luck, increased difficulty

var inputArr : Array[String]

var hasDoubleJump : bool = false
var hasDash : bool = false
var hasWallJump : bool = false

var dashCooldown : float = 0.0

func _ready() -> void:
	for state : PlayerState in $StateMachine.get_children():
		state.player = self
	state_machine.ready()
	inputArr = playerControls.playerInputArray
func _physics_process(delta: float) -> void:
	dashCooldown = max(0, dashCooldown-delta)
	if velocity.x:
		$Sprite2D.scale.x = sign(velocity.x)
	state_machine.process(delta)

func canDash() -> bool:
	return hasDash and dashCooldown == 0.0
