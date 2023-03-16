extends Node2D



@onready var botao_voltar: Button = get_node("botao_voltar")

# Called when the node enters the scene tree for the first time.
func _ready():

	var clicar_item = Callable(self, "inicio_jogo")
	botao_voltar.connect("button_down",clicar_item.bind())



func inicio_jogo() -> void:
	get_tree().change_scene_to_file("res://inteface/control.tscn")
