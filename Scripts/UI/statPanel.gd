extends Node
class_name StatPanel

func updateStatPanel(stats : Array[int]) -> void:
	#$edge/informationListings/className.text = playerReference.playerName
	$edge/informationListings/healthBar.max_value =stats[Player.STATS.MAX_HEALTH]
	$edge/informationListings/healthBar.value = stats[Player.STATS.CURRENT_HEALTH]
	$edge/informationListings/staminaBar.max_value = stats[Player.STATS.MAX_STAMINA]
	$edge/informationListings/staminaBar.value = stats[Player.STATS.CURRENT_STAMINA]
	if  stats[Player.STATS.HAS_DASH]:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.RED
	if stats[Player.STATS.HAS_DOUBLE_JUMP]:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.RED
	if  stats[Player.STATS.HAS_WALL_JUMP]:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.RED
	var attributeText : String = "
[table=2]
[cell][color=gold]Souls:[/color][/cell][cell][color=white]%s[/color][/cell]
[cell][color=red]Vitality:[/color][/cell][cell][color=white]%s[/color][/cell]
[cell][color=green]Agility:[/color][/cell][cell][color=white]%s[/color][/cell]
[cell][color=blue]Technique:[/color][/cell][cell][color=white]%s[/color][/cell]
[/table]
" % [
	stats[Player.STATS.SOULS],
	stats[Player.STATS.VITALITY],
	stats[Player.STATS.AGILITY],
	stats[Player.STATS.TECHNIQUE]
]
	$edge/informationListings/margin/stats/attributes.text = attributeText
	
