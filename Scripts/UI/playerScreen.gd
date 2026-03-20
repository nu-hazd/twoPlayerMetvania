extends HBoxContainer
class_name PlayerScreen

##
## A UI container responsible for displaying an individual player's view and related
## screen effects.
##
## This class provides:
## - A reference to the player's [StatPanel] through [member statPanel].
## - Access to the player's [Camera2D] and [SubViewport].
## - Screen fade controls through [member screen_fade_player].
## - Camera offset animation controls through [member camera_offset].
##
## It is used by the [Player] for visual transitions such as fading the screen and
## shifting the camera downward while crouching.
##

## Reference to the [StatPanel] associated with this player's display.
@export var statPanel: StatPanel

## The [AnimationPlayer] responsible for screen fade transitions.
@onready var screen_fade_player: AnimationPlayer = $displayContainer/screenFadePlayer

## The [Camera2D] used inside this player's viewport.
@onready var player_cam: Camera2D = $displayContainer/playerDisplay/playerViewport/playerCam

## The [SubViewport] that renders this player's world view.
@onready var player_viewport: SubViewport = $displayContainer/playerDisplay/playerViewport

## The [AnimationPlayer] responsible for camera offset animations, such as crouch shifting.
@onready var camera_offset: AnimationPlayer = $displayContainer/cameraOffset

##
## Plays the screen fade animation.
##
## This uses [member screen_fade_player] to play the `"fade"` animation.
##
func fadeScreen() -> void:
	screen_fade_player.play("fade")

##
## Plays the screen unfade animation.
##
## This uses [member screen_fade_player] to play the `"unfade"` animation.
##
func unfadeScreen() -> void:
	screen_fade_player.play("unfade")

##
## Plays the downward camera-shift animation.
##
## This uses [member camera_offset] to play the `"shift"` animation.
## It is typically called when the player enters a crouch state.
##
func shiftDown() -> void:
	camera_offset.play("shift")

##
## Restores the camera offset by playing the shift animation in reverse.
##
## This is typically called when the player exits a crouch state.
##
func restShift() -> void:
	camera_offset.play_backwards("shift")
