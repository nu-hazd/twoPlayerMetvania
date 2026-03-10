extends PlayerState

var basePlayerSpeed : int = 100
var basePlayerJumpStrength : int = -200


func onEnter() -> void:
	animHandler.set("parameters/conditions/ground", true)
	animHandler.set("parameters/ground/blend_position",sign(player.velocity.x))

func process(_delta : float) -> void:
	if not player.is_on_floor():
		nextState = $"../air"
	if Input.is_action_just_pressed(player.inputArr[3]):
		player.velocity.y += basePlayerJumpStrength*(1.0 + float(player.dexterity)/10.0)
	var dirX : float = Input.get_axis(player.inputArr[0],player.inputArr[1])
	player.velocity.x = dirX*basePlayerSpeed*(1.0 + float(player.dexterity)/20.0)
	animHandler.set("parameters/ground/blend_position",sign(player.velocity.x))
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/ground", false)
