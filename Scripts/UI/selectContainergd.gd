extends Panel
class_name SelectContainer

##
## A container panel that coordinates multiple [CharacterSelect] panels and emits a signal
## once all participating players are ready.
##
## This class currently manages two character-select panels:
## - [member p_one_select]
## - [member p_two_select]
##
## When both panels report that they are ready, [signal playersAreReady] is emitted with:
## - The selected stat distributions for each player.
## - The selected full sprite atlases for each player.
##

## Reference to player one's [CharacterSelect] panel.
@onready var p_one_select: CharacterSelect = $customizeScreens/pOneSelect

## Reference to player two's [CharacterSelect] panel.
@onready var p_two_select: CharacterSelect = $customizeScreens/pTwoSelect

## Emitted when both character-select panels are ready.
##
## [param stats] An array containing each player's spent point distribution.
## [param spriteAtlas] An array containing each player's selected [AtlasTexture].
signal playersAreReady(stats: Array[Array], spriteAtlas: Array[AtlasTexture])

##
## Initializes the selection container.
##
## This method connects the [signal CharacterSelect.readyChanged] signal from both
## [member p_one_select] and [member p_two_select] to [method checkReadiness].
##
func _ready() -> void:
	p_one_select.readyChanged.connect(checkReadiness)
	p_two_select.readyChanged.connect(checkReadiness)

##
## Checks whether all managed players are ready.
##
## If both [member p_one_select] and [member p_two_select] have [member CharacterSelect.isReady]
## set to `true`, this method:
## - Builds an array of their attribute point distributions.
## - Builds an array of their selected full sprite atlases.
## - Emits [signal playersAreReady] with both arrays.
##
func checkReadiness() -> void:
	if p_one_select.isReady and p_two_select.isReady:
		var sts: Array[Array] = [
			p_one_select.spentPointDistribution,
			p_two_select.spentPointDistribution
		]
		var txt: Array[AtlasTexture] = [
			p_one_select.getEntireAtlas(),
			p_two_select.getEntireAtlas()
		]

		playersAreReady.emit(
			sts,
			txt
		)
