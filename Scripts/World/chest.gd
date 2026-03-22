extends Node2D
class_name Chest

enum TIER { COMMON, RARE, LEGENDARY }
@export var tier : TIER = TIER.COMMON
var rigidBodyNode : Node2D
var origin : Vector2
