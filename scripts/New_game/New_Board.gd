extends Game_Assets
class_name New_Board

@export var all_piece_list:Array[int]#=[
	#71776119061217280,-9151314442816847872,4755801206503243776,2594073385365405696,576460752303423488,1152921504606846976,
	#65280,129,66,36,8,16]
@export var en_passant_square:BIT_SQUARE=0
@export var can_castle:Array[bool]=[true,true,true,true]
@export var win:Array[bool]=[]

signal making_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE)
signal checkmate(winner)

func _init(
			input_piece_list:Array[int]=[
			71776119061217280,-9151314442816847872,4755801206503243776,2594073385365405696,576460752303423488,1152921504606846976,
			65280,129,66,36,8,16]
	) -> void:
	
	self.all_piece_list=input_piece_list


func coordinate_to_square(coordinate:COORDINATE) -> BIT_SQUARE:
	var return_square:BIT_SQUARE=0
	if coordinate>=0 and coordinate<64:
		return_square=1<<coordinate
	return return_square


func square_to_coordinate(square:BIT_SQUARE) -> COORDINATE:
	if square==0:
		return -1
	
	if square==-9223372036854775808:
		return 63
	
	var coordinate:COORDINATE = 0
	
	while square > 1:
		square >>= 1
		coordinate+=1
	return coordinate


func find_piece_type_index_on_square(square:BIT_SQUARE) -> PIECE_TYPE_INDEX:
	
	
	for i in range(12):
		if all_piece_list[i]&square!=0 and square!=0:
			return i
	return PIECE_TYPE_INDEX.null_piece_index


func remove_piece_on_square(square:BIT_SQUARE) -> void:
	
	square^=-1
	
	for i in range(12):
		all_piece_list[i]=all_piece_list[i]&square


func set_piece_on_square(piece_index:PIECE_TYPE_INDEX,square:BIT_SQUARE) -> void:
	if piece_index!=-1:
		remove_piece_on_square(square)
		all_piece_list[piece_index]|=square


func is_square_playable_for_color(color:bool,square:BIT_SQUARE) -> bool:
	var type_index=find_piece_type_index_on_square(square)
	return (square != 0) and (find_color_from_type_index(type_index) != color)


func is_square_empty(square:BIT_SQUARE) -> bool:
	return find_piece_type_index_on_square(square)==-1


func Type_Validate(square:BIT_SQUARE,piece_index:PIECE_TYPE_INDEX) -> bool:
	return find_piece_type_index_on_square(square)==piece_index


func Never_moved_dectetion_for_pawn(color:bool,piece_square:BIT_SQUARE) -> bool:
	if color:
		return BIT_SQUARE.a2<=piece_square and BIT_SQUARE.h2>=piece_square
	return BIT_SQUARE.a7<=piece_square and BIT_SQUARE.h7>=piece_square


func find_square_with_movement(square:BIT_SQUARE,xMove:int=0,yMove:int=0) -> BIT_SQUARE:
	if square==BIT_SQUARE.null_square:
		return BIT_SQUARE.null_square
	var row:int=8*((square_to_coordinate(square)/8)-yMove)
	var column:int=square_to_coordinate(square)%8+xMove
	if row+column>=64 or row<0 or column<0 or column>=8:
		return BIT_SQUARE.null_square
	else:
		return 1<<row+column


func find_squares_in_direction(color:bool,piece_square:BIT_SQUARE, x_dir:int, y_dir:int) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for i in range(1, 8):
		
		var square:BIT_SQUARE = find_square_with_movement(piece_square, x_dir * i, y_dir * i)
		
		if not is_square_playable_for_color(color,square):
			break
		moveable_list.append(square)
		if find_piece_type_index_on_square(square) != -1:
			break
	return moveable_list


func find_takable_square_for_pawn(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	var dirction=-1
	if color:
		dirction=1
	
	
	for dir in [-1,1]:
		var square=find_square_with_movement(piece_square,dir,dirction)
		if is_square_playable_for_color(color,square) and (
			(not is_square_empty(square) )!=(
				square&en_passant_square!=0 and 
				is_square_playable_for_color(color,find_square_with_movement(square,0,-1 if color else 1))
				and ((piece_square>=BIT_SQUARE.a5 and piece_square<=BIT_SQUARE.h5) if color else (piece_square>=BIT_SQUARE.a4 and piece_square<=BIT_SQUARE.h4))
				)
			):
			
			moveable_list.append(square)


	return moveable_list


func find_available_move_for_pawn(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	var dirction=-1
	if color:
		dirction=1

	var squar1=find_square_with_movement(piece_square,0,dirction)
	if is_square_empty(squar1):
		moveable_list.append(squar1)
		if Never_moved_dectetion_for_pawn(color,piece_square):
			var square2=find_square_with_movement(piece_square,0,2*dirction)
			if is_square_empty(square2):
				moveable_list.append(square2)
	
	
	moveable_list.append_array(find_takable_square_for_pawn(color,piece_square))
	
	return moveable_list


func find_available_move_for_rook(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for direction in [-1, 1]:
		moveable_list.append_array(find_squares_in_direction(color,piece_square,direction,0))
		moveable_list.append_array(find_squares_in_direction(color,piece_square,0,direction))
	return moveable_list


func find_available_move_for_knight(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for u in [2,-2]:
		for i in [1,-1]:
			for s in [find_square_with_movement(piece_square,i,u),find_square_with_movement(piece_square,u,i)]:
				if is_square_playable_for_color(color,s):
					moveable_list.append(s)
	return moveable_list


func find_available_move_for_bishop(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for x_dir in [-1, 1]:
		for y_dir in [-1, 1]:
			moveable_list.append_array(find_squares_in_direction(color,piece_square, x_dir, y_dir)) 
	return moveable_list


func find_available_move_for_queen(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for dir in [-1, 1]:
		moveable_list.append_array(find_squares_in_direction(color,piece_square, dir, 0))  # Horizontal
		moveable_list.append_array(find_squares_in_direction(color,piece_square, 0, dir))  # Vertical
		for dir2 in [-1, 1]:
			moveable_list.append_array(find_squares_in_direction(color,piece_square, dir, dir2)) #diagonal
	return moveable_list


func find_basic_move_for_king(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var square=find_square_with_movement(piece_square,x,y)
			if is_square_playable_for_color(color,square):
				moveable_list.append(square)
	return moveable_list


func find_available_move_for_king(color:bool,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var moveable_list:Array[BIT_SQUARE]
	
	moveable_list.append_array(find_basic_move_for_king(color,piece_square))
	
	#castle
	if piece_square==(BIT_SQUARE.e1 if color else BIT_SQUARE.e8) and not King_in_threat(color):
		if color:
			if can_castle[0] and not square_under_attack(color,BIT_SQUARE.d1) and is_square_empty(BIT_SQUARE.b1) and is_square_empty(BIT_SQUARE.c1) and is_square_empty(BIT_SQUARE.d1):
				moveable_list.append(BIT_SQUARE.c1)
			if can_castle[1] and not square_under_attack(color,BIT_SQUARE.f1) and is_square_empty(BIT_SQUARE.g1) and is_square_empty(BIT_SQUARE.f1):
				moveable_list.append(BIT_SQUARE.g1)
		else:
			
			if can_castle[2] and not square_under_attack(color,BIT_SQUARE.d8) and is_square_empty(BIT_SQUARE.b8) and is_square_empty(BIT_SQUARE.c8) and is_square_empty(BIT_SQUARE.d8):
				moveable_list.append(BIT_SQUARE.c8)
			if can_castle[3] and not square_under_attack(color,BIT_SQUARE.f8) and is_square_empty(BIT_SQUARE.g8) and is_square_empty(BIT_SQUARE.f8):
				moveable_list.append(BIT_SQUARE.g8)
	
	
	return moveable_list


func find_available_move_for_piece(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE) -> Array[BIT_SQUARE]:
	var type=find_type_from_type_index(piece_index)
	var color=find_color_from_type_index(piece_index)
	var moveable_list:Array[BIT_SQUARE]
	var final_list:Array[BIT_SQUARE]
	
	match type:
		Pawn:
			moveable_list=find_available_move_for_pawn(color,piece_square)
		Rook:
			moveable_list=find_available_move_for_rook(color,piece_square)
		Knight:
			moveable_list=find_available_move_for_knight(color,piece_square)
		Bishop:
			moveable_list=find_available_move_for_bishop(color,piece_square)
		Queen:
			moveable_list=find_available_move_for_queen(color,piece_square)
		King:
			moveable_list=find_available_move_for_king(color,piece_square)
	
	for i in moveable_list:
		if not check_detection(piece_index,piece_square,i) and find_type_from_type_index(find_piece_type_index_on_square(i))!=King:
			final_list.append(i)
	return final_list


func get_legal_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE) -> Array:
	var move_list:Array
	var piece_is_pawn:bool=find_type_from_type_index(piece_index)==Pawn
	
	if piece_is_pawn: #promotion
			var color=find_color_from_type_index(piece_index)
			for move_square in find_available_move_for_piece(piece_index,piece_square):
				if color and move_square<=128:
					move_list.append([PIECE_TYPE_INDEX.White_Rooks_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.White_Knights_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.White_Bishops_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.White_Queens_index,piece_square,move_square])
				elif not color and square_to_coordinate(move_square)>=56:
					move_list.append([PIECE_TYPE_INDEX.Black_Rooks_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.Black_Knights_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.Black_Bishops_index,piece_square,move_square])
					move_list.append([PIECE_TYPE_INDEX.Black_Queens_index,piece_square,move_square])
				else:
					move_list.append([piece_index,piece_square,move_square])
	else:
		for move_square in find_available_move_for_piece(piece_index,piece_square):
			move_list.append([piece_index,piece_square,move_square])
	
	return move_list


func get_all_move_for_color(color:bool) -> Array:
	var all_move_list:Array#=[[-1,0,0]]
	for coordinate in range(64):
		var square=1<<coordinate
		var piece_index=find_piece_type_index_on_square(square)
		if find_color_from_type_index(piece_index)==color:
			all_move_list.append_array(get_legal_move(piece_index,square))
	
	return all_move_list


func get_all_legal_move() -> Array:
	var all_move_list:Array#=[[-1,0,0]]
	for coordinate in range(64):
		var square=1<<coordinate
		var piece_index=find_piece_type_index_on_square(square)
		if piece_index!=PIECE_TYPE_INDEX.null_piece_index:
			all_move_list.append_array(get_legal_move(piece_index,square))
	
	return all_move_list


func square_under_attack(color:bool,piece_square:BIT_SQUARE) -> bool:
	var opponent_color=(not color)
#King
	for square in find_basic_move_for_king(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(5,opponent_color):
			return true

#Knight
	for square in find_available_move_for_knight(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(2,opponent_color):
			return true

#Pawn
	for square in find_takable_square_for_pawn(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(0,opponent_color):
			return true

#Queen
	for square in find_available_move_for_queen(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(4,opponent_color):
			return true

#Rook
	for square in find_available_move_for_rook(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(1,opponent_color):
			return true

#Bishop
	for square in find_available_move_for_bishop(color,piece_square):
		if find_piece_type_index_on_square(square)==get_type_index_uisng_type_and_color(3,opponent_color):
			return true

	return false


func King_in_threat(color:bool) -> bool:
	
	
	var King_Square:BIT_SQUARE
	if color:
		King_Square=all_piece_list[PIECE_TYPE_INDEX.White_King_index]
	else:
		King_Square=all_piece_list[PIECE_TYPE_INDEX.Black_King_index]
	
	return square_under_attack(color,King_Square)


func check_detection(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE) -> bool:
	
	
	var testing_board=New_Board.new(all_piece_list.duplicate())
	
	testing_board.make_move(piece_index,piece_square,target_square)
	
	return testing_board.King_in_threat(find_color_from_type_index(piece_index))


func make_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE) -> void:
	
	emit_signal("making_move",piece_index,piece_square,target_square)
	
	remove_piece_on_square(piece_square)
	set_piece_on_square(piece_index,target_square)
	
	var color=find_color_from_type_index(piece_index)
	var type=find_type_from_type_index(piece_index)
	
	if target_square&en_passant_square!=0 and type==Pawn:
		var en_passanting_square=find_square_with_movement(target_square,0,-1 if color else 1)
		make_move(-1,en_passanting_square,en_passanting_square)
	
	en_passant_square=0
	
	#castle and en passant
	match target_square:#if rook is taken
			BIT_SQUARE.a1:
				can_castle[0]=false
			BIT_SQUARE.h1:
				can_castle[1]=false
			BIT_SQUARE.a8:
				can_castle[2]=false
			BIT_SQUARE.h8:
				can_castle[3]=false
	
	match type:
		Pawn:
			if color:
				if piece_square>=BIT_SQUARE.a2 and piece_square<=BIT_SQUARE.h2 and target_square>=BIT_SQUARE.a4 and target_square<=BIT_SQUARE.h4:
					en_passant_square^=find_square_with_movement(target_square,0,-1)
					
			else:
				if piece_square>=BIT_SQUARE.a7 and piece_square<=BIT_SQUARE.h7 and target_square>=BIT_SQUARE.a5 and target_square<=BIT_SQUARE.h5:
					en_passant_square^=find_square_with_movement(target_square,0,1)
					
		Rook:
			if color:
				if piece_square==BIT_SQUARE.a1:
					can_castle[0]=false
				elif piece_square==BIT_SQUARE.h1:
					can_castle[1]=false
			else:
				if piece_square==BIT_SQUARE.a8:
					can_castle[2]=false
				elif piece_square==BIT_SQUARE.h8:
					can_castle[3]=false

		King:
			if color:
				if can_castle[0] and target_square==BIT_SQUARE.c1:
					make_move(get_type_index_uisng_type_and_color(Rook,color),BIT_SQUARE.a1,BIT_SQUARE.d1)
				elif can_castle[1] and target_square==BIT_SQUARE.g1:
					make_move(get_type_index_uisng_type_and_color(Rook,color),BIT_SQUARE.h1,BIT_SQUARE.f1)
				can_castle[0]=false
				can_castle[1]=false
			else:
				if can_castle[2] and target_square==BIT_SQUARE.c8:
					make_move(get_type_index_uisng_type_and_color(Rook,color),BIT_SQUARE.a8,BIT_SQUARE.d8)
				elif can_castle[3] and target_square==BIT_SQUARE.g8:
					make_move(get_type_index_uisng_type_and_color(Rook,color),BIT_SQUARE.h8,BIT_SQUARE.f8)
				can_castle[2]=false
				can_castle[3]=false
	
	if color != null:
		if King_in_threat(not color) and not len(win)>0 and not King_in_threat(color):
			if checkmate_detection(not color):
				win.append(color)


func checkmate_detection(color:bool) -> bool:
	if get_all_move_for_color(color)==[] and King_in_threat(color):
		emit_signal("checkmate",not color)
		return true
	return false


func get_evaluation() -> float:
	if len(win)>0:
		if win[0]:
			return 1000000.0
		else:
			return -1000000.0
	
	
	var evaluation:float=0.0
	for coordinate in range(64):
		var piece_index:PIECE_TYPE_INDEX=find_piece_type_index_on_square(1<<coordinate)
		var color=find_color_from_type_index(piece_index)
		var type:int=find_type_from_type_index(piece_index)
		var added:int=0
		match type:
			Pawn:
				added+=1
			Rook:
				added+=4
			Knight:
				added+=3
			Bishop:
				added+=3
			Queen:
				added+=9
			King:
				added+=0
		if color==false:
			added*=-1
		evaluation+=added
	return evaluation
