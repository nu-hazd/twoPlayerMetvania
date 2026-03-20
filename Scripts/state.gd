extends Node
class_name State

##
## A generic base class for finite-state-machine states.
##
## This class defines the common interface used by all states in the project.
## Inheriting classes are expected to override [method onEnter], [method onExit],
## and [method process] as needed.
##

## Stores the state that should be entered next.
##
## State-machine logic external to this class is expected to read this value and perform
## the actual transition when appropriate.
var nextState: State

##
## Called when leaving this state.
##
## Override this method in inheriting classes to implement cleanup logic, reset values,
## disconnect signals, or stop animations when the state is exited.
##
func onExit() -> void:
	pass

##
## Called when entering this state.
##
## Override this method in inheriting classes to implement initialization logic such as
## resetting timers, setting animation parameters, or preparing movement/state values.
##
func onEnter() -> void:
	pass

##
## Called every frame while this state is active.
##
## Override this method in inheriting classes to implement per-frame state behavior.
##
## [param _delta] The frame delta time in seconds.
##
func process(_delta: float) -> void:
	pass
