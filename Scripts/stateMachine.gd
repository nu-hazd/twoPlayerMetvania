extends Node
class_name StateMachine

@export var currentState : State

func ready() -> void:
	currentState.onEnter()
func process(delta : float) -> void:
	if currentState.nextState:
		currentState.onExit()
		var prevState : State = currentState
		currentState = currentState.nextState
		prevState.nextState = null
		currentState.onEnter()
	currentState.process(delta)
	
