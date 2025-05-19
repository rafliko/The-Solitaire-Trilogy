extends Sprite2D

var dragging = false
var mouse_offset = Vector2.ZERO
var new_parent = null
var move_to_foundation = false

@export var value = 0
@export var suit = 0
@export var isdark = false
@export var is_foundation_card = false
@export var is_freecell_card = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = load(Globals.deck_styles[Globals.deck_style_index])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - mouse_offset
	if move_to_foundation:
		new_parent = null
		dragging = false
		position += position.direction_to(Vector2.ZERO) * delta * 4000
		if abs(position) < Vector2(20,20): 
			position = Vector2.ZERO
			move_to_foundation = false
			get_node("/root/"+Globals.current_game).block_autosolve = false


func _on_button_button_down() -> void:
	if get_node("/root/"+Globals.current_game).validate_sequence($"."):
		new_parent = null
		mouse_offset = get_global_mouse_position() - global_position
		z_index = 1
		dragging = true


func _on_button_button_up() -> void:
	if new_parent != null:
		reparent(new_parent)
	
	if dragging:
		if (get_parent().is_in_group("foundations") or 
		   (get_parent().is_in_group("cards") and get_parent().is_foundation_card)): # Placed on foundation
			is_foundation_card = true
			is_freecell_card = false
			position = Vector2.ZERO
		elif get_parent().is_in_group("freecells"): # Placed on freecell
			is_foundation_card = false
			is_freecell_card = true
			position = Vector2.ZERO
		elif get_parent().is_in_group("columns"):  # Placed on column
			is_foundation_card = false
			is_freecell_card = false
			position = Vector2.ZERO
		elif get_parent().is_in_group("cards"): # Placed on card
			is_foundation_card = false
			is_freecell_card = false
			position = Vector2(0, Globals.default_offset)
		
		z_index = 0
		dragging = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if get_node("/root/"+Globals.current_game).validate_move(area.get_parent(), $"."):
		new_parent = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() == new_parent:
		new_parent = null
