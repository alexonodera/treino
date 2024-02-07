extends Node2D
class_name FaseTemplate

@onready var PAUSE: PackedScene =  preload ("res://inteface/pause.tscn")
@onready var anin: AnimationPlayer = get_node("AnimationPlayer")
@onready var label_fase: Label = get_node("CanvasModulate/Hud/texto_fase")
@onready var Players:Node2D = get_node("Players")
@onready var Inimigos:Node2D = get_node("Inimigos")
@onready var Grupo_boss:Node2D = get_node("Boss")
@onready var camera: Camera2D = get_node("camera")
var BOSS: PackedScene =  preload ("res://personagens/boss1.tscn")
@onready var gatilho_boss: Area2D = get_node("Boss/gatilho_boss")



var pontuacao:int = 0
@export var nome_fase:String = "fase_1"
@export var fases_desbloqueadas: Array = ["fase_2"]
var fase_ativa:bool = true
var boss_ativo:bool = false

func _ready():
	PlayerData.camera = camera
	Engine.max_fps = 60
	iniciar_fase()

func iniciar_fase():
	tocar_som("musica_fase")
	if PlayerData.multijogador:
				
		PlayerData.select_player(PlayerData.char_p1, 1)
		PlayerData.select_player(PlayerData.char_p2, 2)
		Players.add_child(PlayerData.player_1)
		Players.add_child(PlayerData.player_2)
		PlayerData.player_1.global_position=Vector2(80.0,495.0)
		PlayerData.player_1.hp_2(150)
		PlayerData.player_2.global_position=Vector2(80.0,550.0)
		PlayerData.player_2.hp_2(150)
		camera.add_target(PlayerData.player_1)
		camera.add_target(PlayerData.player_2)
	else:
	
		PlayerData.select_player(PlayerData.char_p1, 1)
		Players.add_child(PlayerData.player_1)
		PlayerData.player_1.global_position=Vector2(80.0,495.0)
		PlayerData.player_1.hp_2(150)
		camera.add_target(PlayerData.player_1)

	label_fase.text = nome_fase+" Start"
	anin.play("inicio_fase")

	
func concluir_fase() -> void:
	parar_som("musica_boss")
	tocar_som("fase_concluida")
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
#Adicionar validação para finalizar a fase no novo modo com multiplayer
	#PlayerData.player.status = "fim_estagio"
	for p in get_tree().get_nodes_in_group("player"):
		p.status = "fim_estagio"
 
	for i in get_tree().get_nodes_in_group("inimigo"):
		i.acertou(6, 9999)
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


func on_gatilho_boss_area_entered(area):
	if area.name == "area_corpo_player":
		if !boss_ativo:		
			boss_ativo = true
			call_deferred("_chamar_boss")

			

		
func _chamar_boss():
	parar_som("musica_fase")
	tocar_som("musica_boss")
	var boss: CharacterBody2D = BOSS.instantiate()
	Grupo_boss.add_child(boss)
	boss.global_position = Vector2(2455,474)	
	gatilho_boss.queue_free()	
		
func parar_som(som:String):
	$"sons".get_node(som).stop()

func tocar_som(som:String):
	$"sons".get_node(som).play()
