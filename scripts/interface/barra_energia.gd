extends Control

class_name BarraEnergia

@onready var hp:ProgressBar = get_node("Energia")
@onready var vidas: RichTextLabel = get_node("ContadorVidas")
@onready var nome_char:Label = get_node("nome_char")
@onready var hp2:ProgressBar = get_node("Energia2")
@onready var vidas2: RichTextLabel = get_node("ContadorVidas2")
@onready var nome_char2:Label = get_node("nome_char2")

var vida_atual:int = 0;
var vida_atualizada:int = 0;



func _ready():
	
	pass
	
func _physics_process(_delta):
	
	nome_char.text = PlayerData.player.nome
	var hp_atual: int = round(float(PlayerData.player.hp)/float(PlayerData.player.hp_inicial)*100.0)
	hp.value = hp_atual

		
	if PlayerData.player.vidas < 0:
		vidas.text = "x 0"
	else:		
		vidas.text = "x"+ str(PlayerData.player.vidas)
	
	
func atualizar_dados_player(player:CharacterBody2D, tipo:int):
	pass
	
