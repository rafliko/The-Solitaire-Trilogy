extends Control


func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu.tscn")


func _on_klondike_button_pressed() -> void:
	$RichTextLabel.text = "The four foundations are built up by suit from Ace to King, and the tableau piles can be built down by alternate colors. Every face-up card in a partial pile, or a complete pile, can be moved, as a unit, to another tableau pile on the basis of its highest card. Any empty piles can be filled with a King, or a pile of cards with a King. The aim of the game is to build up four stacks of cards starting with Ace and ending with King, all of the same suit, on one of the four foundations, at which time the player would have won. 

Source: [url]https://en.wikipedia.org/wiki/Klondike_(solitaire)[/url]"


func _on_freecell_button_pressed() -> void:
	$RichTextLabel.text = "The top card of each cascade begins a sequence. Tableaus must be built down by alternating colors. Foundations are built up by suit. The Foundations begin with Ace and are built up to King.

Any cell card or top card of any cascade may be moved to build on a tableau, or moved to an empty cell, an empty cascade, or its foundation.

The game is won after all cards are moved to their foundation piles. 

Unlike in many solitaire card games, the rules of Freecell only allow cards to be moved one at a time. Complete or partial tableaus may be moved to build on existing tableaus, or moved to empty cascades, only by a sequence of moves which recursively place and remove cards through intermediate locations.

For example, with one empty cell, the top card of one tableau can be moved to a free cell. The second card from the top of that tableau can now be moved onto another tableau. Then the original top card can be moved from the cell on top of it.

Such a sequence of moves is called a 'supermove'.

The maximum number C of cards in a tableau that can be moved to another tableau equals the number of empty cells plus one, with that number doubling for each empty cascade: C = 2^M × ( N + 1 ), where M is the number of empty cascades and N is the number of empty cells. The maximum number that can be moved to an empty cascade is C / 2.

Source: [url]https://en.wikipedia.org/wiki/FreeCell[/url]"


func _on_spider_button_pressed() -> void:
	$RichTextLabel.text = "The main purpose of the game is to remove all cards from the table, assembling them in the tableau before removing them. Initially, 54 cards are dealt to the tableau in ten piles, face down except for the top cards. The tableau piles build down by rank can be moved together. The 50 remaining cards can be dealt to the tableau ten at a time when none of the piles are empty.

Each time the stock is used, it deals out one card to each stack. 

Source: [url]https://en.wikipedia.org/wiki/Spider_(solitaire)[/url]"
