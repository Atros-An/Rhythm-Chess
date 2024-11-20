extends Node

var On_Rhyme:bool = true


var music_directory:String


var music_list = []

var debug:bool=true

var White_Piece_list:Array[PIECE]= []
var Black_Piece_list:Array[PIECE]= []

var time:float=0.0

var key_dic:={
	
	"White confirm":"Z",
	"White up":"W",
	"White left":"A",
	"White down":"S",
	"White right":"D",
	"White pawn":"1",
	"White rook":"2",
	"White knight":"3",
	"White bishop":"4",
	"White queen":"5",
	"White king":"6",
	"White deselect":"X",
	
	
	
	"Black confirm":"Enter",
	"Black up":"Up",
	"Black left":"Left",
	"Black down":"Down",
	"Black right":"Right",
	"Black pawn":"Kp 1",
	"Black rook":"Kp 2",
	"Black knight":"Kp 3",
	"Black bishop":"Kp 4",
	"Black queen":"Kp 5",
	"Black king":"Kp 6",
	"Black deselect":"Shift",


	}
