extends Node2D









@onready var Board_Square:PackedScene=preload("res://scenes/board_square.tscn")
@onready var Board_piece:PackedScene=preload("res://scenes/piece.tscn")
@onready var Promotion_Menu:PackedScene=preload("res://scenes/promotion_menu.tscn")
@onready var Board_Grid:GridContainer=$"Board/Board Grid"


var Null_piece:=PIECE.new()
@onready var Null_square:SQUARE=Board_Square.instantiate()

var White_King:PIECE
var Black_King:PIECE


var Used_selected_piece_list:Array[PIECE]#=[]

var piece_move_count:int#=1

const coordinate_list:Array[String]=["a","b","c","d","e","f","g","h"]

enum {White,Black}

enum {King,Queen,Bishop,Knight,Rook,Pawn}

var game_board:New_Board=New_Board.new()


var Up_list:Array[bool]=[false,false]
var Left_list:Array[bool]=[false,false]
var Down_list:Array[bool]=[false,false]
var Right_list:Array[bool]=[false,false]


#var Rhyme_counter:int#0

var Rhyme_list:Array#=[]
const Perfect_range:float=0.25
const Great_range:float=0.5

const Board_glow_min:float=0.4
const Board_glow_max:float=2.6
var Board_glow_color:float

var Music_counter:int=-1


func coordinate_to_square(coordinate:Game_Assets.COORDINATE) -> Game_Assets.BIT_SQUARE:
	var return_square:Game_Assets.BIT_SQUARE=0
	if coordinate>=0 and coordinate<64:
		return_square=1<<coordinate
	return return_square


func square_to_coordinate(square:Game_Assets.BIT_SQUARE) -> Game_Assets.COORDINATE:
	if square==0:
		return -1
	
	if square==-9223372036854775808:
		return 63
	
	var coordinate:Game_Assets.COORDINATE = 0
	
	while square > 1:
		square >>= 1
		coordinate+=1
	return coordinate


func square_to_bit_square(square:SQUARE) -> Game_Assets.BIT_SQUARE:
	return 1<<(Board_Grid.get_children().find(square))


func bit_square_to_square(square:Game_Assets.BIT_SQUARE) -> SQUARE:
	var coordinate=square_to_coordinate(square)
	if coordinate!=-1:
		return Board_Grid.get_children()[coordinate]
	return Null_square


func get_bit_square_from_piece(piece:PIECE) -> Game_Assets.BIT_SQUARE:
	return square_to_bit_square(piece.Home_Square)


func get_piece_index_for_piece(piece:PIECE) -> Game_Assets.PIECE_TYPE_INDEX:
	return (5-piece.type)+(0 if piece.color==White else 6)


func get_piece_on_bit_square(square:Game_Assets.BIT_SQUARE) -> PIECE:
	return find_piece_on_square(bit_square_to_square(square))


func making_move(piece_index:Game_Assets.PIECE_TYPE_INDEX,piece_square:Game_Assets.BIT_SQUARE,target_square:Game_Assets.BIT_SQUARE):
	var Piece=get_piece_on_bit_square(piece_square)
	var square=bit_square_to_square(target_square)
	if piece_index!=-1:
		Piece.Home_Square=square
		Piece.available_list.append(Piece.Home_Square)
		if $Selection_layer.get_children().has(Piece):
			Deselect(Piece.color)
		else:
			Piece.reparent(square)
			move_piece_with_animation(Piece,square)
		capture_handling(Piece)
	else:
		if Piece==Null_piece:
			return
		if Piece.color==0:
			Global.White_Piece_list.erase(Piece)
		else:
			Global.Black_Piece_list.erase(Piece)
		Piece.queue_free()


func _ready() -> void:
	game_board.connect("making_move",making_move)
	game_board.connect("checkmate",end_game)
	reset_all_value()
	Board_init()
	Place_Piece()
	
	next_music()
	if Global.debug:
		$Button.visible=true


func _process(delta) -> void:
	Global.time+=delta
	Rhyme_handling()


func Board_init() -> void:
	var square_name:String
	for i in range(64):
		square_name=coordinate_list[i % 8]
		square_name+=str(int(round(((64-(i+1))/8)+0.5)))
		if int(round((i/8)+0.5))%2==1 and i % 2==0 or int(round((i/8)+0.5))%2==0 and i % 2==1:
			add_Square(false,square_name)
		else:
			add_Square(true,square_name)


func add_Square(dark:bool,Square_name:String) -> void:
	var new_square:SQUARE=Board_Square.instantiate()
	new_square.dark=dark
	new_square.name=Square_name
	Board_Grid.add_child(new_square)


func Place_Piece() -> void:
	var row:String
	White_King=add_Piece("e1",0,0)
	Black_King=add_Piece("e8",0,1)
	for color in [0,1]:
		row=str(color*7+1)
		#queen
		add_Piece("d"+row,1,color)
		#bishop
		add_Piece("c"+row,2,color)
		add_Piece("f"+row,2,color)
		#knight
		add_Piece("b"+row,3,color)
		add_Piece("g"+row,3,color)
		#rook
		add_Piece("a"+row,4,color)
		add_Piece("h"+row,4,color)
		#pawn
		for i in coordinate_list:
			add_Piece(i+str(int(row)+(-2*color+1)),5,color)


func add_Piece(coordinate:String,type:int,color:int) -> PIECE:
	var new_piece:PIECE=Board_piece.instantiate()
	new_piece.type=type
	new_piece.color=color
	get_Square(coordinate).add_child(new_piece)
	
	if color==White:
		Global.White_Piece_list.append(new_piece)
	elif color==Black:
		Global.Black_Piece_list.append(new_piece)
	return new_piece


func get_Square(coordinate:String,xMove:int=0,yMove:int=0) -> SQUARE:
	var row:int=(8-((int(coordinate.right(1)))+yMove))*8
	var column:int=coordinate_list.find(coordinate.left(1))+xMove
	if row+column>=64 or row<0 or column<0 or column>=8:
		return null
	else:
		return Board_Grid.get_child(row+column)


func find_piece_on_square(square) -> PIECE:
	if len(square.get_children())>4 and is_piece_valid(square.get_child(4)):
			return square.get_child(4)
	
	for i in Global.White_Piece_list+Global.Black_Piece_list:
		if i.Home_Square==square:
			return i

	return Null_piece


func is_piece_valid(piece:PIECE) -> bool:
	
	return piece != null and piece != Null_piece and is_instance_valid(piece)


func is_square_valid(square: SQUARE) -> bool:
	return square != null and is_instance_valid(square)


func is_square_blocked(square: SQUARE) -> bool:
	if is_square_valid(square):
		return is_piece_valid(find_piece_on_square(square))
	else:
		return false


func call_promotion(Promote_pawn:PIECE) -> void:

	var New_Promotion_Menu=Promotion_Menu.instantiate()
	if Promote_pawn.color==White:
		New_Promotion_Menu.global_position=Promote_pawn.global_position+Vector2(-64,64)
	else:
		New_Promotion_Menu.global_position=Promote_pawn.global_position+Vector2(-64,-576)
	New_Promotion_Menu.My_Pawn=Promote_pawn
	$Promotion_window.add_child(New_Promotion_Menu)


func find_next_piece_in_list(color:int,piece_type:int) -> PIECE:
	if piece_type==-1:
		return Null_piece
	
	var Piece_list=[]
	if color==White:
		Piece_list=Global.White_Piece_list
	elif color==Black:
		Piece_list=Global.Black_Piece_list
	for i in Piece_list:
		if int(i.type)==(piece_type):
			if not Input.is_action_pressed("shift") and not Used_selected_piece_list.has(i):
				Used_selected_piece_list.append(i)
				Deselect(color)
				return i
			elif Input.is_action_pressed("shift") and len(Used_selected_piece_list)>1:
				Used_selected_piece_list.erase(Used_selected_piece_list[-1])
				Deselect(color)
				return Used_selected_piece_list[-1]

	for i in Piece_list:
		if int(i.type)==(piece_type):
			if not Input.is_action_pressed("shift"):
				Used_selected_piece_list.clear()
				Used_selected_piece_list.append(i)
				Deselect(color)
				return i
			else:
				Used_selected_piece_list.append(i)
	if len(Used_selected_piece_list)>1:
		Deselect(color)
		return Used_selected_piece_list[-1]
	return Null_piece


func show_color_square(Square:SQUARE,R:float,G:float,B:float,A:float) -> void:
	if Square!=Null_square:
		var color_dot=Square.color_dot
		color_dot.visible=true
		color_dot.self_modulate=Color(R,G,B,A)


func Deselect(color:int) -> void:
	for Piece in $Selection_layer.get_children():
		
		if Piece.color==color:
			Piece.scale=Vector2(1,1)
			Piece.reparent(Piece.Home_Square)
			
			Piece.Home_Square.color_dot.visible=false
			for Square in Piece.available_list:
				Square.color_dot.visible=false
			move_piece_with_animation(Piece,Piece.Home_Square)
			
			Piece.available_list.clear()
			Piece.available_list.append(Piece.Home_Square)


func Selection_process(piece:PIECE) -> void:
	piece.reparent($Selection_layer)
	
	piece.scale=Vector2(1.1,1.1)
	show_color_square(piece.Home_Square,1,1,0.5,1)
	
	if $Selection_layer.get_children()!=[]:
		
		for i in $Selection_layer.get_children():
			
			for bit_square in game_board.int_squares_to_bit_square_lists(game_board.find_available_move_for_piece(get_piece_index_for_piece(i),get_bit_square_from_piece(i))):
				var square=bit_square_to_square(bit_square)
				show_color_square(square,0.5,1,1,1)
				i.available_list.append(square)


func piece_movement(Piece:PIECE,X_direction:int=0,Y_direction:int=0,side=0) -> void:
	var Piece_color:int=Piece.color
	if Up_list[Piece_color]:
		Y_direction+=1
	if Left_list[Piece_color]:
		X_direction-=1
	if Right_list[Piece_color]:
		X_direction+=1
	if Down_list[Piece_color]:
		Y_direction-=1

	var Target_Square:SQUARE=get_Square(Piece.Current_Square.name,X_direction,Y_direction)
	if not is_square_valid(Target_Square):
		
		if side==0:
			side=1
		else:
			side+=(side/abs(side))
		side=-side

		if Up_list[Piece_color]:
			Y_direction=1
			X_direction+=side
		if Left_list[Piece_color]:
			X_direction=-1
			Y_direction+=side
		if Right_list[Piece_color]:
			X_direction=1
			Y_direction+=side
		if Down_list[Piece_color]:
			Y_direction=-1
			X_direction+=side
	
	Target_Square=get_Square(Piece.Current_Square.name,X_direction,Y_direction)

	if not move_piece_with_animation(Piece,Target_Square) and not X_direction>7 and not Y_direction>7:
		piece_movement(Piece,X_direction,Y_direction,side)


func move_piece_with_animation(piece,Square_to_move) -> bool:
	if is_square_valid(Square_to_move) and piece.available_list.has(Square_to_move):
		var tween = create_tween()
		tween.tween_property(piece,"global_position",Square_to_move.global_position+Vector2(64,64),0.2)
		piece.Current_Square=Square_to_move
		return true
	else:
		return false


func play_piece(color:int) -> void:
	for Piece in $Selection_layer.get_children():
		if Piece.color==color:
			
			if Piece.Home_Square!=Piece.Current_Square:
				game_board.make_move(get_piece_index_for_piece(Piece),get_bit_square_from_piece(Piece),square_to_bit_square(Piece.Current_Square))
			
			if Piece.type==Pawn and ((not is_square_valid(get_Square(Piece.Current_Square.name,0,1))) or (not is_square_valid(get_Square(Piece.Current_Square.name,0,-1)))):
				call_promotion(Piece)

			if Used_selected_piece_list.has(Piece):
				Used_selected_piece_list.erase(Piece)


func capture_handling(capturer:PIECE) -> void:
	
	if capturer.color==White:
		for i in Global.Black_Piece_list:
			if i.Home_Square==capturer.Home_Square:
				Global.Black_Piece_list.erase(i)
				for Square in i.available_list:
					Square.get_child(2).visible=false
				i.queue_free()

	elif capturer.color==Black:
		for i in Global.White_Piece_list:
			if i.Home_Square==capturer.Home_Square:
				Global.White_Piece_list.erase(i)
				for Square in i.available_list:
					Square.get_child(2).visible=false
				i.queue_free()


func _input(event) -> void:
	
	if ((event is InputEventKey) and not (event.pressed)):
		if event.as_text_keycode()==Global.key_dic["White up"]:
			Up_list[White]=false
		elif event.as_text_keycode()==Global.key_dic["White left"]:
			Left_list[White]=false
		elif event.as_text_keycode()==Global.key_dic["White down"]:
			Down_list[White]=false
		elif event.as_text_keycode()==Global.key_dic["White right"]:
			Right_list[White]=false
		elif event.as_text_keycode()==Global.key_dic["Black up"]:
			Up_list[Black]=false
		elif event.as_text_keycode()==Global.key_dic["Black left"]:
			Left_list[Black]=false
		elif event.as_text_keycode()==Global.key_dic["Black down"]:
			Down_list[Black]=false
		elif event.as_text_keycode()==Global.key_dic["Black right"]:
			Right_list[Black]=false


	if ((event is InputEventKey) and (event.pressed)):
		if event.as_text_keycode()==Global.key_dic["White up"]:
			Up_list[White]=true
		elif event.as_text_keycode()==Global.key_dic["White left"]:
			Left_list[White]=true
		elif event.as_text_keycode()==Global.key_dic["White down"]:
			Down_list[White]=true
		elif event.as_text_keycode()==Global.key_dic["White right"]:
			Right_list[White]=true
		elif event.as_text_keycode()==Global.key_dic["Black up"]:
			Up_list[Black]=true
		elif event.as_text_keycode()==Global.key_dic["Black left"]:
			Left_list[Black]=true
		elif event.as_text_keycode()==Global.key_dic["Black down"]:
			Down_list[Black]=true
		elif event.as_text_keycode()==Global.key_dic["Black right"]:
			Right_list[Black]=true


		if event.as_text_keycode()=="Backspace":
			for i in $Selection_layer.get_children():
				print(i)


		if $Selection_layer.get_children()!=[]:
			for i in $Selection_layer.get_children():
				piece_movement(i)

		if event.as_text_keycode()==Global.key_dic["White confirm"]:
			
			if Global.On_Rhyme or Global.debug:
				play_piece(0)
			else:
				print("Miss")

		if event.as_text_keycode()==Global.key_dic["Black confirm"]:
			if Global.On_Rhyme or Global.debug:
				play_piece(1)
			else:
				print("Miss")


		if event.as_text_keycode()==Global.key_dic["White deselect"]:
			Deselect(0)
		if event.as_text_keycode()==Global.key_dic["Black deselect"]:
			Deselect(1)

		if Global.debug:
			print(event.as_text_keycode())



#finding piece

		var Selecting_piece_color:int=-1
		var Selecting_piece_type:int=-1
		
		if event.as_text_keycode()==Global.key_dic["White pawn"]:
			Selecting_piece_color=White
			Selecting_piece_type=Pawn
		elif event.as_text_keycode()==Global.key_dic["White rook"]:
			Selecting_piece_color=White
			Selecting_piece_type=Rook
		elif event.as_text_keycode()==Global.key_dic["White knight"]:
			Selecting_piece_color=White
			Selecting_piece_type=Knight
		elif event.as_text_keycode()==Global.key_dic["White bishop"]:
			Selecting_piece_color=White
			Selecting_piece_type=Bishop
		elif event.as_text_keycode()==Global.key_dic["White queen"]:
			Selecting_piece_color=White
			Selecting_piece_type=Queen
		elif event.as_text_keycode()==Global.key_dic["White king"]:
			Selecting_piece_color=White
			Selecting_piece_type=King
		elif event.as_text_keycode()==Global.key_dic["Black pawn"]:
			Selecting_piece_color=Black
			Selecting_piece_type=Pawn
		elif event.as_text_keycode()==Global.key_dic["Black rook"]:
			Selecting_piece_color=Black
			Selecting_piece_type=Rook
		elif event.as_text_keycode()==Global.key_dic["Black knight"]:
			Selecting_piece_color=Black
			Selecting_piece_type=Knight
		elif event.as_text_keycode()==Global.key_dic["Black bishop"]:
			Selecting_piece_color=Black
			Selecting_piece_type=Bishop
		elif event.as_text_keycode()==Global.key_dic["Black queen"]:
			Selecting_piece_color=Black
			Selecting_piece_type=Queen
		elif event.as_text_keycode()==Global.key_dic["Black king"]:
			Selecting_piece_color=Black
			Selecting_piece_type=King
		var piece_found:PIECE=find_next_piece_in_list(Selecting_piece_color,Selecting_piece_type)
		if is_piece_valid(piece_found):
			Selection_process(piece_found)


func Play_music() -> void:
	
	
	
	$Music_Player.stop()
	$Music_Player.stream=AudioStreamOggVorbis.load_from_file(Global.music_directory+"/music/"+Global.music_list[Music_counter]+".ogg")
	
	
	$Music_Player.play()
	Global.time=0


func _on_music_player_finished() -> void:
	next_music()


func next_music() -> void:
	Music_counter+=1
	Rhyme_list.clear()
	
	if Music_counter>=len(Global.music_list):
		
		end_game()
		return
	
	var new_rhythm_file=FileAccess.open(Global.music_directory+"/rhythm/"+Global.music_list[Music_counter]+".txt",FileAccess.READ)
	for i in new_rhythm_file.get_as_text().split(","):
		Rhyme_list.append(float(i))
	
	new_rhythm_file.close()
	Play_music()


func Rhyme_handling() -> void:
	

	
	var Board_glow_colors:Array[float]=[-1.0]
	
	Global.On_Rhyme=false
	for Rhyme in Rhyme_list:
		if Global.time >= Rhyme-Great_range and Global.time <= Rhyme+Great_range:
			if abs((1/Great_range)*(Global.time-Rhyme))<=1:
				Board_glow_colors.append(Board_glow_min+((+Board_glow_max-Board_glow_min)/2)*(cos((PI/Great_range)*(Global.time-Rhyme))+1))
			Global.On_Rhyme=true
	
	Board_glow_color=clamp(Board_glow_colors.max(),Board_glow_min,Board_glow_max)
	for i in Board_Grid.get_children():
		i.get_child(1).modulate.b=Board_glow_color
		i.get_child(1).modulate.g=Board_glow_color


func remove_all_piece() -> void:
	for Square in Board_Grid.get_children():
		if is_square_blocked(Square.get_child(0)):
			Square.get_child(0).get_child(4).queue_free()


func reset_all_value() -> void:
	Rhyme_list=[]
	piece_move_count=1
	#Rhyme_counter=0
	Board_glow_color=Board_glow_min
	Used_selected_piece_list=[]
	Global.time=0
	Global.White_Piece_list.clear()
	Global.Black_Piece_list.clear()
	
	Up_list=[false,false]
	Left_list=[false,false]
	Down_list=[false,false]
	Right_list=[false,false]


func reset_game() -> void:
	reset_all_value()
	remove_all_piece()
	Place_Piece()
	Play_music()


func _on_button_pressed() -> void:
	pass
	print(game_board.bitboard_to_fen())
	#for Square in Board_Grid.get_children():
		#Square.color_dot.visible=false
	#print("pressed")
#
	#for i in game_board.int_squares_to_bit_square_lists(game_board.Black_attack_mask[0]):
		#show_color_square(bit_square_to_square(i),1,0,0,1)
	#for i in game_board.Black_checking_masks:
		#for square in game_board.int_squares_to_bit_square_lists(i):
			#show_color_square(bit_square_to_square(square),1,0.5,0,1)
	#for i in game_board.Black_pining_masks:
		#for square in game_board.int_squares_to_bit_square_lists(i):
			#show_color_square(bit_square_to_square(square),1,1,0,1)



func end_game(winner=null) -> void:
	print(("White won" if winner else "Black won"))
	Global.music_list.clear()
	get_tree().change_scene_to_file("res://scenes/main_ui.tscn")




