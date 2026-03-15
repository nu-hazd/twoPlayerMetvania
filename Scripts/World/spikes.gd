@tool
extends HazardArea
class_name SpikeTrap

@export var length: float = 128.0:
	set(value):
		length = value
		update_trap()

@export var height: float = 16.0:
	set(value):
		height = value
		update_trap()

func _ready() -> void:
	update_trap()

func update_trap() -> void:
	if not is_inside_tree():
		return
	
	var collision := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	
	if collision == null or sprite == null:
		return
	
	if collision.shape == null:
		collision.shape = RectangleShape2D.new()
	
	var rect_shape := collision.shape as RectangleShape2D
	if rect_shape == null:
		return
	
	rect_shape.size = Vector2(length, height)
	sprite.region_enabled = true
	sprite.region_rect = Rect2(Vector2.ZERO, Vector2(length, height))
