extends Object
class_name Game_Assets



enum {Pawn,Rook,Knight,Bishop,Queen,King}

enum PIECE_TYPE_INDEX {
	White_Pawns_index,
	White_Rooks_index,
	White_Knights_index,
	White_Bishops_index,
	White_Queens_index,
	White_King_index,
	
	Black_Pawns_index,
	Black_Rooks_index,
	Black_Knights_index,
	Black_Bishops_index,
	Black_Queens_index,
	Black_King_index,
	
	null_piece_index=-1}

enum COORDINATE { 
	A8,B8,C8,D8,E8,F8,G8,H8,
	A7,B7,C7,D7,E7,F7,G7,H7,
	A6,B6,C6,D6,E6,F6,G6,H6,
	A5,B5,C5,D5,E5,F5,G5,H5,
	A4,B4,C4,D4,E4,F4,G4,H4,
	A3,B3,C3,D3,E3,F3,G3,H3,
	A2,B2,C2,D2,E2,F2,G2,H2,
	A1,B1,C1,D1,E1,F1,G1,H1,
	null_coordinate=-1}

enum BIT_SQUARE{
	a8=1<<0 ,b8=1<<1 ,c8=1<<2 ,d8=1<<3 ,e8=1<<4 ,f8=1<<5 ,g8=1<<6 ,h8=1<<7 ,
	a7=1<<8 ,b7=1<<9 ,c7=1<<10,d7=1<<11,e7=1<<12,f7=1<<13,g7=1<<14,h7=1<<15,
	a6=1<<16,b6=1<<17,c6=1<<18,d6=1<<19,e6=1<<20,f6=1<<21,g6=1<<22,h6=1<<23,
	a5=1<<24,b5=1<<25,c5=1<<26,d5=1<<27,e5=1<<28,f5=1<<29,g5=1<<30,h5=1<<31,
	a4=1<<32,b4=1<<33,c4=1<<34,d4=1<<35,e4=1<<36,f4=1<<37,g4=1<<38,h4=1<<39,
	a3=1<<40,b3=1<<41,c3=1<<42,d3=1<<43,e3=1<<44,f3=1<<45,g3=1<<46,h3=1<<47,
	a2=1<<48,b2=1<<49,c2=1<<50,d2=1<<51,e2=1<<52,f2=1<<53,g2=1<<54,h2=1<<55,
	a1=1<<56,b1=1<<57,c1=1<<58,d1=1<<59,e1=1<<60,f1=1<<61,g1=1<<62,h1=1<<63,
	null_square=0
}

const coordinate_list:Array[String]=[
	"A8","B8","C8","D8","E8","F8","G8","H8",
	"A7","B7","C7","D7","E7","F7","G7","H7",
	"A6","B6","C6","D6","E6","F6","G6","H6",
	"A5","B5","C5","D5","E5","F5","G5","H5",
	"A4","B4","C4","D4","E4","F4","G4","H4",
	"A3","B3","C3","D3","E3","F3","G3","H3",
	"A2","B2","C2","D2","E2","F2","G2","H2",
	"A1","B1","C1","D1","E1","F1","G1","H1"]


func find_color_from_type_index(type_index:int):
	if type_index==-1:
		return null
	return type_index<6

func find_type_from_type_index(type_index:int) -> int:
	if type_index==-1:
		return -1
	return type_index%6

func get_type_index_uisng_type_and_color(type:int,color:bool) -> int:
	if color:
		return type
	return type+6