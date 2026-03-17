extends Area2D
class_name HazardArea
@export var isAbbys: bool = false
@export var areaDamage : int = 5
@export var knockBack : int = 200


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.iFrames = 0
		body.damage(areaDamage)
		if isAbbys:
			body.velocity = Vector2.ZERO
			body.set_physics_process(false)
			body.playerScreen.fadeScreen()
			await body.playerScreen.screen_fade_player.animation_finished
			body.global_position = body.lastSafePos
			body.playerScreen.unfadeScreen()
			body.set_physics_process(true)
		else:
			body.velocity = Vector2(cos(rotation+PI/2),sin(rotation+PI/2))*-knockBack
	elif body is Enemy:
		pass
			
