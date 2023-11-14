extends Node


signal updated
signal died

var score: = 0 : set = set_score
var deaths: = 0 : set = set_deaths
var vidas: = 2 : set = set_vidas
var position:Vector2 = Vector2.ZERO
var pos_base:Vector2 = Vector2.ZERO
var status:String = ""
var player_1: CharacterBody2D = null 
var player_2: CharacterBody2D = null 
var char_p1: int = 0
var char_p2: int = 0
var novo_jogo: bool = false
@onready var char_1: PackedScene =  preload("res://personagens/char_1.tscn")
@onready var char_2: PackedScene =  preload("res://personagens/char_2.tscn")
var personagens: Array = []



func _ready():
	personagens.push_back(char_1)
	personagens.push_back(char_2)


func reset():
	self.score = 0
	self.deaths = 0
	
	


func select_player(char_sel:int, player:int) -> void:
	if player == 1:
		player_1 =  personagens[char_sel].instantiate()
	else:
		player_2 = personagens[char_sel].instantiate()
	
	

func set_score(new_score: int) -> void:
	score = new_score
	emit_signal("updated")


func set_deaths(new_value: int) -> void:
	deaths = new_value
	emit_signal("died")
	
func set_vidas(vidas_restantes: int) -> void:
	vidas = vidas_restantes
	emit_signal("updated")
	if vidas < 0:
#		vidas = 0
		emit_signal("died")
