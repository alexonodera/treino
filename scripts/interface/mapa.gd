extends MenuManeiro

@onready var botao_back: Button = get_node("Control/Back")
# Called when the node enters the scene tree for the first time.
func _ready():
	criar_acoes_botoes()
	
	var clicar_back = Callable(self, "voltar_load")
	botao_back.connect("button_down",clicar_back.bind())
	
	verificar_fases_desbloqueadas()


			
func botao_pressionado(botao:String) -> void:
	match botao:
		"Fase":
			TransicaoTela.cena = "res://cenas/fase_template.tscn"
			TransicaoTela.aparecer()	
#			get_tree().change_scene_to_file("res://cenas/teste.tscn")	
		"Fase2":
			TransicaoTela.cena = "res://cenas/fase_template.tscn"
			TransicaoTela.aparecer()	
#			get_tree().change_scene_to_file("res://cenas/fase_template.tscn")	
		"Fase3":
			pass


func voltar_load() -> void:
	TransicaoTela.cena = "res://inteface/control.tscn"
	TransicaoTela.aparecer()
#	get_tree().change_scene_to_file("res://inteface/control.tscn")
	
func verificar_fases_desbloqueadas() -> void:
	var fases_concluidas: Array = core.procurar_sub_itens(core.save_selecionado.id,"fase_concluida")
	
	for fase in get_tree().get_nodes_in_group("fase"):
	
		if fase.get_meta("id_fase") != "fase_1":
			fase.disabled = true
			fase.modulate.a = 0.2			
		for fase_concluida in fases_concluidas:
			if fase_concluida.fases_desbloqueadas.has(fase.get_meta("id_fase")):
				fase.disabled = false
				fase.modulate.a = 1.0
			




