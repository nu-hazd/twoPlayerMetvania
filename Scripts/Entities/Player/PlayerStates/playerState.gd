extends State
## A base state class for player-specific states.
##
## This class extends [State] and provides inheriting player states with:
## - A typed reference to the owning [Player] through [member player].
## - A reference to the player's [AnimationTree] through [member animHandler].
##
## Player state scripts such as movement, jump, dash, attack, or idle states can inherit
## from this class to access shared player-specific references.
##

## A typed reference to the [Player] that owns this state.
##
## This variable is expected to be assigned externally, typically by the player's
## state machine or initialization logic.
class_name PlayerState
var player: Player

## Reference to the player's [AnimationTree].
##
## This can be used by inheriting states to update animation conditions, blend values,
## and other animation parameters.
@onready var animHandler: AnimationTree = $"../../AnimationTree"
