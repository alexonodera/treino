extends Node2D
class_name FaseTemplate

@onready var PAUSE: PackedScene =  preload ("res://inteface/pause.tscn")
@onready var anin: AnimationPlayer = get_node("AnimationPlayer")
@onready var label_fase: Label = get_node("CanvasModulate/Hud/texto_fase")


var pontuacao:int = 0
@export var nome_fase:String = "fase_1"
@export var fases_desbloqueadas: Array = ["fase_2"]
var fase_ativa:bool = true

func _ready():
	Engine.max_fps = 60
	iniciar_fase()

func iniciar_fase():
	label_fase.text = nome_fase+" Start"
	anin.play("inicio_fase")
	
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
	label_fase.text = "Stage Clear"
	fase_ativa = false
	PlayerData.player.status = "fim_estagio"

	anin.play("fim_fase")
	
#	get_tree().change_scene_to_file("res://cenas/mapa.tscn")
	

func criar_nova_fase_concluida(nome:String) -> void:
	var nova_fase_concluida: Dictionary = {
		"id":core.gerar_id(),
		"nome":nome,
		"template": "fased_concluida",
		"fases_desbloqueadas": fases_desbloqueadas,
		"pontuacao_maxima":pontuacao	
	} 
	core.cadastrar(nova_fase_concluida)
	core.criar_rel(core.save_selecionado.id, nova_fase_concluida.id, "sub_item")
	core.gravar_dados()


	
	


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "fim_fase":
		TransicaoTela.cena = "res://cenas/mapa.tscn"
		TransicaoTela.aparecer()	
