extends Node2D

class_name PIECE

@export var type:int=0
@export var color:int=0
@export var Home_Square:SQUARE
@export var Current_Square:SQUARE
@export var Never_Moved:bool=true
@export var available_list:Array[SQUARE]=[]



func _ready():
	Home_Square=self.get_parent()
	self.global_position=Home_Square.global_position+Vector2(64,64)
	Current_Square=Home_Square
	$ChessPiecesSprite.frame=type+6*color
	#W KQBNRP
	#B KQBNRP
	
	#W PRNBQK
	#B PRBNQK
	available_list.append(Home_Square)
