extends MarginContainer

var music_list=[]
@onready var music_button:PackedScene=preload("res://scenes/new_music_drop_down.tscn")
@onready var Line_edit:=$MarginContainer/VBoxContainer/LineEdit
@onready var music_container=$MarginContainer/VBoxContainer/MarginContainer/ScrollContainer/VBoxContainer


func _ready() -> void:
	pass

func loading_music_file() -> void:
	
	var dir = DirAccess.open(Global.music_directory+"/music/")
	if dir:
		dir.list_dir_begin()
		var file_name:String = dir.get_next()
		while file_name != "":
			if not dir.current_is_dir():
				music_list.append(file_name.get_basename())
			file_name = dir.get_next()



func _on_add_music_pressed() -> void:
	var New_music_button:music_drop_down=music_button.instantiate()
	New_music_button.music_list=music_list
	New_music_button.music_button_index=0
	if len(get_tree().get_nodes_in_group("Music_drop_down"))>0:
		for i in get_tree().get_nodes_in_group("Music_drop_down"):
			if i.music_button_index>=New_music_button.music_button_index:
				New_music_button.music_button_index=i.music_button_index+1
	
	if len(music_list)>0:
		Global.music_list.append(music_list[0])
		music_container.add_child(New_music_button)



func _on_line_edit_text_submitted(new_text: String) -> void:
	
	Line_edit.release_focus()
	Global.music_directory=new_text.replace('\\',"/")
	
	loading_music_file()
	_on_add_music_pressed()
