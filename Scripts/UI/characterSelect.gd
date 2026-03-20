extends Panel


## A character-selection panel that allows a player to:
##
## - Choose a character skin.
## - Distribute attribute points.
## - Toggle ready status.
## - Unlock alternate playtest sprites through a hidden input sequence.
##
## This panel is driven by a [PlayerControls] resource and tracks the currently selected
## UI control through [member currentControl]. Navigation and interaction are handled in
## [method _process] using mapped player actions.
class_name CharacterSelect


## Emitted whenever [member isReady] changes.
signal readyChanged

## The [PlayerControls] resource used to read this panel's navigation and accept inputs.
@export var controls: PlayerControls

## The default spritesheet used for player skin selection.
const playerSpriteSheet: Texture2D = preload("res://Assets/Entities/Player/playerColorSprites.png")

## The alternate spritesheet unlocked through the hidden input sequence.
const playtesterSprites: Texture2D = preload("res://Assets/Entities/Player/playTestSprites.png")

## Whether this character slot is currently marked as ready.
var isReady: bool = false

## The currently highlighted UI [Control].
##
## This control is visually emphasized by scaling it up through [method changeCurrentControl].
var currentControl: Control = null

## The [AtlasTexture] currently used to display the selected skin.
var playerSkins: AtlasTexture

## The number of selectable skin columns available in the current spritesheet.
var skinSpriteSheetSize: int

## The currently selected skin index.
var currentSkin: int = 0

## The number of attribute points still available for distribution.
var availablePoints: int = 1

## The number of points assigned to each attribute in order:
## - vitality
## - agility
## - technique
var spentPointDistribution: Array[int] = [33, 33, 33]

##
## Input actions understood by [method actionPressed].
##
enum ACTIONS {
	UP, DOWN, LEFT, RIGHT, ACCEPT
}

## The required hidden input sequence used to unlock playtest sprites.
##
## Its values correspond to the input IDs pushed by [method pushStackAndCheck].
var requiredActions: Array[int] = [0, 0, 1, 1, 2, 2, 3, 3]

## Tracks the current progress of the hidden input sequence.
var cheatCodeStack: Array[int]

##
## Initializes the character-select panel.
##
## This method:
## - Updates displayed attribute text.
## - Sets the initial selected control to `"skin"`.
## - Enlarges the selected control.
## - Creates the default [member playerSkins] atlas from [member playerSpriteSheet].
## - Configures the visible region for a single skin preview.
## - Computes [member skinSpriteSheetSize].
## - Assigns the atlas texture to `$skin/atlas`.
##
func _ready() -> void:
	updateAttributeText()
	currentControl = find_child("skin")
	currentControl.scale = Vector2(1.25, 1.25)

	playerSkins = AtlasTexture.new()
	playerSkins.atlas = playerSpriteSheet
	playerSkins.region = Rect2(0, 0, 32, 32)

	skinSpriteSheetSize = int(playerSpriteSheet.get_size().x / 256)

	var atlas: TextureRect = $skin/atlas
	atlas.texture = playerSkins

##
## Polls player input every frame and converts it into menu actions.
##
## This method:
## - Checks directional and accept inputs from [member controls].
## - Pushes each input into [member cheatCodeStack] through [method pushStackAndCheck].
## - Dispatches the corresponding UI action through [method actionPressed].
##
## [param _delta] The frame delta time in seconds.
##
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(controls.up):
		pushStackAndCheck(0)
		actionPressed(ACTIONS.UP)
	elif Input.is_action_just_pressed(controls.down):
		pushStackAndCheck(1)
		actionPressed(ACTIONS.DOWN)
	elif Input.is_action_just_pressed(controls.left):
		pushStackAndCheck(2)
		actionPressed(ACTIONS.LEFT)
	elif Input.is_action_just_pressed(controls.right):
		pushStackAndCheck(3)
		actionPressed(ACTIONS.RIGHT)
	elif Input.is_action_just_pressed(controls.jump):
		pushStackAndCheck(4)
		actionPressed(ACTIONS.ACCEPT)

##
## Switches the skin-selection system to the hidden playtest spritesheet.
##
## This method:
## - Reveals `$Label`.
## - Resets [member currentSkin].
## - Sets [member availablePoints] to `30`.
## - Resets [member spentPointDistribution] to `[50, 50, 50]`.
## - Replaces the displayed atlas with [member playtesterSprites].
## - Updates the visible attribute text.
##
func togglePlayTestSprites() -> void:
	$Label.visible = true
	currentSkin = 0
	availablePoints = 30
	spentPointDistribution = [50, 50, 50]
	skinSpriteSheetSize = 4

	playerSkins = AtlasTexture.new()
	playerSkins.atlas = playtesterSprites
	playerSkins.region = Rect2(0, 0, 32, 32)

	updateAttributeText()

	var rect: TextureRect = $skin/atlas
	rect.texture = playerSkins

##
## Pushes an input token into [member cheatCodeStack] and checks whether the hidden
## input sequence is still valid.
##
## This method:
## - Appends the new action token.
## - Clears the stack if it becomes longer than [member requiredActions].
## - Clears the stack if the latest token does not match the expected sequence.
## - Calls [method togglePlayTestSprites] when the full sequence is matched.
##
## [param action] The encoded action token to append.
##
func pushStackAndCheck(action: int) -> void:
	cheatCodeStack.push_back(action)
	print(cheatCodeStack)

	if cheatCodeStack.size() > requiredActions.size():
		cheatCodeStack.clear()
	elif cheatCodeStack[cheatCodeStack.size() - 1] != requiredActions[cheatCodeStack.size() - 1]:
		cheatCodeStack.clear()

	if cheatCodeStack.size() == requiredActions.size():
		togglePlayTestSprites()

##
## Executes a UI action based on the provided [enum ACTIONS] value.
##
## Behavior by action:
## - [constant ACTIONS.ACCEPT]: toggles ready state.
## - [constant ACTIONS.UP]: moves focus to the top neighbor.
## - [constant ACTIONS.DOWN]: moves focus to the bottom neighbor.
## - [constant ACTIONS.LEFT]: changes skin left or removes an attribute point.
## - [constant ACTIONS.RIGHT]: changes skin right or adds an attribute point.
##
##
## [param action] The action to perform.
##
func actionPressed(action: ACTIONS):
	match action:
		ACTIONS.ACCEPT:
			toggleReady()

		ACTIONS.UP:
			var new_control: Control = currentControl.get_node(currentControl.focus_neighbor_top)
			changeCurrentControl(new_control)

		ACTIONS.DOWN:
			var new_control: Control = currentControl.get_node(currentControl.focus_neighbor_bottom)
			changeCurrentControl(new_control)

		ACTIONS.LEFT:
			if currentControl.name == "skin":
				skinLeft()
				if currentSkin == 1 and skinSpriteSheetSize == 4:
					$gobii.visible = true
				else:
					$gobii.visible = false
			elif int(currentControl.name) in [0, 1, 2]:
				deductPoint(int(currentControl.name))

		ACTIONS.RIGHT:
			if currentControl.name == "skin":
				skinRight()
				if currentSkin == 1 and skinSpriteSheetSize == 4:
					$gobii.visible = true
				else:
					$gobii.visible = false
			elif int(currentControl.name) in [0, 1, 2]:
				addPoint(int(currentControl.name))

##
## Updates the X position of [member playerSkins.region] to display the selected skin.
##
## [param skinIndex] The skin index to display.
##
## Does nothing if [param skinIndex] is out of bounds.
##
func setSkinRegion(skinIndex: int) -> void:
	if skinIndex < 0 or skinIndex >= skinSpriteSheetSize:
		return
	playerSkins.region.position.x = skinIndex * 256

##
## Returns a duplicate [AtlasTexture] representing the full selected skin sheet region.
##
## The returned texture uses the same atlas as [member playerSkins] but expands the
## region size to `256 x 288`.
##
## [return] A duplicated [AtlasTexture] with an expanded region size.
##
func getEntireAtlas() -> AtlasTexture:
	var result = playerSkins.duplicate()
	result.region.size = Vector2(256, 288)
	return result

##
## Advances to the next skin, wrapping around to `0` at the end.
##
func skinRight() -> void:
	if currentSkin == skinSpriteSheetSize - 1:
		currentSkin = 0
	else:
		currentSkin += 1
	setSkinRegion(currentSkin)

##
## Moves to the previous skin, wrapping around to the last index when at `0`.
##
func skinLeft() -> void:
	if currentSkin == 0:
		currentSkin = skinSpriteSheetSize - 1
	else:
		currentSkin -= 1
	setSkinRegion(currentSkin)

##
## Adds one point to the specified attribute if [member availablePoints] is greater than `0`.
##
## [param attribute] The attribute index to increase.
##
func addPoint(attribute: int) -> void:
	if availablePoints > 0:
		availablePoints -= 1
		spentPointDistribution[attribute] += 1
		updateAttributeText()

##
## Removes one point from the specified attribute if that attribute currently has more than `1`.
##
## [param attribute] The attribute index to decrease.
##
func deductPoint(attribute: int) -> void:
	if spentPointDistribution[attribute] > 1:
		availablePoints += 1
		spentPointDistribution[attribute] -= 1
		updateAttributeText()

##
## Refreshes the visible attribute and point text labels.
##
## This updates:
## - `$"ats/0"` with vitality text
## - `$"ats/1"` with agility text
## - `$"ats/2"` with technique text
## - `$pts` with remaining points
##
func updateAttributeText() -> void:
	$"ats/0".text = "-1 [color=red]VITALITY[color=white] +1 [br]%s" % spentPointDistribution[0]
	$"ats/1".text = "-1 [color=green]AGILITY[color=white] +1 [br]%s" % spentPointDistribution[1]
	$"ats/2".text = "-1 [color=blue]TECHNIQUE[color=white] +1 [br]%s" % spentPointDistribution[2]
	$pts.text = "PTS: %s" % availablePoints

##
## Toggles this slot's ready state.
##
## This method:
## - Moves focus to `$ready`.
## - Sets [member isReady] to `false` and colors `$ready` red if already ready.
## - Sets [member isReady] to `true` and colors `$ready` green if all points have been spent.
## - Emits [signal readyChanged].
##
func toggleReady() -> void:
	changeCurrentControl($ready)

	if isReady:
		$ready.modulate = Color.RED
		isReady = false
	elif availablePoints == 0:
		isReady = true
		$ready.modulate = Color.GREEN

	readyChanged.emit()

##
## Changes the currently highlighted control.
##
## This method restores the old [member currentControl] scale to `Vector2(1, 1)`,
## assigns [param newControl], then enlarges the new current control.
##
## [param newControl] The [Control] to highlight.
##
func changeCurrentControl(newControl: Control) -> void:
	currentControl.scale = Vector2(1, 1)
	currentControl = newControl
	currentControl.scale = Vector2(1.25, 1.25)
