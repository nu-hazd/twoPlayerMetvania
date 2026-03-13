extends PlayerState



@export var clingGravity : int = 100
@export var clingGravityIfUp : int = 300
@export var jumpKickStrength : Vector2i = Vector2i(100,-200)
@export var unclingSpeed : int = 50
var enterWallDir : float
func onEnter() -> void:
	nextState = null
	player.usedDoubleJump = false
	enterWallDir = int($"../../right".is_colliding()) - int($"../../left".is_colliding())
	if not enterWallDir:
		nextState = $"../ground"
	animHandler.set("parameters/conditions/cling", true)
	

func process(_delta : float) -> void:
	var collidingWithWalls : int = int($"../../right".is_colliding()) - int($"../../left".is_colliding())
	if not collidingWithWalls:
		nextState = $"../air"
	elif player.wantsJump and player.getStat(Player.STATS.CURRENT_STAMINA) >=1:
		player.consumeStamina(1)
		player.wantsJump = 0
		player.velocity = jumpKickStrength*Vector2i(-collidingWithWalls,1)
		nextState = $"../air"
	elif Input.is_action_just_pressed(player.playerControls.playerInputArray[4]) and player.canDash() and Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1]) != enterWallDir:
		nextState = $"../dash"
	elif Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1]) != enterWallDir:
		player.velocity.x = Input.get_axis(player.playerControls.playerInputArray[0],player.playerControls.playerInputArray[1])*unclingSpeed
	elif player.is_on_floor():
		nextState  = $"../dash"
	if player.velocity.y < 0:
		player.velocity.y += clingGravityIfUp*_delta
	else:
		player.velocity.y += clingGravity*_delta
	player.move_and_slide()

func onExit() -> void:
	player.disableWalljump = 0.1
	animHandler.set("parameters/conditions/cling", false)
