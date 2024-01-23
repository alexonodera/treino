extends Control

@onready var botao_start: Button = get_node("Start")
@onready var botao_quit: Button = get_node("Quit")
@onready var confirmacao =  preload("res://inteface/confirmacao.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():

	var clicar_item = Callable(self, "iniciar_jogo")
	botao_start.connect("button_down",clicar_item.bind())
	

	var clicar_sair = Callable(self, "sair_jogo")
	botao_quit.connect("button_down",clicar_sair.bind())
	

func iniciar_jogo() -> void:	
	if core.carregar_dados():
		var dados = core.procurar_itens("save")
		if dados.size() > 0:			
			TransicaoTela.cena = "res://inteface/control.tscn"
			TransicaoTela.aparecer()	
#			get_tree().change_scene_to_file("res://inteface/control.tscn")
		else:
			core.novo_item() 
#			get_tree().change_scene_to_file("res://cenas/teste.tscn")		
	else:
		core.novo_item() 
#		get_tree().change_scene_to_file("res://cenas/teste.tscn")

func sair_jogo() ->void:
	var janela_confirmacao:Control  = confirmacao.instantiate()
	janela_confirmacao.get_node("JanelaConfirmacao/Mensagem").text = "Do you really want to exit the game?"
	self.add_child(janela_confirmacao)
	janela_confirmacao.get_node("Anin").play("aparecer")
	var botao_ok: Button = janela_confirmacao.get_node("JanelaConfirmacao/Apagar_save")
	var clicar_item = Callable(self, "_confirmar_sair")
	botao_ok.connect("button_down",clicar_item.bind(janela_confirmacao))
	
	
func _confirmar_sair(janela_confirmacao):
	janela_confirmacao.get_node("Anin").play("desaparecer")
	await janela_confirmacao.get_node("Anin").animation_finished
	get_tree().quit()

	
