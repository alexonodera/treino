extends Control

class_name BarraEnergia

@onready var hp:ProgressBar = get_node("Energia")
@onready var vidas: RichTextLabel = get_node("ContadorVidas")

var vida_atual:int = 0;
var vida_atualizada:int = 0;



func _ready():
	pass
	
func _physics_process(delta):
	
	var hp_atual: int = round(float(PlayerData.player.hp)/float(PlayerData.player.hp_inicial)*100.0)
	hp.value = hp_atual

		
	if PlayerData.player.vidas < 0:
		vidas.text = "x 0"
	else:		
		vidas.text = "x"+ str(PlayerData.player.vidas)
	
	

