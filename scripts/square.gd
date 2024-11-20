extends Control
class_name SQUARE

@export var dark:bool=false
@export var color_dot:Sprite2D
@onready var MyColorRect:=$ColorRect


func _ready():
	color_dot=$Color_Dot
	if dark:
		MyColorRect.color="#90a0a5"
