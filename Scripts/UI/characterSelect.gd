extends Panel
class_name CharacterSelect
signal readyChanged
@export var controls : PlayerControls
const playerSpriteSheet : Texture2D = preload("res://Assets/Entities/Player/playerColorSprites.png")
const playtesterSprites : Texture2D = preload("res://Assets/Entities/Player/playTestSprites.png")
var isReady : bool = false
var currentControl : Control = null
var playerSkins : AtlasTexture 
var skinSpriteSheetSize : int
var currentSkin : int = 0
var availablePoints : int = 1
var spentPointDistribution : Array[int] = [50,50,50]
enum ACTIONS {
	UP, DOWN, LEFT, RIGHT, ACCEPT
}

var requiredActions : Array[int] = [0, 0, 1, 1, 2, 2, 3, 3] 
var cheatCodeStack : Array[int]


func _ready() -> void:
	updateAttributeText()
	currentControl = find_child("skin")
	currentControl.scale = Vector2(1.25, 1.25)
	playerSkins = AtlasTexture.new()
	playerSkins.atlas = playerSpriteSheet
	playerSkins.region = Rect2(0, 0, 32, 32)
	skinSpriteSheetSize = int(playerSpriteSheet.get_size().x / 256 )
	var atlas : TextureRect = $skin/atlas
	atlas.texture = playerSkins
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

func togglePlayTestSprites() -> void:
	$Label.visible = true
	currentSkin = 0
	availablePoints += 30
	skinSpriteSheetSize = 4
	playerSkins = AtlasTexture.new()
	playerSkins.atlas = playtesterSprites
	playerSkins.region = Rect2(0, 0, 32, 32)
	var rect : TextureRect = $skin/atlas
	rect.texture = playerSkins
func pushStackAndCheck(action : int) -> void:
	cheatCodeStack.push_back(action)
	print(cheatCodeStack)
	if cheatCodeStack.size() > requiredActions.size():
		cheatCodeStack.clear()
	elif cheatCodeStack[cheatCodeStack.size()-1] != requiredActions[cheatCodeStack.size()-1]:
		cheatCodeStack.clear()
	if cheatCodeStack.size() == requiredActions.size():
		togglePlayTestSprites()

func actionPressed(action : ACTIONS):
	match action:
		ACTIONS.ACCEPT:
			toggleReady()
		ACTIONS.UP:
			var new_control : Control = currentControl.get_node(currentControl.focus_neighbor_top) 
			changeCurrentControl(new_control)
		ACTIONS.DOWN:
			var new_control : Control = currentControl.get_node(currentControl.focus_neighbor_bottom) 
			changeCurrentControl(new_control)
		ACTIONS.LEFT:
			if currentControl.name == "skin":
				skinLeft()
			elif int(currentControl.name) in [0,1,2]:
				deductPoint(int(currentControl.name))
		ACTIONS.RIGHT:
			if currentControl.name == "skin":
				skinRight()
			elif int(currentControl.name) in [0,1,2]:
				addPoint(int(currentControl.name))

func setSkinRegion(skinIndex : int) -> void:
	if skinIndex < 0 or skinIndex >= skinSpriteSheetSize:
		return
	playerSkins.region.position.x = skinIndex*256 

func getEntireAtlas() -> AtlasTexture:
	var result = playerSkins.duplicate()
	result.region.size = Vector2(256,288)
	return result
func skinRight() -> void:
	if currentSkin == skinSpriteSheetSize - 1:
		currentSkin = 0
	else:
		currentSkin += 1
	setSkinRegion(currentSkin)
func skinLeft() -> void:
	if currentSkin == 0:
		currentSkin = skinSpriteSheetSize - 1
	else:
		currentSkin -= 1
	setSkinRegion(currentSkin)
func addPoint(attribute : int) -> void:
	if availablePoints > 0:
		availablePoints-=1
		spentPointDistribution[attribute]+=1
		updateAttributeText()
func deductPoint(attribute : int) -> void:
	if spentPointDistribution[attribute] > 1:
		availablePoints+=1
		spentPointDistribution[attribute]-=1
		updateAttributeText()

func updateAttributeText() -> void:
	$"ats/0".text = "-1 [color=red]VITALITY[color=white] +1 [br]%s" % spentPointDistribution[0]
	$"ats/1".text = "-1 [color=green]AGILITY[color=white] +1 [br]%s" % spentPointDistribution[1]
	$"ats/2".text = "-1 [color=blue]TECHNIQUE[color=white] +1 [br]%s" % spentPointDistribution[2]
	$pts.text = "PTS: %s" % availablePoints
func toggleReady() -> void:
	changeCurrentControl($ready)
	if isReady:
		$ready.modulate = Color.RED
		isReady = false
	elif availablePoints == 0:
		isReady = true
		$ready.modulate = Color.GREEN
	readyChanged.emit()
func changeCurrentControl(newControl : Control) -> void:
	currentControl.scale = Vector2(1,1)
	currentControl = newControl
	currentControl.scale = Vector2(1.25,1.25)
func updateDisplay() -> void:
	pass
