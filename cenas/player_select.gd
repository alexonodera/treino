extends Node2D


@onready var cursor_p1: CharacterBody2D = get_node("Cursor_p1")
@onready var cursor_p2: CharacterBody2D = get_node("Cursor_p2")
@onready var char_1: PackedScene =  preload("res://personagens/Player_template.tscn")

var pos_cursor_p1: int = 0
var pos_cursor_p2: int = 0
var p1_pronto: bool = false
var p2_pronto: bool = false
var multijogador: bool = false
var itens =[]



func _ready():

	for item in get_tree().get_nodes_in_group("char"):
		itens.push_back(item)
	
	pos_cursor_p2 = itens.size()-1
		
	
		
	
func _process(_delta):
	if !p2_pronto:
		if Input.is_action_just_pressed("start_p2"):			
			multijogador = true			
		
		if Input.is_action_just_pressed("direita_p2"):
			if pos_cursor_p2 < itens.size()-1:
				pos_cursor_p2 += 1
				
		if Input.is_action_just_pressed("esquerda_p2"):

			if pos_cursor_p2 > 0:
				pos_cursor_p2 -= 1	
		if Input.is_action_just_pressed("ataque_p2"):	
	
			PlayerData.char_p2 = pos_cursor_p2
			p2_pronto = true
			iniciar_jogo()
			
		if multijogador:
			cursor_p2.global_position = itens[pos_cursor_p2].global_position
	if !p1_pronto:
		cursor_p1.global_position = itens[pos_cursor_p1].global_position
		
		if Input.is_action_just_pressed("direita"):
			if pos_cursor_p1 < itens.size()-1:
				pos_cursor_p1 += 1
				
		if Input.is_action_just_pressed("esquerda"):
			if pos_cursor_p1 > 0:
				pos_cursor_p1 -= 1
			
		if Input.is_action_just_pressed("ataque"):	
			PlayerData.char_p1 = pos_cursor_p1
			print("ataque_p1")
			p1_pronto = true
			iniciar_jogo()
	




func iniciar_jogo():
	if multijogador:
		if p1_pronto and p2_pronto:		
			if PlayerData.novo_jogo:
				print("teste0")
				TransicaoTela.cena = "res://cenas/fase_template.tscn"
			else:
				print("teste1")
				TransicaoTela.cena = "res://cenas/mapa.tscn"
				TransicaoTela.aparecer()
		else:
			print("tem que esperar")
	else:
		if p1_pronto and !multijogador:
			if PlayerData.novo_jogo:
				print("teste2")
				TransicaoTela.cena = "res://cenas/fase_template.tscn"
			else:
				print("teste3")
				TransicaoTela.cena = "res://cenas/mapa.tscn"
				
				TransicaoTela.aparecer()
