extends Node2D

@onready var tamanho_inicial = $hp_interno.size
@onready var nome:Label = get_node("nome")

var escala = 1 : set = definir_escala


func _ready() -> void:
	
	pass 


func _physics_process(_delta: float) -> void:

	if get_parent().transform.x.x > 0:
		scale = Vector2(1,1)
	else:
		scale = Vector2(-1,1)
#	if escala <= 0:
#		visible = false
#	else:
#		visible = true
	
		
		
func definir_escala(valor):
	$hp_interno.size.x = tamanho_inicial.x * valor
