extends HBoxContainer
class_name PlayerScreen

@export var statPanel : StatPanel
@onready var screen_fade_player: AnimationPlayer = $displayContainer/screenFadePlayer
@onready var player_cam: Camera2D = $displayContainer/playerDisplay/playerViewport/playerCam
@onready var player_viewport: SubViewport = $displayContainer/playerDisplay/playerViewport

func fadeScreen() -> void:
	screen_fade_player.play("fade")
func unfadeScreen() -> void:
	screen_fade_player.play("unfade")
