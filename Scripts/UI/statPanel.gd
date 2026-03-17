extends Panel
class_name StatPanel
@export var weaponRechargeBars : Array[ProgressBar]
@export var weaponIcons : Array[TextureRect]
@onready var dash_recharge: ProgressBar = $edge/informationListings/dashRecharge
var weaponCooldowns : Array[float] = [0.0,0.0]
var dashCooldown : float = 0.0


func _ready() -> void:
	dash_recharge.modulate.a = 0
	set_process(false)
func startWeaponCooldown(weaponNumber : int, time : float) -> void:
	if weaponNumber < 0 or weaponNumber > 1:
		return
	weaponCooldowns[weaponNumber] = time
	weaponRechargeBars[weaponNumber].max_value = time
	weaponRechargeBars[weaponNumber].value = time
	set_process(true)
func startRechargeBarCooldown(time : float) -> void:
	dash_recharge.modulate.a = 1
	dashCooldown = time
	dash_recharge.max_value = dashCooldown
	dash_recharge.value = dashCooldown
	set_process(true)
func _process(delta: float) -> void:
	dashCooldown = max(0, dashCooldown- delta)
	weaponCooldowns = [max(0,weaponCooldowns[0]-delta),max(0,weaponCooldowns[1]-delta)]
	for i in range(2):
		weaponRechargeBars[i].value = weaponCooldowns[i]
	dash_recharge.value = dashCooldown
	if not dashCooldown:
		dash_recharge.modulate.a = 0
	if not weaponCooldowns and not dashCooldown:
		set_process(false)
	
func updateStatPanel(stats : Array[int]) -> void:
	#$edge/informationListings/className.text = playerReference.playerName
	$edge/informationListings/healthBar.max_value =stats[Player.STATS.MAX_HEALTH]
	$edge/informationListings/healthBar.value = stats[Player.STATS.CURRENT_HEALTH]
	$edge/informationListings/staminaBar.max_value = stats[Player.STATS.MAX_STAMINA]
	$edge/informationListings/staminaBar.value = stats[Player.STATS.CURRENT_STAMINA]
	if  stats[Player.STATS.HAS_DASH]:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.RED
	if stats[Player.STATS.HAS_DOUBLE_JUMP]:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.RED
	if  stats[Player.STATS.HAS_WALL_JUMP]:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.RED
	var attributeText : String = "
[table=2]
[cell][color=gold]$[/color][/cell][cell][color=white]%s[/color][/cell]

[cell][color=red]VIT[/color][/cell][cell][color=white]%s[/color][/cell]

[cell][color=green]AGI[/color][/cell][cell][color=white]%s[/color][/cell]

[cell][color=blue]TEC[/color][/cell][cell][color=white]%s[/color][/cell]
[/table]
" % [
	stats[Player.STATS.SOULS],
	stats[Player.STATS.VITALITY],
	stats[Player.STATS.AGILITY],
	stats[Player.STATS.TECHNIQUE]
]
	$edge/informationListings/margin/stats/attributes.text = attributeText
func updateWeaponHUD(weapons : Array[Weapon]) -> void:
	weaponIcons[0].texture = weapons[0].info.icon
	weaponIcons[1].texture = weapons[1].info.icon
	
	
