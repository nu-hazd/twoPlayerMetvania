extends State
class_name EnemyState
##
## A base state for enemy-specific states.
##
## This class extends [State] and provides common animation-related references used by
## enemy states, such as an [AnimationPlayer] and an [AnimationTree].
##
## Inheriting states can use:
## - [member state_anims] for direct animation playback.
## - [member anim_handler] for AnimationTree parameter control.
##
## Reference to the [AnimationPlayer] responsible for state-specific animations.
@onready var state_anims: AnimationPlayer = $"../../stateAnims"
## Reference to the [AnimationTree] used for blend spaces, conditions, and other
## animation-state parameters.
@onready var anim_handler: AnimationTree =  $"../../animHandler"
