extends Control

@onready var botao_start: Button = get_node("Start")

# Called when the node enters the scene tree for the first time.
func _ready():

	var clicar_item = Callable(self, "iniciar_jogo")
	botao_start.connect("button_down",clicar_item.bind())

func iniciar_jogo() -> void:	
	if core.carregar_dados():
		var dados = core.procurar_itens("save")
		if dados.size() > 0:			
		
			get_tree().change_scene_to_file("res://inteface/control.tscn")
		else:
			core.novo_item() 
#			get_tree().change_scene_to_file("res://cenas/teste.tscn")		
	else:
		core.novo_item() 
#		get_tree().change_scene_to_file("res://cenas/teste.tscn")


	
	
