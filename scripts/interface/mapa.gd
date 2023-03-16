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
			pass	
		"Fase2":
			pass
		"Fase3":
			pass


func voltar_load() -> void:
	get_tree().change_scene_to_file("res://inteface/control.tscn")
	
func verificar_fases_desbloqueadas() -> void:
	pass
	
