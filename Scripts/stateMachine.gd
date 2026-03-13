extends Node
class_name StateMachine

@export var currentState : State

func ready() -> void:
	currentState.onEnter()
func process(delta : float) -> void:
	if currentState.nextState:
		#aaprint("%s has %s as its next state at %s" % [currentState.name,currentState.nextState.name, Time.get_time_string_from_system()])
		currentState.onExit()
		var prevState : State = currentState
		currentState = currentState.nextState
		prevState.nextState = null
		currentState.onEnter()
	currentState.process(delta)
	
