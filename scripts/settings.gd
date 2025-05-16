extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$deck_style/deck_style_option.select(Globals.deck_style_index)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_deck_style_option_item_selected(index: int) -> void:
	Globals.deck_style_index = index


func _on_credits_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
