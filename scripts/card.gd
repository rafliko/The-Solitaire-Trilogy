extends Sprite2D

var dragging = false
var mouse_offset = Vector2.ZERO
var new_parent = null
const move_speed = 4000

@export var move_to_foundation = false
@export var value = 0
@export var suit = 0
@export var isdark = false
@export var is_foundation_card = false
@export var is_freecell_card = false
@export var is_hidden = false
@export var is_pile_card = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = load(Globals.deck_styles[Globals.deck_style_index])
	if is_hidden: region_rect = Globals.card_back_rect
	else: region_rect = Rect2(value*Globals.card_width, suit*Globals.card_height, Globals.card_width, Globals.card_height)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		global_position = get_global_mouse_position() - mouse_offset
		
	if move_to_foundation:
		z_index = 1
		new_parent = null
		dragging = false
		position += position.direction_to(Vector2.ZERO) * delta * move_speed
		if abs(position.x) < delta * move_speed and abs(position.y) < delta * move_speed: 
			z_index = 0
			position = Vector2.ZERO
			move_to_foundation = false
			get_node("/root/"+Globals.current_game).block_autosolve = false
			
	if is_hidden:
		if get_child_count() < 3:
			is_hidden = false
			region_rect = Rect2(value*Globals.card_width, suit*Globals.card_height, Globals.card_width, Globals.card_height)

func _on_button_button_down() -> void:
	if !is_hidden and get_node("/root/"+Globals.current_game).validate_sequence($"."):
		new_parent = null
		mouse_offset = get_global_mouse_position() - global_position
		z_index = 1
		dragging = true


func _on_button_button_up() -> void:
	if new_parent != null and new_parent != get_parent():
		reparent(new_parent)
	
	if dragging:
		if (get_parent().is_in_group("foundations") or # Placed on foundation
		   (get_parent().is_in_group("cards") and get_parent().is_foundation_card)): # Placed on foundation card
			is_pile_card = false
			is_foundation_card = true
			is_freecell_card = false
			position = Vector2.ZERO
		elif get_parent().is_in_group("freecells"): # Placed on freecell
			is_pile_card = false
			is_foundation_card = false
			is_freecell_card = true
			position = Vector2.ZERO
		elif get_parent().is_in_group("columns"):  # Placed on column
			is_pile_card = false
			is_foundation_card = false
			is_freecell_card = false
			position = Vector2.ZERO
		elif get_parent().is_in_group("cards") and !get_parent().is_pile_card: # Placed on a card that isn't a pile card
			is_pile_card = false
			is_foundation_card = false
			is_freecell_card = false
			if Globals.current_game == "spider":
				position = Vector2(0, Globals.default_offset_spider)
			else:
				position = Vector2(0, Globals.default_offset)
		else:
			position = Vector2.ZERO
		
		z_index = 0
		dragging = false


func _on_area_2d_area_entered(area: Area2D) -> void:
	if get_node("/root/"+Globals.current_game).validate_move(area.get_parent(), $"."):
		new_parent = area.get_parent()


func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.get_parent() == new_parent:
		new_parent = null
