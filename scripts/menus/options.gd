extends Control

@onready var tab_container=$MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/TabContainer
@onready var Key_rebind_botton=preload("res://scenes/key_rebind_botton.tscn")
@onready var botton_container=$MarginContainer2/MarginContainer/VBoxContainer/HBoxContainer/TabContainer/Controls/MarginContainer/ScrollContainer/botton_container
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_keybind()
	set_process(false)

func set_keybind() -> void:
	
	for i in Global.key_dic:
		var new_botton=Key_rebind_botton.instantiate()
		new_botton.action_name=i
		new_botton.key=Global.key_dic[i]
		botton_container.add_child(new_botton)


func exit() -> void:
	visible=false
	set_process(false)
	


func _on_tab_container_tab_selected(tab:int) -> void:
	if tab == 3:
		tab_container.current_tab=0
		exit()
