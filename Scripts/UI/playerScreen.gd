extends HBoxContainer
class_name PlayerScreen

@export var statPanel : StatPanel
@onready var screen_fade_player: AnimationPlayer = $displayContainer/screenFadePlayer
@onready var player_cam: Camera2D = $displayContainer/playerDisplay/playerViewport/playerCam
@onready var player_viewport: SubViewport = $displayContainer/playerDisplay/playerViewport
@onready var camera_offset: AnimationPlayer = $displayContainer/cameraOffset

func fadeScreen() -> void:
	screen_fade_player.play("fade")
func unfadeScreen() -> void:
	screen_fade_player.play("unfade")
func shiftDown() -> void:
	camera_offset.play("shift")
func restShift() -> void:
	camera_offset.play_backwards("shift")
