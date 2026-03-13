extends CharacterBody2D
class_name Enemy
var hp : int = 100
var technique : int = 25
func damage(amount : int) -> void:
	hp = max(0, hp-amount)
	print("Damaged: %s" % amount) 
