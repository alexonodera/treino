extends Control

@onready var btn_reiniciar: Button = get_node("Restart")
@onready var btn_sair: Button = get_node("Menu")
@onready var btn_mapa: Button = get_node("Mapa")


func _ready():
	get_tree().paused = false
	var clique_reiniciar = Callable(self, "reiniciar_fase")
	btn_reiniciar.connect("button_down", clique_reiniciar.bind())
	
	var clique_sair = Callable(self, "sair_jogo")
	btn_sair.connect("button_down", clique_sair.bind())
	
	var clique_mapa = Callable(self, "mapa_jogo")
	btn_mapa.connect("button_down", clique_mapa.bind())
	
	
func reiniciar_fase():
	#print(PlayerData.fase.name)
	print(PlayerData.path_fase_atual)
	if PlayerData.path_fase_atual:
		var fase_atual = PlayerData.path_fase_atual
		TransicaoTela.cena = fase_atual
		TransicaoTela.aparecer()	
	else:
		TransicaoTela.cena = "res://cenas/titulo.tscn"
		TransicaoTela.aparecer()		


func sair_jogo():
	
	TransicaoTela.cena = "res://cenas/titulo.tscn"
	TransicaoTela.aparecer()	
	
func mapa_jogo():
	TransicaoTela.cena = "res://cenas/mapa.tscn"
	TransicaoTela.aparecer()	
	pass
