extends Area2D
class_name Door

@export var id : String = "zero To one"
var enabled : bool = true
var parentRoom : Room

@export var targetDoor : Door
@export var arrival_pos: Marker2D 
var doNotInteract : Array[Player]
signal playerEnteredDoor(player : Player, targetDoor : Door, enteredDoor : Door)


func disableDoor() -> void:
	enabled = false
func enableDoor() -> void:
	enabled = true



func _on_body_entered(body: Node2D) -> void:
	if body is Player and enabled and not doNotInteract.has(body):
		doNotInteract.push_back(body)
		if not $clear.is_stopped():
			$clearSecond.start()
		$clear.start()
		playerEnteredDoor.emit(body, targetDoor)

func _on_clear_timeout() -> void:
	doNotInteract.pop_front()
func _on_clear_second_timeout() -> void:
	doNotInteract.pop_front()
