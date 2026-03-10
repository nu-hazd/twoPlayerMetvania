extends Node




func _ready() -> void:
	$screensContainer/playerOneScreen/playerOneDisplay/subviewport/room.player_one.remote_transform_2d.remote_path = $screensContainer/playerOneScreen/playerOneDisplay/subviewport/p1Cam.get_path()
	$screensContainer/playerOneScreen/playerOneDisplay/subviewport/room.player_two.remote_transform_2d.remote_path = $screensContainer/playerTwoScreen/playerTwoDisplay/subviewport/p2Cam.get_path()
	$screensContainer/playerTwoScreen/playerTwoDisplay/subviewport.world_2d = $screensContainer/playerOneScreen/playerOneDisplay/subviewport.world_2d
