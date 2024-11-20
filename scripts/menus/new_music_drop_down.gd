extends HBoxContainer
class_name music_drop_down


@export var music_list=[]
@export var music_button_index:int

func _ready() -> void:
	for m in music_list:
		$New_music.add_item(m)

func _on_new_music_item_selected(index):
	Global.music_list[music_button_index]=music_list[index]


func _on_remove_music_pressed() -> void:
	if len(get_tree().get_nodes_in_group("Music_drop_down"))>1:
		for i in get_tree().get_nodes_in_group("Music_drop_down"):
			if i.music_button_index>music_button_index:
				i.music_button_index-=1
		
		for i in range(len(Global.music_list)):
			if i > music_button_index:
				Global.music_list[i-1]=Global.music_list[i]
		Global.music_list.pop_back()
		self.queue_free()
