extends BoxContainer

@onready var label=$HBoxContainer/Label
@onready var button=$HBoxContainer/Button

@export var action_name:String
@export var key:String




func _ready() -> void:
	#key=Global.key_dic[action_name]
	set_process_unhandled_key_input(false)
	label.text=action_name
	button.text=key




func _on_button_toggled(toggled_on) -> void:
	set_process_unhandled_key_input(toggled_on)
	if toggled_on:
		button.text="Press any key..."
		
		for i in get_tree().get_nodes_in_group("key_rebind_botton"):
			if i.action_name!=self.action_name:
				i.button.toggle_mode=false
				i.set_process_unhandled_key_input(false)

	else:
		button.text=key
		for i in get_tree().get_nodes_in_group("key_rebind_botton"):
			if i.action_name!=self.action_name:
				i.button.toggle_mode=true



func _unhandled_key_input(event) -> void:
	
	for i in Global.key_dic:
		if Global.key_dic[i]==OS.get_keycode_string(event.keycode):
			Global.key_dic[i]=key
	for i in get_tree().get_nodes_in_group("key_rebind_botton"):
		if  i.key==OS.get_keycode_string(event.keycode):
			i.key=key
			i.button.text=key
			
	if OS.get_keycode_string(event.keycode)=="Escape":
		Global.key_dic[action_name]=null
		key="None"
	else:
		Global.key_dic[action_name]=OS.get_keycode_string(event.keycode)
		key=Global.key_dic[action_name]
	button.button_pressed=false

