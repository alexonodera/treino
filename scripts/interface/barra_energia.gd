extends Control

class_name BarraEnergia

@onready var hp:ProgressBar = get_node("hud_p1/Energia")
@onready var vidas: RichTextLabel = get_node("hud_p1/ContadorVidas")
@onready var nome_char:Label = get_node("hud_p1/nome_char")
@onready var hp2:ProgressBar = get_node("hud_p2/Energia2")
@onready var vidas2: RichTextLabel = get_node("hud_p2/ContadorVidas2")
@onready var nome_char2:Label = get_node("hud_p2/nome_char2")
@onready var hud_p2:Control = get_node("hud_p2")

var vida_atual:int = 0;
var vida_atualizada:int = 0;



func _ready():
	
	pass
	
func _physics_process(_delta):
	if PlayerData.multijogador:
		hud_p2.visible = true
		nome_char.text = PlayerData.player_1.nome
		var hp_atual: int = round(float(PlayerData.player_1.hp)/float(PlayerData.player_1.hp_inicial)*100.0)
		hp.value = hp_atual
		
		if PlayerData.player_1.vidas < 0:
			vidas.text = "x 0"
		else:		
			vidas.text = "x"+ str(PlayerData.player_1.vidas)
		
		nome_char2.text = PlayerData.player_2.nome
		var hp_atual_2: int = round(float(PlayerData.player_2.hp)/float(PlayerData.player_2.hp_inicial)*100.0)
		hp2.value = hp_atual_2
		
		if PlayerData.player_2.vidas < 0:
			vidas2.text = "x 0"
		else:		
			vidas2.text = "x"+ str(PlayerData.player_2.vidas)
	else:
		hud_p2.visible = false
		nome_char.text = PlayerData.player_1.nome
		var hp_atual: int = round(float(PlayerData.player_1.hp)/float(PlayerData.player_1.hp_inicial)*100.0)
		hp.value = hp_atual
		
		if PlayerData.player_1.vidas < 0:
			vidas.text = "x 0"
		else:		
			vidas.text = "x"+ str(PlayerData.player_1.vidas)
		
	
func atualizar_dados_player(_player:CharacterBody2D, _tipo:int):
	pass
	
