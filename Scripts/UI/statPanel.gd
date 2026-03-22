extends Panel

## A HUD panel that displays player stats, weapon cooldowns, and dash cooldown state.
##
## This class manages:
## - Weapon recharge bars through [member weaponRechargeBars].
## - Weapon icons through [member weaponIcons].
## - A dash recharge bar through [member dash_recharge].
## - Ongoing cooldown timers for both weapons and dash.
##
## It can be updated with player stat data through [method updateStatPanel] and weapon
## data through [method updateWeaponHUD].

class_name StatPanel

## Progress bars used to display weapon cooldown remaining time.
##
## This script assumes the array contains two entries, one for each weapon slot.
@export var weaponRechargeBars: Array[ProgressBar]

@export var weaponContainers : Array[PanelContainer]
## Texture rectangles used to display weapon icons.
##
## This script assumes the array contains two entries, one for each weapon slot.
@export var weaponIcons: Array[TextureRect]

## The progress bar used to display dash cooldown.
@onready var dash_recharge: ProgressBar = $edge/informationListings/dashRecharge

## The remaining cooldown time, in seconds, for each weapon slot.
##
## This script tracks exactly two weapon cooldown values.
var weaponCooldowns: Array[float] = [0.0, 0.0]

## The remaining dash cooldown time, in seconds.
var dashCooldown: float = 0.0

@export var coords: Label

##
## Initializes the stat panel.
##
## This method:
## - Hides the dash recharge bar by setting its alpha to `0`.
## - Disables per-frame processing until a cooldown begins.
##
func _ready() -> void:
	dash_recharge.modulate.a = 0
	set_process(false)

##
## Starts a cooldown for one of the weapon recharge bars.
##
## This method:
## - Validates the requested weapon slot.
## - Stores the cooldown in [member weaponCooldowns].
## - Sets the matching progress bar's maximum and current value.
## - Enables processing so the cooldown can tick down over time.
##
## [param weaponNumber] The index of the weapon slot to update.
## [param time] The cooldown duration, in seconds.
##
func startWeaponCooldown(time: float, weaponNumber : int) -> void:
	if weaponNumber < 0 or weaponNumber > 1:
		return
	if time == 0:
		weaponRechargeBars[weaponNumber].visible = false
	else:
		weaponRechargeBars[weaponNumber].visible = true
	weaponCooldowns[weaponNumber] = time
	weaponRechargeBars[weaponNumber].max_value = time
	weaponRechargeBars[weaponNumber].value = time
	set_process(true)

##
## Starts the dash recharge bar cooldown.
##
## This method:
## - Makes the dash recharge bar visible.
## - Stores the cooldown in [member dashCooldown].
## - Sets the bar's maximum and current value.
## - Enables processing so the cooldown can tick down over time.
##
## [param time] The dash cooldown duration, in seconds.
##
func startRechargeBarCooldown(time: float) -> void:
	dash_recharge.modulate.a = 1
	dashCooldown = time
	dash_recharge.max_value = dashCooldown
	dash_recharge.value = dashCooldown
	set_process(true)

##
## Updates active cooldown timers and their corresponding UI bars every frame.
##
## This method:
## - Decreases [member dashCooldown].
## - Decreases both entries in [member weaponCooldowns].
## - Updates all weapon recharge bars.
## - Updates the dash recharge bar.
## - Hides the dash bar when its cooldown reaches `0`.
## - Disables processing when no cooldowns remain.
##
## [param delta] The frame delta time in seconds.
##
func _process(delta: float) -> void:
	dashCooldown = max(0, dashCooldown - delta)
	weaponCooldowns = [
		max(0, weaponCooldowns[0] - delta),
		max(0, weaponCooldowns[1] - delta)
	]

	for i in range(2):
		weaponRechargeBars[i].value = weaponCooldowns[i]

	dash_recharge.value = dashCooldown

	if not dashCooldown:
		dash_recharge.modulate.a = 0

	if not weaponCooldowns and not dashCooldown:
		set_process(false)

##
## Updates the stat-related HUD elements from a player stat array.
##
## This method updates:
## - The health bar maximum and current value.
## - The stamina bar maximum and current value.
## - The unlock indicators for dash, double jump, and wall jump.
## - The rich-text attribute summary for coins, vitality, agility, and technique.
##
## [param stats] A player stat array indexed using [enum Player.STATS].
##
func updateStatPanel(stats: Array[int]) -> void:
	#$edge/informationListings/className.text = playerReference.playerName
	$edge/informationListings/healthBar.max_value = stats[Player.STATS.MAX_HEALTH]
	$edge/informationListings/healthBar.value = stats[Player.STATS.CURRENT_HEALTH]
	$edge/informationListings/staminaBar.max_value = stats[Player.STATS.MAX_STAMINA]
	$edge/informationListings/staminaBar.value = stats[Player.STATS.CURRENT_STAMINA]

	if stats[Player.STATS.HAS_DASH]:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/dash.modulate = Color.RED

	if stats[Player.STATS.HAS_DOUBLE_JUMP]:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/doubleJump.modulate = Color.RED

	if stats[Player.STATS.HAS_WALL_JUMP]:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.GREEN
	else:
		$edge/informationListings/margin/stats/unlocks/wallJump.modulate = Color.RED

	var attributeText: String = "
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

##
## Updates the weapon HUD icons from an array of [Weapon] instances.
##
## This method assigns the icon texture of each weapon's [member info] resource to the
## corresponding entry in [member weaponIcons].
##
## This script assumes [param weapons] contains at least two elements.
##
## [param weapons] The array of equipped weapons to display.
##
func updateWeaponHUD(weapons: Array[Weapon]) -> void:
	match  weapons.size():
		0:
			weaponContainers[0].self_modulate = Color(255,255,255,0)
			weaponContainers[1].self_modulate = Color(255,255,255,0)
			weaponContainers[0].visible = false
			weaponContainers[1].visible = false
		1:
			weaponIcons[0].texture = weapons[0].info.icon
			weaponContainers[0].visible = true
			match weapons[0].info.tier:
				WeaponInformation.TIER.COMMON:
					weaponContainers[0].self_modulate = Color.WHITE
				WeaponInformation.TIER.RARE:
					weaponContainers[0].self_modulate = Color.BLUE
				WeaponInformation.TIER.EPIC:
					weaponContainers[0].self_modulate = Color.PURPLE
				WeaponInformation.TIER.LEGENDARY:
					weaponContainers[0].self_modulate = Color.GOLD
			weaponContainers[1].visible = false
		2:
			weaponIcons[0].texture = weapons[0].info.icon
			weaponIcons[1].texture = weapons[1].info.icon
			weaponContainers[0].visible = true
			weaponContainers[1].visible = true
			match weapons[0].info.tier:
				WeaponInformation.TIER.COMMON:
					weaponContainers[0].self_modulate = Color.WHITE
				WeaponInformation.TIER.RARE:
					weaponContainers[0].self_modulate = Color.BLUE
				WeaponInformation.TIER.EPIC:
					weaponContainers[0].self_modulate = Color.PURPLE
				WeaponInformation.TIER.LEGENDARY:
					weaponContainers[0].self_modulate = Color.GOLD
			match weapons[1].info.tier:
				WeaponInformation.TIER.COMMON:
					weaponContainers[1].self_modulate = Color.WHITE
				WeaponInformation.TIER.RARE:
					weaponContainers[1].self_modulate = Color.BLUE
				WeaponInformation.TIER.EPIC:
					weaponContainers[1].self_modulate = Color.PURPLE
				WeaponInformation.TIER.LEGENDARY:
					weaponContainers[1].self_modulate = Color.GOLD
func updateCoords(pos :Vector2) -> void:
	coords.text = "%d, %d" % [floor(pos.x),floor(pos.y)]
