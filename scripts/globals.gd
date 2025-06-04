extends Node

const card_width = 200
const card_height = 300
const default_offset = 70
const default_offset_spider = 50
const card_back_rect = Rect2(2*card_width, 4*card_height, card_width, card_height)

var current_game = "menu"
var deck_styles = [
	"res://sprites/decks/anglo.png", 
	"res://sprites/decks/adler.png", 
	"res://sprites/decks/atlasnye.png",
	"res://sprites/decks/veteris_artem.png"
]
var deck_style_index = 0


func count_sequence(parent_card: Node, depth: int) -> int:
	if parent_card.get_child_count() > 2:
		return count_sequence(parent_card.get_child(2), depth+1)
	else:
		return depth


func get_top_card(parent_card: Node) -> Node:
	if parent_card.get_child_count() > 2:
		return get_top_card(parent_card.get_child(2))
	else:
		return parent_card


func get_min_foundation(foundations: Node2D):
	# Get the lowest value in foundations
	var min = 20
	for f in foundations.get_children():
		if f.get_child_count() > 1:
			if Globals.count_sequence(f.get_child(1),1) < min:
				min = Globals.count_sequence(f.get_child(1),1)
		else: min = 0
	return min
