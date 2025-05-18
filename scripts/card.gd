extends Sprite2D

var dragging = false
var mouse_offset = Vector2.ZERO
var new_parent = null

var value = 0
var suit = 0
var isdark = false
var move_to_foundation = false

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
	
	if get_parent() != null:
		if get_parent().is_in_group("foundations") or get_parent().is_in_group("foundation_cards"):
			remove_from_group("freecell_cards")
			add_to_group("foundation_cards")
			position = Vector2.ZERO
		elif get_parent().is_in_group("freecells"):
			add_to_group("freecell_cards")
			position = Vector2.ZERO
		elif get_parent().is_in_group("cards"): 
			remove_from_group("freecell_cards")
			position = Vector2(0, Globals.default_offset)
		else: 
			remove_from_group("freecell_cards")
			position = Vector2.ZERO
	z_index = 0
	dragging = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if get_node("/root/"+Globals.current_game).validate_move(area.get_parent(), $"."):
		new_parent = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() == new_parent:
		new_parent = null
