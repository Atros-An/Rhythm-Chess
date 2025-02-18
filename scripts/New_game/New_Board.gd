extends Game_Assets
class_name New_Board

@export var all_piece_list:Array[int]#=[
	#71776119061217280,-9151314442816847872,4755801206503243776,2594073385365405696,576460752303423488,1152921504606846976,
	#65280,129,66,36,8,16]

@export var piece_dic:Dictionary

@export var en_passant_square:BIT_SQUARE#=0
@export var can_castle:Array[bool]=[true,true,true,true]
@export var win:Array[bool]=[]

@export var White_attack_masks_for_pieces:Dictionary
@export var White_attack_mask:Array[int]=[0]
@export var White_pining_masks:Dictionary
@export var White_checking_masks:Dictionary
@export var Black_attack_mask:Array[int]=[0]
@export var Black_attack_masks_for_pieces:Dictionary
@export var Black_pining_masks:Dictionary
@export var Black_checking_masks:Dictionary


signal making_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE)
signal checkmate(winner)

var move_functions:Dictionary= {
	Pawn: find_available_move_for_pawn,
	Rook: find_available_move_for_rook,
	Knight: find_available_move_for_knight,
	Bishop: find_available_move_for_bishop,
	Queen: find_available_move_for_queen,
	King: find_available_move_for_king,
}
var attack_funtions:Dictionary= {
	Pawn: find_attacking_square_for_pawn,
	Rook: find_pinning_attack_for_rook,
	Knight: find_available_move_for_knight,
	Bishop: find_pinning_attack_for_bishop,
	Queen: find_pinning_attack_for_queen,
	King: find_basic_move_for_king,
}

func _init(
			input_piece_list:Array[int]=[
			71776119061217280,-9151314442816847872,4755801206503243776,2594073385365405696,576460752303423488,1152921504606846976,
			65280,129,66,36,8,16],
			input_piece_dic:Dictionary={
			BIT_SQUARE.a8:Black_Rook,BIT_SQUARE.b8:Black_Knight,	BIT_SQUARE.c8:Black_Bishop,	BIT_SQUARE.d8:Black_Queen,	BIT_SQUARE.e8:Black_King,BIT_SQUARE.f8:Black_Bishop,	BIT_SQUARE.g8:Black_Knight,	BIT_SQUARE.h8:Black_Rook,
			BIT_SQUARE.a7:Black_Pawn,BIT_SQUARE.b7:Black_Pawn,		BIT_SQUARE.c7:Black_Pawn,	BIT_SQUARE.d7:Black_Pawn,	BIT_SQUARE.e7:Black_Pawn,BIT_SQUARE.f7:Black_Pawn,		BIT_SQUARE.g7:Black_Pawn,	BIT_SQUARE.h7:Black_Pawn,
			
			BIT_SQUARE.a2:White_Pawn,BIT_SQUARE.b2:White_Pawn,		BIT_SQUARE.c2:White_Pawn,	BIT_SQUARE.d2:White_Pawn,	BIT_SQUARE.e2:White_Pawn,BIT_SQUARE.f2:White_Pawn,		BIT_SQUARE.g2:White_Pawn,	BIT_SQUARE.h2:White_Pawn,
			BIT_SQUARE.a1:White_Rook,BIT_SQUARE.b1:White_Knight,	BIT_SQUARE.c1:White_Bishop,	BIT_SQUARE.d1:White_Queen,	BIT_SQUARE.e1:White_King,BIT_SQUARE.f1:White_Bishop,	BIT_SQUARE.g1:White_Knight,	BIT_SQUARE.h1:White_Rook
			},
			input_en_passant_square:BIT_SQUARE=0,
			input_can_castle:Array[bool]=[true,true,true,true],
			input_win:Array[bool]=[],
			input_White_attack_masks_for_pieces:Dictionary={},
			input_White_attack_mask:Array[int]=[0],
			input_White_pining_masks:Dictionary={},
			input_White_checking_masks:Dictionary={},
			input_Black_attack_mask:Array[int]=[0],
			input_Black_attack_masks_for_pieces:Dictionary={},
			input_Black_pining_masks:Dictionary={},
			input_Black_checking_masks:Dictionary={}
			) -> void:
	
	self.all_piece_list=input_piece_list
	self.piece_dic=input_piece_dic
	self.en_passant_square=input_en_passant_square
	self.can_castle=input_can_castle
	self.win=input_win
	self.White_attack_masks_for_pieces=input_White_attack_masks_for_pieces
	self.White_attack_mask=input_White_attack_mask
	self.White_pining_masks=input_White_pining_masks
	self.White_checking_masks=input_White_checking_masks
	self.Black_attack_mask=input_Black_attack_mask
	self.Black_attack_masks_for_pieces=input_Black_attack_masks_for_pieces
	self.Black_pining_masks=input_Black_pining_masks
	self.Black_checking_masks=input_Black_checking_masks
	



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
	
	return int(log(square)/log(2))


func bitboard_to_fen() -> String:
	
	
	
	var piece_map = {
	PIECE_TYPE_INDEX.White_King_index: "K",
	PIECE_TYPE_INDEX.White_Queens_index: "Q",
	PIECE_TYPE_INDEX.White_Rooks_index: "R",
	PIECE_TYPE_INDEX.White_Bishops_index: "B",
	PIECE_TYPE_INDEX.White_Knights_index: "N",
	PIECE_TYPE_INDEX.White_Pawns_index: "P",
	PIECE_TYPE_INDEX.Black_King_index: "k",
	PIECE_TYPE_INDEX.Black_Queens_index: "q",
	PIECE_TYPE_INDEX.Black_Rooks_index: "r",
	PIECE_TYPE_INDEX.Black_Bishops_index: "b",
	PIECE_TYPE_INDEX.Black_Knights_index: "n",
	PIECE_TYPE_INDEX.Black_Pawns_index: "p",
	PIECE_TYPE_INDEX.null_piece_index: "?"
	}

	#Piece placement
	var piece_placement:String=""
	for coordinate in range(64):
		if coordinate%8==0:
			piece_placement+="/"
		piece_placement+=piece_map[find_piece_type_index_on_square(coordinate_to_square(coordinate))]
	piece_placement=piece_placement.right(piece_placement.length()-1)
	piece_placement=piece_placement.replace("????????","8")
	piece_placement=piece_placement.replace("???????","7")
	piece_placement=piece_placement.replace("??????","6")
	piece_placement=piece_placement.replace("?????","5")
	piece_placement=piece_placement.replace("????","4")
	piece_placement=piece_placement.replace("???","3")
	piece_placement=piece_placement.replace("??","2")
	piece_placement=piece_placement.replace("?","1")
	
	#Active color
	var active_color_fen:String = "w"

	#Castling rights
	var castling_fen:String = ""
	if can_castle[0]:
		castling_fen += "K"
	if can_castle[1]:
		castling_fen += "Q"
	if can_castle[2]:
		castling_fen += "k"
	if can_castle[3]:
		castling_fen += "q"
	if castling_fen == "":
		castling_fen = "-"

	#En passant square
	var en_passant_fen:String = "-" if en_passant_square == 0 else coordinate_list[square_to_coordinate(en_passant_square)].to_lower()

	#Halfmove clock and fullmove number
	var halfmove_fen:String = "0"
	var fullmove_fen:String = "0"

	return piece_placement + " " + active_color_fen + " " + castling_fen + " " + en_passant_fen + " " + halfmove_fen + " " + fullmove_fen



func find_piece_type_index_on_square(square:BIT_SQUARE) -> PIECE_TYPE_INDEX:
	return piece_dic.get(square,PIECE_TYPE_INDEX.null_piece_index)


func remove_piece_on_square(square:BIT_SQUARE) -> void:
	if piece_dic.erase(square):
		square^=-1
		for i in range(12):
			all_piece_list[i]=all_piece_list[i]&square


func set_piece_on_square(piece_index:PIECE_TYPE_INDEX,square:BIT_SQUARE) -> void:
	if piece_index!=PIECE_TYPE_INDEX.null_piece_index:
		remove_piece_on_square(square)
		piece_dic[square]=piece_index
		all_piece_list[piece_index]|=square


func is_square_playable_for_color(color:bool,square:BIT_SQUARE) -> bool:
	var type_index=find_piece_type_index_on_square(square)
	return (square != 0) and (find_color_from_type_index(type_index) != color)


func is_square_empty(square:BIT_SQUARE) -> bool:
	return find_piece_type_index_on_square(square)==PIECE_TYPE_INDEX.null_piece_index


func Never_moved_dectetion_for_pawn(color:bool,piece_square:BIT_SQUARE) -> bool:
	if color:
		return BIT_SQUARE.a2<=piece_square and BIT_SQUARE.h2>=piece_square
	return BIT_SQUARE.a7<=piece_square and BIT_SQUARE.h7>=piece_square


func find_square_with_movement(square:BIT_SQUARE,xMove:int=0,yMove:int=0) -> BIT_SQUARE:
	if square==BIT_SQUARE.null_square:
		return BIT_SQUARE.null_square

	var coordinate=square_to_coordinate(square)
	
	var row:int=8*((coordinate/8)-yMove)
	var column:int=coordinate%8+xMove
	if row+column>=64 or row<0 or column<0 or column>=8:
		return BIT_SQUARE.null_square
	else:
		return 1<<row+column


func find_available_squares_in_direction(color:bool,piece_square:BIT_SQUARE,dir_index:int) -> int:
	var moveable_squares:int=0
	var current_square:BIT_SQUARE=piece_square
	var boundary:Array=boundary_dic[dir_index]
	var not_on_boundary:bool=true
	
	while not_on_boundary:

		for b in boundary:
			if current_square&b!=0:
				not_on_boundary=false
		if not not_on_boundary:
			break

		if dir_index>0:
			current_square<<=dir_index
		elif dir_index<0:
			current_square>>=abs(dir_index)
		if current_square<0:
			current_square*=-1

		moveable_squares|=current_square
		if not is_square_empty(current_square):
			break
	
	return moveable_squares


func find_pinning_line_in_direction(color:bool,piece_square:BIT_SQUARE,dir_index:int) -> Array[int]:
	
	var current_square:BIT_SQUARE=piece_square
	var boundary:Array=boundary_dic[dir_index]
	var not_on_boundary:bool=true
	var block:int=0
	var moveable_squares:int=0
	while not_on_boundary:

		for b in boundary:
			if current_square&b!=0:
				not_on_boundary=false
		if not not_on_boundary:
			break

		if dir_index>0:
			current_square<<=dir_index
		elif dir_index<0:
			current_square>>=-dir_index
		if current_square<0:
			current_square*=-1
		moveable_squares|=current_square
		
		var square_type:int=find_piece_type_index_on_square(current_square)
		if color==find_color_from_type_index(square_type):
			break

		elif find_type_from_type_index(square_type)==King:
			return [moveable_squares,block]

		elif square_type != PIECE_TYPE_INDEX.null_piece_index:
			if block==0:
				block=moveable_squares
			else:
				return [block,0]

	if block!=0:
		return [block,0]
	return [moveable_squares,0]


func find_takable_square_for_pawn(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	var dirction=-1
	if color:
		dirction=1
	
	
	for dir in [-1,1]:
		var square=find_square_with_movement(piece_square,dir,dirction)
		if is_square_playable_for_color(color,square) and (
			(not is_square_empty(square) )!=(
				square&en_passant_square!=0 
				and is_square_playable_for_color(color,find_square_with_movement(square,0,-1 if color else 1))
				and ((piece_square>=BIT_SQUARE.a5 and piece_square<=BIT_SQUARE.h5) 
				if color else 
				(piece_square>=BIT_SQUARE.a4 and piece_square<=BIT_SQUARE.h4))
				and not check_detection(find_piece_type_index_on_square(piece_square),piece_square,square)
				)
			):

			
			moveable_squares|=square


	return moveable_squares


func find_attacking_square_for_pawn(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	var dirction=-1
	if color:
		dirction=1
	
	for dir in [-1,1]:
		var square=find_square_with_movement(piece_square,dir,dirction)
		moveable_squares|=square

	return moveable_squares


func find_available_move_for_pawn(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	var dirction=-1
	if color:
		dirction=1

	var squar1=find_square_with_movement(piece_square,0,dirction)
	if is_square_empty(squar1):
		moveable_squares|=squar1
		if Never_moved_dectetion_for_pawn(color,piece_square):
			var square2=find_square_with_movement(piece_square,0,2*dirction)
			if is_square_empty(square2):
				moveable_squares|=square2
	
	
	moveable_squares|=find_takable_square_for_pawn(color,piece_square)
	
	return moveable_squares


func find_available_move_for_rook(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	for i in rook_dir:
		moveable_squares|=find_available_squares_in_direction(color,piece_square,i)
	return moveable_squares


func find_pinning_attack_for_rook(color:bool,piece_square:BIT_SQUARE) -> Array:
	var attacking_tuple_list:Array=[]
	for i in rook_dir:
		var pinning_attack=find_pinning_line_in_direction(color,piece_square,i)
		if pinning_attack[0]!=0:
			attacking_tuple_list.append(pinning_attack)
	return attacking_tuple_list


func find_available_move_for_knight(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	for u in [2,-2]:
		for i in [1,-1]:
			for s in [find_square_with_movement(piece_square,i,u),find_square_with_movement(piece_square,u,i)]:
				moveable_squares|=s
	return moveable_squares


func find_available_move_for_bishop(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	for i in bishop_dir:
		moveable_squares|=find_available_squares_in_direction(color,piece_square,i)
	return moveable_squares


func find_pinning_attack_for_bishop(color:bool,piece_square:BIT_SQUARE) -> Array:
	var attacking_tuple_list:Array=[]
	for i in bishop_dir:
		var pinning_attack=find_pinning_line_in_direction(color,piece_square,i)
		if pinning_attack[0]!=0:
			attacking_tuple_list.append(pinning_attack)
	return attacking_tuple_list


func find_available_move_for_queen(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	for i in queen_dir:
		moveable_squares|=find_available_squares_in_direction(color,piece_square,i)
	return moveable_squares


func find_pinning_attack_for_queen(color:bool,piece_square:BIT_SQUARE) -> Array:
	var attacking_tuple_list:Array=[]
	for i in queen_dir:
		var pinning_attack=find_pinning_line_in_direction(color,piece_square,i)
		if pinning_attack[0]!=0:
			attacking_tuple_list.append(pinning_attack)
	return attacking_tuple_list


func find_basic_move_for_king(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	for x in [-1,0,1]:
		for y in [-1,0,1]:
			var square=find_square_with_movement(piece_square,x,y)
			moveable_squares|=square
	return moveable_squares


func find_available_move_for_king(color:bool,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	
	moveable_squares|=find_basic_move_for_king(color,piece_square)
	
	#castle
	if piece_square==(BIT_SQUARE.e1 if color else BIT_SQUARE.e8) and not King_in_threat(color):
		if color:
			if can_castle[0] and not square_under_attack(color,BIT_SQUARE.d1) and is_square_empty(BIT_SQUARE.b1) and is_square_empty(BIT_SQUARE.c1) and is_square_empty(BIT_SQUARE.d1):
				moveable_squares|=BIT_SQUARE.c1
			if can_castle[1] and not square_under_attack(color,BIT_SQUARE.f1) and is_square_empty(BIT_SQUARE.g1) and is_square_empty(BIT_SQUARE.f1):
				moveable_squares|=BIT_SQUARE.g1
		else:
			
			if can_castle[2] and not square_under_attack(color,BIT_SQUARE.d8) and is_square_empty(BIT_SQUARE.b8) and is_square_empty(BIT_SQUARE.c8) and is_square_empty(BIT_SQUARE.d8):
				moveable_squares|=BIT_SQUARE.c8
			if can_castle[3] and not square_under_attack(color,BIT_SQUARE.f8) and is_square_empty(BIT_SQUARE.g8) and is_square_empty(BIT_SQUARE.f8):
				moveable_squares|=BIT_SQUARE.g8
	
	return moveable_squares


func find_available_move_for_piece(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE) -> int:
	var moveable_squares:int=0
	var final_squares:int=0
	var type=find_type_from_type_index(piece_index)
	var color=find_color_from_type_index(piece_index)
	
	moveable_squares=move_functions[type].call(color,piece_square)

	for i in int_squares_to_bit_square_lists(moveable_squares):
		if square_check(color,type,piece_square,i):
			final_squares|=(i)

	return final_squares


func square_check(color:int,type:int,piece_square:BIT_SQUARE,square:BIT_SQUARE) -> bool:
	if not is_square_playable_for_color(color,square) or find_type_from_type_index(find_piece_type_index_on_square(square))==King:
		return false

	if type==King:
		if square&(White_attack_mask[0] if not color else Black_attack_mask[0])!=0:
			return false

	else:
		var check_masks:Dictionary
		var pinning_masks:Dictionary
		if not color:
			check_masks=White_checking_masks
			pinning_masks=White_pining_masks
		else:
			check_masks=Black_checking_masks
			pinning_masks=Black_pining_masks

		if len(check_masks)==1:
			for check in check_masks.values():
				if square&check==0:
					return false
		if len(pinning_masks)!=0:
			for pin in pinning_masks.values():
				if piece_square&pin!=0 and square&pin==0:
					return false
	return true


func find_attack_for_piece(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE) -> int:
	var attack_squares:int=0
	var type=find_type_from_type_index(piece_index)
	var color=find_color_from_type_index(piece_index)
	attack_squares=attack_funtions[type].call(color,piece_square)
	
	return attack_squares


func get_square_for_all_piece() -> Array:
	var all_piece_array:Array
	for piece_index in range(12):
		var piece_bitboard:int = all_piece_list[piece_index]
		while piece_bitboard != 0:
			var square:BIT_SQUARE = piece_bitboard & -piece_bitboard  # Get LSB
			all_piece_array.append([piece_index,square])
			piece_bitboard -= square  # Pop LSB
	return all_piece_array


func get_square_for_all_piece_for_color(color:bool) -> Array:
	var all_piece_array:Array
	for piece_index in range(6):
		var type_index=get_type_index_uisng_type_and_color(piece_index,color)

		var piece_bitboard:int = all_piece_list[type_index]
		while piece_bitboard != 0:
			var square:BIT_SQUARE = piece_bitboard & -piece_bitboard  # Get LSB
			all_piece_array.append([type_index,square])
			piece_bitboard &= piece_bitboard - 1  # Pop LSB
	return all_piece_array


func get_legal_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE) -> Array:
	var move_list:Array
	var piece_is_pawn:bool=find_type_from_type_index(piece_index)==Pawn
	

	for move_square in int_squares_to_bit_square_lists(find_available_move_for_piece(piece_index,piece_square)):
		move_list.append([piece_index,piece_square,move_square])
		if piece_is_pawn:#promotion
			var color=find_color_from_type_index(piece_index)
			if color and move_square<=128:
				for promotion_type in [PIECE_TYPE_INDEX.White_Rooks_index,PIECE_TYPE_INDEX.White_Knights_index,PIECE_TYPE_INDEX.White_Bishops_index,PIECE_TYPE_INDEX.White_Queens_index]:
					move_list.append([promotion_type,piece_square,move_square])
			elif not color and square_to_coordinate(move_square)>=56:
				for promotion_type in [PIECE_TYPE_INDEX.Black_Rooks_index,PIECE_TYPE_INDEX.Black_Knights_index,PIECE_TYPE_INDEX.Black_Bishops_index,PIECE_TYPE_INDEX.Black_Queens_index]:
					move_list.append([promotion_type,piece_square,move_square])

	return move_list


func get_all_move_for_color(color:bool) -> Array:
	var all_move_list:Array#=[[-1,0,0]]

	for piece_set in get_square_for_all_piece_for_color(color):
		var piece_index:PIECE_TYPE_INDEX=piece_set[0]
		var square:BIT_SQUARE=piece_set[1]
		all_move_list.append_array(get_legal_move(piece_index,square))
	
	return all_move_list


func get_all_legal_move() -> Array:
	var all_move_list:Array#=[[-1,0,0]]
	for piece_set in get_square_for_all_piece():
		var piece_index:PIECE_TYPE_INDEX=piece_set[0]
		var square:BIT_SQUARE=piece_set[1]
		if piece_index!=PIECE_TYPE_INDEX.null_piece_index:
			all_move_list.append_array(get_legal_move(piece_index,square))
	
	return all_move_list


func square_under_attack(color:bool,piece_square:BIT_SQUARE) -> bool:

	if not color and (White_attack_mask[0] & piece_square != 0):
		return true
	elif color and (Black_attack_mask[0] & piece_square != 0):
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
	
	var testing_board=New_Board.new(all_piece_list.duplicate(),
	piece_dic.duplicate(),
	en_passant_square,
	can_castle.duplicate(),
	win.duplicate(),
	White_attack_masks_for_pieces.duplicate(),
	White_attack_mask.duplicate(),
	White_pining_masks.duplicate(),
	White_checking_masks.duplicate(),
	Black_attack_mask.duplicate(),
	Black_attack_masks_for_pieces.duplicate(),
	Black_pining_masks.duplicate(),
	Black_checking_masks.duplicate())
	
	testing_board.basic_make_move(piece_index,piece_square,target_square)
	
	return testing_board.King_in_threat(find_color_from_type_index(piece_index))


func update_attack_masks_after_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE) -> void:
	if piece_index==PIECE_TYPE_INDEX.null_piece_index:
		return
	
	var color=find_color_from_type_index(piece_index)
	var type:int=find_type_from_type_index(piece_index)
	
	var merged_attack_masks=White_attack_masks_for_pieces.duplicate()
	merged_attack_masks.merge(Black_attack_masks_for_pieces)
	
	for masks in merged_attack_masks.values():
		for mask in masks:
			if mask&piece_square!=0 or mask&target_square!=0:
				var square_new=merged_attack_masks.find_key(mask)
				if square_new==null:
					square_new=0
				var piece_index_new:PIECE_TYPE_INDEX=find_piece_type_index_on_square(square_new)
				if piece_index_new!=PIECE_TYPE_INDEX.null_piece_index:
					var type_new:int=find_type_from_type_index(piece_index_new)
					var color_new:bool=find_color_from_type_index(piece_index_new)
					#merged_attack_masks.erase(squae_new)
					update_attack_masks_for_piece(type_new,color_new,square_new)
	
	update_attack_masks_for_piece(type,color,target_square,piece_square)


func update_attack_masks_for_piece(type:int,color:bool,square:BIT_SQUARE,update_square:BIT_SQUARE=square) -> void:
	
	var attack_mask:Array
	var attack_masks_for_pieces:Dictionary
	var check_masks:Dictionary
	var pinning_masks:Dictionary
	
	if color:
		attack_mask=White_attack_mask
		attack_masks_for_pieces=White_attack_masks_for_pieces
		check_masks=White_checking_masks
		pinning_masks=White_pining_masks
	else:
		attack_mask=Black_attack_mask
		attack_masks_for_pieces=Black_attack_masks_for_pieces
		check_masks=Black_checking_masks
		pinning_masks=Black_pining_masks

	attack_mask[0]=0
	attack_masks_for_pieces.erase(update_square)
	attack_masks_for_pieces[square]=[]
	check_masks.erase(update_square)
	check_masks.erase(square)
	pinning_masks.erase(update_square)
	pinning_masks.erase(square)
	
	
	if sliding_piece.has(type):
		var sliding_attack:Array=attack_funtions[type].call(color,square)
		for attack_tuple in sliding_attack:
			if attack_tuple[1]!=0:
				attack_masks_for_pieces[square].append(attack_tuple[1])
				pinning_masks[square]=attack_tuple[0]
			else:
				attack_masks_for_pieces[square].append(attack_tuple[0])
	else:
		var attack_squares:int=attack_funtions[type].call(color,square)
		
		for i in int_squares_to_bit_square_lists(attack_squares):
			attack_masks_for_pieces[square].append(attack_squares)
	
	for masks in attack_masks_for_pieces.values():
		for mask in masks:
			attack_mask[0]|=mask
			if mask&all_piece_list[get_type_index_uisng_type_and_color(King,not color)]!=0:
				check_masks[square]=mask|square


func basic_make_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE) -> void:
	remove_piece_on_square(piece_square)
	set_piece_on_square(piece_index,target_square)
	
	var color=find_color_from_type_index(piece_index)
	var type:PIECE_TYPE_INDEX=find_type_from_type_index(piece_index)
	
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
	update_attack_masks_after_move(piece_index,piece_square,target_square)


func make_move(piece_index:PIECE_TYPE_INDEX,piece_square:BIT_SQUARE,target_square:BIT_SQUARE) -> void:
	
	emit_signal("making_move",piece_index,piece_square,target_square)
	basic_make_move(piece_index,piece_square,target_square)
	
	var color=find_color_from_type_index(piece_index)
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
	for piece_set in get_square_for_all_piece():
		var piece_index=piece_set[0]
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
