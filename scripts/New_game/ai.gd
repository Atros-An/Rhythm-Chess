extends Object
class_name  chess_ai


@export var my_color:bool=true
var count:int=0
func find_next_best_move_on_board(board:New_Board) -> Array:
	var move:Array
	
	
	
	return move
	

func minimax(board:New_Board,depth:int,color:bool,alpha:float=-1000000.0,beta:float=1000000.0)-> float:
	
	if depth == 0 or len(board.win)>0:
		count+=1
		print(count)
		if color:
			return board.get_evaluation()
		else:
			return -board.get_evaluation()
	
	#var best:float=-10000
	
	
	for move in board.get_all_move_for_color(color):
		var test_board:=New_Board.new(board.all_piece_list.duplicate())
		test_board.make_move(move[0],move[1],move[2])
		var val = -minimax(test_board,depth-1,not color,-beta,-alpha)
		#best = max(val,best)
		if val>beta:
			return beta
		alpha=max(alpha,val)
		
	return alpha
	
	

