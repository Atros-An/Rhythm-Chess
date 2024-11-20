extends Control


@onready var start_button = $"MarginContainer/menu/VBoxContainer/Start Game"
@onready var options_button = $MarginContainer/menu/VBoxContainer/Options
@onready var end_button = $"MarginContainer/menu/VBoxContainer/End Game"
@onready var game=preload("res://scenes/Game.tscn")



func _ready() -> void:
	
	pass 



func _on_start_game_pressed() -> void:
	get_tree().change_scene_to_packed(game)
	#get_tree().get_root().add_child(game.instantiate())
	
	#print(1)
	#get_tree().change_scene_to_file("res://scenes/Game.tscn")
	
	#get_tree().reload_current_scene()

func _on_options_pressed() -> void:
	
	$options.set_process(true)
	$options.visible=true
	pass 


func _on_end_game_pressed() -> void:
	get_tree().quit()
