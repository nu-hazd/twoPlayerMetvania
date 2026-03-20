extends Resource

##
## A resource describing how an [ItemPickup] should be configured when spawned.
##
## This resource stores the visual, physical, and gameplay data needed by
## [method ItemPickup.setup], including:
## - The sprite-sheet coordinates used for display.
## - The pickup type from [enum ItemPickup.TYPES].
## - The display scale applied to the pickup range node.
## - The rigid-body mass of the spawned pickup.
##
## Instances of this resource can be used as keys in item-spawn dictionaries for
## systems such as [ItemSpawner].
class_name ItemInfo

## The top-left coordinates, in pixels, of this item's sprite region inside its atlas.
##
## This value is assigned to the pickup sprite's region position during
## [method ItemPickup.setup].
@export var coords: Vector2 = Vector2(64, 16)

## The gameplay type of the item represented by this resource.
##
## This determines what reward the [ItemPickup] grants when collected.
@export var type: ItemPickup.TYPES = ItemPickup.TYPES.S_COIN

## The visual scale applied to the spawned pickup's range node.
##
## This is assigned during [method ItemPickup.setup].
@export var scale: Vector2 = Vector2(1, 1)

## The rigid-body mass assigned to the spawned pickup.
##
## This affects how the pickup behaves physically when launched or attracted.
@export var mass: float = 1.0
