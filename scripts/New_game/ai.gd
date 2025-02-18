extends Object
class_name  chess_ai


@export var my_color:bool=true
@export var count:int=0
@export var checkmate_counter:int=0

func find_next_best_move_on_board(board:New_Board) -> Array:
	var move:Array
	
	
	
	return move
	

func minimax_alpha_beta(board:New_Board,depth:int,color:bool,alpha:float=-1000000.0,beta:float=1000000.0)-> float:
	
	if depth == 0 or len(board.win)>0:
		if color:
			return board.get_evaluation()
		else:
			return -board.get_evaluation()
	
	#var best:float=-10000
	
	
	for move in board.get_all_move_for_color(color):
		
		var testing_board=New_Board.new(board.all_piece_list.duplicate(),
		board.piece_dic.duplicate(),
		board.en_passant_square,
		board.can_castle.duplicate(),
		board.win.duplicate(),
		board.White_attack_masks_for_pieces.duplicate(),
		board.White_attack_mask.duplicate(),
		board.White_pining_masks.duplicate(),
		board.White_checking_masks.duplicate(),
		board.Black_attack_mask.duplicate(),
		board.Black_attack_masks_for_pieces.duplicate(),
		board.Black_pining_masks.duplicate(),
		board.Black_checking_masks.duplicate())
		testing_board.make_move(move[0],move[1],move[2])
		
		var val = -minimax_alpha_beta(testing_board,depth-1,not color,-beta,-alpha)
		#best = max(val,best)
		
		if val>beta:
			return beta
		alpha=max(alpha,val)
		
	return alpha

func minimax(board:New_Board,depth:int,color:bool)-> float:
	
	if depth == 0 or len(board.win)>0:
		if color:
			return board.get_evaluation()
		else:
			return -board.get_evaluation()
	
	var best:float=-1000000
	
	for move in board.get_all_move_for_color(color):
		var testing_board=New_Board.new(board.all_piece_list.duplicate(),
		board.piece_dic.duplicate(),
		board.en_passant_square,
		board.can_castle.duplicate(),
		board.win.duplicate(),
		board.White_attack_masks_for_pieces.duplicate(),
		board.White_attack_mask.duplicate(),
		board.White_pining_masks.duplicate(),
		board.White_checking_masks.duplicate(),
		board.Black_attack_mask.duplicate(),
		board.Black_attack_masks_for_pieces.duplicate(),
		board.Black_pining_masks.duplicate(),
		board.Black_checking_masks.duplicate())
		testing_board.make_move(move[0],move[1],move[2])
		
		var val = -minimax(testing_board,depth-1,not color)
		best = max(val,best)
	
	return best


func find_all_moves(board:New_Board,depth:int,starting_color:bool):
	if depth == 0 or len(board.win)>0:
		count+=1
		if count%10000==0:
			print("number of moves calculated: ",count)
		if len(board.win)>0:
			checkmate_counter+=1
		return
	
	var move_list=board.get_all_move_for_color(starting_color)
	for move in move_list:
		var testing_board=New_Board.new(board.all_piece_list.duplicate(),
		board.piece_dic.duplicate(),
		board.en_passant_square,
		board.can_castle.duplicate(),
		board.win.duplicate(),
		board.White_attack_masks_for_pieces.duplicate(),
		board.White_attack_mask.duplicate(),
		board.White_pining_masks.duplicate(),
		board.White_checking_masks.duplicate(),
		board.Black_attack_mask.duplicate(),
		board.Black_attack_masks_for_pieces.duplicate(),
		board.Black_pining_masks.duplicate(),
		board.Black_checking_masks.duplicate())
		testing_board.make_move(move[0],move[1],move[2])
		find_all_moves(testing_board,depth-1,not starting_color)
