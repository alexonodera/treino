extends Area2D

var EFEITO3: PackedScene =  preload ("res://Effects/hit3.tscn")
@onready var anin: AnimationPlayer =$AnimationPlayer
@export var vel:int = 9000

func _physics_process(delta):
	position += transform.x * vel * delta



func on_area_entered(area):

	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()				
		var posicao:Vector2 = inimigo.get_node("corpo/cabeca").global_position
		PlayerData.player_1.tremer_tela(50)
		var tamanho:Vector2 =  Vector2(16,16)
		PlayerData.player_1.efeito_especial(posicao, EFEITO3, tamanho)
		PlayerData.score += 35
		PlayerData.player_1.tocar_som("golpe_especial")
		
		var comportamento:int = int(randf_range(1,3))
		
		inimigo.emit_signal("acertar", comportamento, 100)
		anin.play("acertou")
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()		
		var posicao: Vector2 = objeto.global_position
		var tamanho:Vector2 =  Vector2(16,16)
		PlayerData.player_1.efeito_especial(posicao, EFEITO3, tamanho)
		PlayerData.score += 35
		PlayerData.player_1.tocar_som("golpe_especial")
		
		objeto.emit_signal("acertar", transform.x, 220)
		PlayerData.score += 20

		


func on_animation_player_animation_finished(anim_name):
	if anim_name == "acertou":
		queue_free()
