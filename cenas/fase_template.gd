extends Node2D
class_name FaseTemplate

var pontuacao:int = 0
@export var nome_fase:String = "fase_1"
@export var fases_desbloqueadas: Array = ["fase_2"]


	
func concluir_fase() -> void:
	
	var fases_concluidas = core.procurar_sub_itens(core.save_selecionado.id, "fase_concluida")
	
	if fases_concluidas:				
		for fase_concluida in fases_concluidas:
			if fase_concluida.nome == nome_fase:
				if pontuacao > fase_concluida.pontuacao_maxima:					
					fase_concluida.pontuacao_maxima =pontuacao
					core.editar(fase_concluida)
					core.gravar_dados()					

			else:				
				criar_nova_fase_concluida(nome_fase)

	else:	
		criar_nova_fase_concluida(nome_fase)
	get_tree().change_scene_to_file("res://cenas/mapa.tscn")
	

func criar_nova_fase_concluida(nome:String) -> void:
	var nova_fase_concluida: Dictionary = {
		"id":core.gerar_id(),
		"nome":nome,
		"template": "fase_concluida",
		"fases_desbloqueadas": fases_desbloqueadas,
		"pontuacao_maxima":pontuacao	
	} 
	core.cadastrar(nova_fase_concluida)
	core.criar_rel(core.save_selecionado.id, nova_fase_concluida.id, "sub_item")
	core.gravar_dados()


	
	
