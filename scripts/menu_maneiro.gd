extends Node
class_name MenuManeiro

func _ready() -> void:
	criar_acoes_botoes()
	
	

func criar_acoes_botoes() -> void:

	for botao in get_tree().get_nodes_in_group("botao"):
		var botao_apertado = Callable(self, "botao_pressionado")
		botao.connect("button_down",botao_apertado.bind(botao.name))
		
		var evento_mouse = Callable(self, "interacao_mouse")
		botao.connect("mouse_exited", evento_mouse.bind(botao,"saiu"))
		botao.connect("mouse_entered", evento_mouse.bind(botao,"entrou"))

func interacao_mouse(botao:Button, tipo:String) -> void:
	if botao.disabled:
		return
		
	match tipo:
		"saiu":
			
			botao.modulate.a = 1.0
		"entrou":
			
			botao.modulate.a = 0.5
			
			
func botao_pressionado(botao:String) -> void:

	match botao:
		"Novo":
			pass	
		"Carregar":
			pass
		"Apagar":
			pass
