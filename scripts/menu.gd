extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$card1.texture = load(Globals.deck_styles[Globals.deck_style_index])
	$card2.texture = load(Globals.deck_styles[Globals.deck_style_index])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/settings.tscn")
