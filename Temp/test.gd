extends Control

enum{ 
	A8,B8,C8,D8,E8,F8,G8,H8,
	A7,B7,C7,D7,E7,F7,G7,H7,
	A6,B6,C6,D6,E6,F6,G6,H6,
	A5,B5,C5,D5,E5,F5,G5,H5,
	A4,B4,C4,D4,E4,F4,G4,H4,
	A3,B3,C3,D3,E3,F3,G3,H3,
	A2,B2,C2,D2,E2,F2,G2,H2,
	A1,B1,C1,D1,E1,F1,G1,H1}

func coordinate_to_sqaure(coordinate:int) -> int:
	if coordinate>=0 and coordinate<64:
		coordinate=1<<coordinate
	else:
		coordinate=0
	return coordinate

func _ready():

	#print(1<<A1,1<<H1)
	
	var my_Board=New_Board.new()
	var my_ai=chess_ai.new()
	print(my_ai.minimax(my_Board,4,true))
	




