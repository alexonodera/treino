extends Node2D

@onready var tamanho_inicial = $hp_interno.size

var escala = 1 : set = definir_escala


func _ready() -> void:
	pass 


func _physics_process(delta: float) -> void:
	pass
#	if escala <= 0:
#		visible = false
#	else:
#		visible = true
	
		
		
func definir_escala(valor):
	$hp_interno.size.x = tamanho_inicial.x * valor
