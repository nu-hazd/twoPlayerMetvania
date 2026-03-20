extends EnemyState
class_name WanderingEnemyState

##
## A base state class for enemy states that require direct access to a [WanderingEnemy].
##
## This class extends [EnemyState] and provides inheriting states with a strongly-typed
## reference to the owning [WanderingEnemy] through [member enemy].
##
## Typical inheritors include idle, wandering, chase, and similar movement-related states.
##

## A typed reference to the [WanderingEnemy] that owns this state.
##
## This variable is expected to be assigned externally, usually by the enemy's state
## machine or initialization logic.
var enemy: WanderingEnemy
