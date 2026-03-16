extends Panel
class_name SelectContainer

@onready var p_one_select: CharacterSelect = $customizeScreens/pOneSelect
@onready var p_two_select: CharacterSelect = $customizeScreens/pTwoSelect


signal playersAreReady(stats: Array[Array], spriteAtlas: Array[AtlasTexture])
func _ready() -> void:
	p_one_select.readyChanged.connect(checkReadiness)
	p_two_select.readyChanged.connect(checkReadiness)

func checkReadiness() -> void:
	if p_one_select.isReady and p_two_select.isReady:
		#(stats: Array[Array], spriteAtlas: Array[AtlasTexture]
		var sts : Array[Array] = [p_one_select.spentPointDistribution,p_two_select.spentPointDistribution]
		var txt : Array[AtlasTexture]= [p_one_select.getEntireAtlas(),p_two_select.getEntireAtlas()]
		playersAreReady.emit(
			sts,
			txt
			)
	
