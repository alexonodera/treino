extends StaticBody2D
class_name Comida

@onready var player_ref: CharacterBody2D = null
@onready var anin: AnimationPlayer = get_node("anin")
@onready var area:Area2D = get_node("area_comida")
@onready var EFEITO7: PackedScene =  preload ("res://Effects/hit7.tscn")


@export var vitalidade: int = 200




func _process(_delta):
	z_index = abs(position.y)
	if player_ref != null and Input.is_action_just_pressed("ataque"):
		if PlayerData.player_1.pos_base.y > position.y - 20 and PlayerData.player_1.pos_base.y < position.y + 20:
			PlayerData.player_1.status = "pegar_item"
			PlayerData.player_1.hp_2(-vitalidade)
			var posicao_e: Vector2 = area.get_node("shape").global_position
			area.get_node("shape").disabled = true
			var tamanho:Vector2 =  Vector2(1,1)
			efeito_especial(posicao_e, EFEITO7, tamanho)
			anin.play("sumir")
			await anin.animation_finished

			queue_free()
	elif player_ref != null and Input.is_action_just_pressed("ataque_p2"):
		if PlayerData.player_2.pos_base.y > position.y - 20 and PlayerData.player_2.pos_base.y < position.y + 20:
			PlayerData.player_2.status = "pegar_item"
			PlayerData.player_2.hp_2(-vitalidade)
			var posicao_e: Vector2 = area.get_node("shape").global_position
			area.get_node("shape").disabled = true
			var tamanho:Vector2 =  Vector2(1,1)
			efeito_especial(posicao_e, EFEITO7, tamanho)
			anin.play("sumir")
			await anin.animation_finished

			queue_free()
	
func efeito_especial(posicao:Vector2, efeito_obj:PackedScene,tamanho:Vector2):
	var efeito = efeito_obj.instantiate()
	efeito.scale = tamanho
	add_child(efeito)
	efeito.global_position = posicao

func on_area_comida_area_entered(area_s):
	if area_s.name == "area_sobre":
		player_ref = area_s.get_parent()


func on_area_comida_area_exited(area_s):
	if area_s.name == "area_sobre":
		player_ref = null
