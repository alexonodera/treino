extends CharacterBody2D
class_name Caixa_template

@onready var limite: CollisionShape2D = get_node("limite3")

func _process(_delta):
	z_index = position.y

#func on_colisao_z_area_entered(area):
#	print("teste")
#	print(area.name)
#	if area.name == "area_corpo_player":	
#		print("aqui")
#		var corpo:CharacterBody2D = area.get_parent()	
#		if corpo.position.y > position.y - 20 and corpo.position.y < position.y + 20:
#			print(corpo.velocidade)
#			corpo.velocidade.x = 0
#
			


func _on_colisao_z_area_entered(area):
	print(area.name)
	if area.name == "area_corpo_player":	

		var corpo:CharacterBody2D = area.get_parent()	
		
		print(corpo.status)
		if corpo.pos_base.y > position.y - 20 and corpo.pos_base.y < position.y + 20:
			pass
#			print(corpo.velocidade)
#			corpo.velocidade.x = 0


