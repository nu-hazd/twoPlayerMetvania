extends Node2D
class_name TempRoom

@onready var player_one: Player = $playerOne
@onready var player_two: Player = $playerTwo



func _on_upgrade_body_exited(body: Node2D) -> void:
	if body is Player:
		body.setStat(Player.STATS.HAS_DOUBLE_JUMP,false) 
		body.setStat(Player.STATS.HAS_DASH,false) 
		body.setStat(Player.STATS.HAS_WALL_JUMP,false)
		body.setStat(Player.STATS.AGILITY, 100)
		body.setStat(Player.STATS.TECHNIQUE, 100)
		body.setStat(Player.STATS.VITALITY, 100)
		body.updateStats()

func _on_reset_body_entered(body: Node2D) -> void:
	if body is Player:
		body.setStat(Player.STATS.HAS_DOUBLE_JUMP,true) 
		body.setStat(Player.STATS.HAS_DASH,true) 
		body.setStat(Player.STATS.HAS_WALL_JUMP,true) 
		body.setStat(Player.STATS.AGILITY, 50)
		body.setStat(Player.STATS.TECHNIQUE, 50)
		body.setStat(Player.STATS.VITALITY, 50)
		body.updateStats()

func _on_downgrade_body_entered(body: Node2D) -> void:
	if body is Player:
		body.setStat(Player.STATS.AGILITY, 1)
		body.setStat(Player.STATS.TECHNIQUE, 1)
		body.setStat(Player.STATS.VITALITY, 1)
		body.updateStats()
