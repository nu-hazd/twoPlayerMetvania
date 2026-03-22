extends Resource

## A resource that stores the input action names used by a specific player.
##
## This resource maps gameplay actions to the string names registered in the project's
## Input Map. It is used by systems such as [Player] and [CharacterSelect] to read
## player-specific controls without hardcoding action names directly into scripts.
##
## Stored actions include:
## - Movement directions
## - Jump
## - Dash
## - Two weapon-use actions
##
## Multiple instances of this resource can be created to support different players,
## input layouts, or control schemes.
class_name PlayerControls

## The Input Map action name used for moving left.
@export var left: String = "p1_l"

## The Input Map action name used for moving right.
@export var right: String = "p1_r"

## The Input Map action name used for moving up.
@export var up: String = "p1_u"

## The Input Map action name used for moving down.
@export var down: String = "p1_d"

## The Input Map action name used for jumping.
@export var jump: String = "p1_jump"

## The Input Map action name used for dashing.
@export var dash: String = "p1_dash"

## The Input Map action name used for using weapon slot 1.
@export var useWeapon1: String = "p1_w1"

## The Input Map action name used for using weapon slot 2.
@export var useWeapon2: String = "p1_w2"
