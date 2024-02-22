extends Control
class_name GameOver

@onready var btn_continuar: Button = get_node("Janela/VBoxContainer/continuar")
@onready var btn_reiniciar: Button = get_node("Janela/VBoxContainer/reiniciar")
@onready var btn_sair: Button = get_node("Janela/VBoxContainer/sair")
@onready var anin: AnimationPlayer = get_node("anin")
@onready var confirmacao =  preload("res://inteface/confirmacao.tscn")

var pausado:bool = false



func _ready():
	var clique_continar = Callable(self, "despausar")
	btn_continuar.connect("button_down",clique_continar.bind())	
	
	var clique_reiniciar = Callable(self, "reiniciar_jogo")
	btn_reiniciar.connect("button_down", clique_reiniciar.bind())
	
	var clique_sair = Callable(self, "sair_jogo")
	btn_sair.connect("button_down", clique_sair.bind())
	
	
	#pausar()
	
	
	
func _process(_delta):
	pass
	
	#if Input.is_action_just_pressed("ui_accept"):
		#if(pausado):
			#despausar()			
			#
		#else:
			#pausar()
			
func reiniciar_jogo():
	var janela_confirm_reiniciar: Control  = confirmacao.instantiate()
	janela_confirm_reiniciar.get_node("JanelaConfirmacao/Mensagem").text = "Would you like to restart the level?"
	self.add_child(janela_confirm_reiniciar)
	janela_confirm_reiniciar.get_node("Anin").play("aparecer")
	
	var botao_confirm_reiniciar: Button = janela_confirm_reiniciar.get_node("JanelaConfirmacao/Apagar_save")
	var clicar_item_reiniciar = Callable(self, "recarregar_fase")
	botao_confirm_reiniciar.connect("button_down",clicar_item_reiniciar.bind())
	
func recarregar_fase():
	pausado = false
	get_tree().paused = false	
	
	TransicaoTela.aparecer()

	
	
func sair_jogo():
	var janela_confirm_sair: Control  = confirmacao.instantiate()
	janela_confirm_sair.get_node("JanelaConfirmacao/Mensagem").text = "Are you sure you want to quit the game?"
	self.add_child(janela_confirm_sair)
	janela_confirm_sair.get_node("Anin").play("aparecer")
	
	var botao_confirm_sair: Button = janela_confirm_sair.get_node("JanelaConfirmacao/Apagar_save")
	var clicar_item_sair = Callable(self, "fechar_jogo")
	botao_confirm_sair.connect("button_down",clicar_item_sair.bind())

func despausar():
	anin.play("desaparecer")
	await  anin.animation_finished
	pausado = false
	get_tree().paused = false
	
	
	

func pausar():			
	anin.play("aparecer")
	await  anin.animation_finished
	pausado = true
	get_tree().paused = true

func fechar_jogo():
	print("saiu do jogo")
	get_tree().paused = false
	TransicaoTela.cena = "res://cenas/titulo.tscn"
	TransicaoTela.aparecer()	
	

	



	
	
