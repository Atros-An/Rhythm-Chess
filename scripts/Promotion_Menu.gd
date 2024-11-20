extends ColorRect

@onready var Board_piece=preload("res://scenes/piece.tscn")
@export var My_Pawn:PIECE

func _ready() -> void:
	$VBoxContainer/Queen/ChessPiecesSprite.frame=1+6*My_Pawn.color
	$VBoxContainer/Knight/ChessPiecesSprite.frame=3+6*My_Pawn.color
	$VBoxContainer/Rook/ChessPiecesSprite.frame=4+6*My_Pawn.color
	$VBoxContainer/Bishop/ChessPiecesSprite.frame=2+6*My_Pawn.color
	

func Promotion(type:int) -> void:
	var new_piece=Board_piece.instantiate()
	new_piece.type=type
	new_piece.color=My_Pawn.color
	My_Pawn.Home_Square.add_child(new_piece)
	My_Pawn.Home_Square.get_child(2).visible=false
#White
	if My_Pawn.color==0:
		for i in Global.White_Piece_list:
			if i == My_Pawn:
				Global.White_Piece_list[Global.White_Piece_list.find(i)]=new_piece

#Black
	elif My_Pawn.color==1:
		for i in Global.Black_Piece_list:
			if i == My_Pawn:
				Global.Black_Piece_list[Global.Black_Piece_list.find(i)]=new_piece

	My_Pawn.queue_free()
	self.queue_free()

func _on_queen_pressed() -> void:
	$VBoxContainer/Queen/ChessPiecesSprite.scale=Vector2(1.05,1.05)
	Promotion(1)

func _on_knight_pressed() -> void:
	$VBoxContainer/Knight/ChessPiecesSprite.scale=Vector2(1.05,1.05)
	Promotion(3)

func _on_rook_pressed() -> void:
	$VBoxContainer/Rook/ChessPiecesSprite.scale=Vector2(1.05,1.05)
	Promotion(4)

func _on_bishop_pressed() -> void:
	$VBoxContainer/Bishop/ChessPiecesSprite.scale=Vector2(1.05,1.05)
	Promotion(2)
