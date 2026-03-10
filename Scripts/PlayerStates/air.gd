extends PlayerState

var basePlayerAirSpeed : int = 50
var basePlayerFastFallStrength : int = -100
var baseGravity : int = 300

func onEnter() -> void:
	animHandler.set("parameters/conditions/air", true)
	animHandler.set("parameters/air/blend_position", sign(player.velocity.y))

func process(_delta : float) -> void:
	var dirX : float = Input.get_axis(player.inputArr[0],player.inputArr[1])
	player.velocity.x = dirX*basePlayerAirSpeed*(1.0 + float(player.dexterity)/5.0)
	animHandler.set("parameters/air/blend_position",sign(player.velocity.y))
	if Input.is_action_just_pressed(player.inputArr[2]):
		player.velocity.y += (basePlayerFastFallStrength*(1.0 + float(player.dexterity)/10.0))*_delta
	player.velocity.y += baseGravity*_delta
	if player.is_on_floor():
		nextState = $"../ground"
	player.move_and_slide()

func onExit() -> void:
	animHandler.set("parameters/conditions/air", false)

func _input(event: InputEvent) -> void:
	if event.is_action_released(player.inputArr[3]):
		player.velocity.y *= 0.5
