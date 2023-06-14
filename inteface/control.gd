extends MenuManeiro
class_name LoadSave

@onready var save =  preload("res://inteface/item.tscn")
@onready var confirmacao =  preload("res://inteface/confirmacao.tscn")
@onready var lista_itens: GridContainer = get_node('Control/ListaItens')
@onready var botao_back: Button = get_node("Back")
@onready var botao_carregar: Button = get_node("Menu/Carregar")
@onready var botao_apagar: Button = get_node("Menu/Apagar")
@onready var botao_novo: Button = get_node("Menu/Novo")


var iten_selecionado:  Dictionary = {}

func _ready():
	criar_acoes_botoes()
#	for botao in get_tree().get_nodes_in_group("botao"):
#		var botao_apertado = Callable(self, "botao_pressionado")
#		botao.connect("button_down",botao_apertado.bind(botao.name))
#
#		var evento_mouse = Callable(self, "interacao_mouse")
#		botao.connect("mouse_exited", evento_mouse.bind(botao,"saiu"))
#		botao.connect("mouse_entered", evento_mouse.bind(botao,"entrou"))
	
	carregar_itens()
	
	var clicar_back = Callable(self, "voltar_titulo")
	botao_back.connect("button_down",clicar_back.bind())


func botao_pressionado(botao:String) -> void:
	match botao:
		"Novo":
			novo_item()		
		"Carregar":
			carregar_jogo()
		"Apagar":
			apagar_jogo()

	
#func interacao_mouse(botao:Button, tipo:String) -> void:
#	if botao.disabled:
#		return
#
#	match tipo:
#		"saiu":
#			botao.modulate.a = 1.0
#		"entrou":
#			botao.modulate.a = 0.5
			
func novo_item() -> void:
	var saves = core.procurar_itens("save")
	if saves.size() < 6 :
		var data = Time.get_datetime_string_from_system (false,true) 
#		var horario = Time.get_time_string_from_system(false) 
		var item_n: Dictionary = {}
		item_n.id = core.gerar_id()
		item_n.nome = data
		item_n.template = "save"
		item_n.attrs = {
			"conclusao": "0%",
			"level": "1",
			"estagios_concluidos": [],
			"personagem": {}
		}
#		core.database.itens.push_back(item_n)
		
		core.cadastrar(item_n)
		core.gravar_dados()
		core.save_selecionado = item_n
		get_tree().change_scene_to_file("res://cenas/fase_template.tscn")	
		

func carregar_itens()-> void:
	limpar_lista()
	botao_apagar.modulate.a = 0.2
	botao_apagar.disabled = true
	botao_carregar.modulate.a = 0.2
	botao_carregar.disabled = true
		
	var itens: Array = core.procurar_itens("save")
	if itens.size() == 6:	
		botao_novo.modulate.a = 0.2
		botao_novo.disabled = true
	else:
		botao_novo.modulate.a = 1
		botao_novo.disabled = false

	if itens:			
		for x in itens:
			var iten_tmp:Control  = save.instantiate()
			iten_tmp.get_node("Clique/row/nome").text = x.nome
			iten_tmp.get_node("Clique/row/porcentagem").text = x.attrs.conclusao
			iten_tmp.get_node("Clique/row/level").text = x.attrs.level
			var fundo:ColorRect = iten_tmp.get_node("Clique/fundo")
			#Maneira de alterar outros elementos do item instanciado com funções do script
			var evento_mouse = Callable(self, "interacao_mouse2")
			fundo.connect("mouse_entered", evento_mouse.bind(fundo,"saiu"))
			fundo.connect("mouse_exited", evento_mouse.bind(fundo,"entrou"))
			
			var botao_1: Button = iten_tmp.get_node("Clique")
			var clicar_item = Callable(self, "selecionar_save")
#			botao_1.connect("button_down",clicar_item.bind(x))
			
			lista_itens.add_child(iten_tmp)
			
			botao_1.connect("button_down",clicar_item.bind(x,iten_tmp))
			

func limpar_lista()-> void:
	for save_n in get_tree().get_nodes_in_group("item_save"):
		save_n.queue_free()
		
func interacao_mouse2(iten_tmp:Control, tipo: String) -> void:
	match tipo:
		"saiu":
			iten_tmp.modulate.a = 1.0
		"entrou":
			iten_tmp.modulate.a = 0.5

func selecionar_save(item:Dictionary, item_tmp: Control) ->void:	
	iten_selecionado = item
	for i in get_tree().get_nodes_in_group("item_save"):
		i.modulate.b = 1
	item_tmp.modulate.b =255
	botao_apagar.modulate.a = 1
	botao_apagar.disabled = false
	botao_carregar.modulate.a = 1
	botao_carregar.disabled = false

	

func voltar_titulo() -> void:
	get_tree().change_scene_to_file("res://cenas/titulo.tscn")
	
func carregar_jogo() -> void:
	core.save_selecionado  = iten_selecionado
	get_tree().change_scene_to_file("res://cenas/mapa.tscn")
	
func apagar_jogo() ->void:
	for i in get_tree().get_nodes_in_group("janela"):
		i.queue_free()
	var janela_confirmacao:Control  = confirmacao.instantiate()
	janela_confirmacao.get_node("JanelaConfirmacao/Mensagem").text = "Are You Sure to Delete "+ iten_selecionado.nome+"?"
	self.add_child(janela_confirmacao)
	janela_confirmacao.get_node("Anin").play("aparecer")
	var botao_ok: Button = janela_confirmacao.get_node("JanelaConfirmacao/Apagar_save")
	var clicar_item = Callable(self, "confirmar_apagar_save")
	botao_ok.connect("button_down",clicar_item.bind(janela_confirmacao))

func confirmar_apagar_save(janela_confirmacao) -> void:
	core.deletar(iten_selecionado.id)
	core.gravar_dados()
	carregar_itens()
	janela_confirmacao.get_node("Anin").play("desaparecer")

	
	
	
	
	
