extends Node

##
## A finite state machine that manages transitions between [State] objects.
##
## This node keeps track of the currently active state through [member currentState].
## When a state assigns a value to its [member State.nextState], this machine:
## - Calls [method State.onExit] on the current state.
## - Switches to the next state.
## - Clears the previous state's [member State.nextState].
## - Calls [method State.onEnter] on the new current state.
## - Executes [method State.process] on the active state each frame.
##
## This class assumes each state follows the interface defined by [State].
##
class_name StateMachine

## The currently active [State].
##
## This state is entered during [method ready] and updated every frame through
## [method process].
@export var currentState: State

##
## Initializes the state machine by entering [member currentState].
##
## This should be called once before the state machine begins processing transitions.
## If this method is intended to run automatically when the node enters the scene tree,
## rename it to [method _ready].
##
func ready() -> void:
	currentState.onEnter()

##
## Updates the current state and handles pending transitions.
##
## If [member State.nextState] is set on [member currentState], this method performs
## the full state transition before updating the new active state.
##
## Transition flow:
## - Call [method State.onExit] on the current state.
## - Store the previous state in a temporary variable.
## - Replace [member currentState] with [member State.nextState].
## - Clear the previous state's [member State.nextState].
## - Call [method State.onEnter] on the new current state.
## - Call [method State.process] on the active state.
##
## [param delta] The frame delta time in seconds.
##
## If this method is intended to run automatically every frame, rename it to
## [method _process].
##
func process(delta: float) -> void:
	if currentState.nextState:
		#aaprint("%s has %s as its next state at %s" % [currentState.name,currentState.nextState.name, Time.get_time_string_from_system()])
		currentState.onExit()
		var prevState: State = currentState
		currentState = currentState.nextState
		prevState.nextState = null
		currentState.onEnter()
	currentState.process(delta)
