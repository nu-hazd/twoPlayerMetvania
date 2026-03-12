extends Node


var p1 : Player
var p2 : Player

func _ready() -> void:
	p1 = $screensContainer/playerOneScreen/playerOneDisplay/subviewport/room.player_one
	p2 = $screensContainer/playerOneScreen/playerOneDisplay/subviewport/room.player_two
	p1.remote_transform_2d.remote_path = $screensContainer/playerOneScreen/playerOneDisplay/subviewport/p1Cam.get_path()
	p2.remote_transform_2d.remote_path = $screensContainer/playerTwoScreen/playerTwoDisplay/subviewport/p2Cam.get_path()
	$screensContainer/playerTwoScreen/playerTwoDisplay/subviewport.world_2d = $screensContainer/playerOneScreen/playerOneDisplay/subviewport.world_2d
	p1.statsChanged.connect($screensContainer/playerOneScreen/playerOneStatPanel.updateStatPanel)
	p2.statsChanged.connect($screensContainer/playerTwoScreen/playerTwoStatPanel.updateStatPanel)
	p1.statsChanged.emit(p1.stats)
	p2.statsChanged.emit(p2.stats)
