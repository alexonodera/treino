extends CharacterBody2D
class_name Caixa_template

@onready var limite: CollisionShape2D = get_node("limite3")
@onready var colisao_base: StaticBody2D = get_node("colisao_base")

var pos_base: Vector2 = Vector2.ZERO

func _process(_delta):
	z_index = position.y
	pos_base = colisao_base.global_position

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
	
	if area.name == "area_corpo_player":	

		var corpo:CharacterBody2D = area.get_parent()	

		if corpo.pos_base.y > position.y - 20 and corpo.pos_base.y < position.y + 20:
			pass
#			print(corpo.velocidade)
#			corpo.velocidade.x = 0


