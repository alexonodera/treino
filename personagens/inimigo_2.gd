extends CharacterBody2D

var EFEITO: PackedScene = preload("res://Effects/hit3.tscn")
var EFEITO2: PackedScene = preload("res://Effects/hit3.tscn")





@export var nome:String = ""
@export var max_velocidade:int = 250
@export var gravidade:int = 2000
@export var tempo_agarrado:int = 2
@export var forca:int = 2
@export var boss: bool = false

@onready var cabeca: Sprite2D = get_node("corpo/cabeca")
@onready var timer_comportamento: Timer = get_node("TimerComportamento")
@onready var barra_hp: Node2D = get_node("hp")
@onready var anin: AnimationPlayer = $AnimationPlayer
@onready var cena:Node2D = $"../../"
@onready var area_agarrao_inimigo:Area2D = get_node("area_agarrao_inimigo") 
@onready var limite = get_node("limite")
var pos_base:Vector2 = Vector2.ZERO
signal acertar(tipo:int, forca:int)
signal agarrar(tipo:int)


var batendo:bool = false
var apanhando:bool= false
var recuar:bool= false
var caindo:bool= false
var caido:bool= false
var agarrado:bool= false
var apanhando_agarrado:bool= false
var arremessado:bool= false
var status: String = "normal"
var tempo_recuar:float = 0


var max_tempo_agarrado:int = 2
var tempo_acao:float = 0
var tempo_espera:int = 2
var comportamento_movimento:int = 5
@export var hp:int = 1500
var hp_inicial:int = hp

var text_cabeca: CompressedTexture2D = null


var velocidade:Vector2 = Vector2.ZERO



func _ready() -> void:
	connect("acertar",Callable(self,"acertou"))

	
	var textura:Texture2D = load("res://assets/decoracao/tv.png")
	cabeca.texture = textura
	hp_inicial = hp	
	barra_hp.nome.text = nome
	


func _physics_process(delta: float) -> void:
#	if transform.x.x > 0:
#		barra_hp.scale = Vector2(1,1)
#	else:
#		barra_hp.scale = Vector2(-1,1)
		
	if hp <= 0 and status != "caindo" and status != "morto":
		status = "morrendo"


	z_index = int(position.y)	
		

	set_velocity(velocidade)
	move_and_slide()

	if  status != "caindo":
		pos_base = position
		
	
	
	if status == "normal":	
		limite.disabled = false
		agarrado = false
		apanhando_agarrado = false
		arremessado =false
		
		tempo_agarrado = 0
		$sombra_sprite.visible = true
		$area_corpo/shape.disabled = false
		$area_ataque/shape.disabled = false
		$area_agarrao_inimigo/shape.disabled = false		
		$ataque_medio/shape.disabled = true
		$ataque_fraco/shape.disabled = true
		$ataque_forte/shape.disabled = true
		$dano_arremesso/shape.disabled = true
		
		movimento()
		virar_para_player()
		recuando()
		animacao() 		
		
	elif status == "apanhando":	
		$dano_arremesso/shape.disabled = true
		$area_ataque/shape.disabled = true

		if apanhando_agarrado:
			status = "agarrado"
	
		elif caido:
			parado()			
			await anin.animation_finished	
			status = "levantando"
						
		else:
			await anin.animation_finished			
			parado()	
			status = "normal"	
	
	
	elif status == "batendo":
		$dano_arremesso/shape.disabled = true
		$area_corpo/shape.disabled = false
		await anin.animation_finished
		if apanhando_agarrado:
			status = "agarrado"
		else:
			status = "normal"
			
	elif status == "caindo":
		z_index = int(pos_base.y)
		$sombra_sprite.visible = false		
		$area_corpo/shape.disabled = true
		$area_ataque/shape.disabled = true
		$area_agarrao_inimigo/shape.disabled = true
		limite.disabled = true
		
		verificar_queda()
		
#	elif status == "agarrado" and PlayerData.player.status == "agarrar":
	elif status == "agarrado":
		$area_agarrao_inimigo/shape.disabled = true
		$area_ataque/shape.disabled = true
		$area_corpo/shape.disabled = false
		if apanhando_agarrado:	
			play("hit4")					
			await anin.animation_finished
			apanhando_agarrado = false
		else:
			play("agarrado")
		

	elif status == "afastar":		
		tempo_acao += delta
		recuar = true
		
		if tempo_acao >= tempo_espera && status != "agarrado":
			tempo_acao = 0
			status= "normal"
		
	elif status == "levantando":
		
		anin.play("levantando")
		await anin.animation_finished
		status = "normal"
			
	elif status == "morrendo":
		parado()
		$area_ataque/shape.disabled = true
		$area_corpo/shape.disabled = true
		$area_agarrao_inimigo/shape.disabled = true
		
		if anin.current_animation == "queda3" or anin.current_animation == "queda_chao":
			play("queda_chao")
			await anin.animation_finished	
	
		else:
			play("hit3_e")
			await anin.animation_finished
			status = "morto"
		
	elif status == "morto":	
		play("morte")		
		await anin.animation_finished		

		
	


	
	# if status == "normal":
	# 	pos_base = position

	


	

func cair(forca_z:int):
	velocidade.y = -800
	velocidade.x = forca_z
	
	
func verificar_queda():
	#$limite.disabled = true	
	add_collision_exception_with(cena.get_node("Cenario/limite") )
	#$area_corpo/shape.disabled = true
	if status == "caindo" and velocidade.y < 0:
		if arremessado:
			play("arremessado")
		else:	
			play("cair")
		
		
	if status == "caindo" and velocidade.y > 0:
		if arremessado:
			play("arremessado2")
			
		else:
			play("queda3")
			
			
			
	
	velocidade.y += gravidade * get_physics_process_delta_time()
	
	#posição de parada do pulo. Correção de -16 para posição correta.
	if position.y +7  > pos_base.y and position.y < pos_base.y -7 or position.y > pos_base.y:
		parado()
		#$limite.disabled = false
		remove_collision_exception_with(cena.get_node("Cenario/limite"))
		caido = true
		apanhando_agarrado = false
		PlayerData.player_1.tremer_tela(80)
		status = "apanhando"	
		
		efeito_queda()	
		if hp <= 0:
#			if transform.x.x > 0:
#				transform.x = Vector2(-scale.x, 0)
#			elif transform.x.x < 0:
#				transform.x = Vector2(scale.x, 0)
		
			play("queda_chao")
			await anin.animation_finished
			status = "morto"
			
		else:
			play("queda_chao")
			
			
		#await anin.animation_finished	
		


func efeito_hit(tipo:int):
	
	var efeito: Efeito = EFEITO2.instantiate()
	efeito.scale = Vector2(5,5)
	add_child(efeito)
	if tipo == 1:
		var posicao:Vector2 =  $corpo/cabeca.global_position
		#posicao.x += 80
		efeito.global_position = posicao
	elif tipo == 2:
		var posicao:Vector2  =  $corpo.global_position
		#posicao.x -= 80
		efeito.global_position =posicao
		
func efeito_queda():
	var efeito: Efeito = EFEITO.instantiate()
	efeito.scale = Vector2(5,5)
	add_child(efeito)	
	efeito.global_position = $limite.global_position
#	player.apply_noise_shake()
	tocar_som("queda")

func animacao():	
	if status == "normal" and velocidade != Vector2.ZERO:
		anin.play("caminhar")
	else:
		anin.play("parado2")
		

func play(animation: String) -> void:
	anin.play(animation)

#func f_agarrou(tipo):
#	parado()	
#	status ="agarrado"	
#	if tipo == 1:
#		if position.x > player.position.x:
#			transform.x = Vector2(-scale.x, 0)
#		else:
#			transform.x = Vector2(scale.x, 0)
#
		

	

func acertou(tipo:int, forca_h:int):	
	
	parado()
	hp_f(abs(forca_h))
	
	if tipo == 5:
		#efeito_hit()
		
		arremessado = true
		status ="caindo"
		if transform.x.x >0:
			cair(forca_h)
		else:
			cair(-forca_h)
	elif tipo == 3:
		efeito_hit(1)		
		status ="caindo"
		if transform.x.x >0:
			cair(-forca_h)
		else:
			cair(forca_h)
	elif tipo ==4:
		status= "agarrado"
		efeito_hit(2)		
		apanhando_agarrado = true
		if "hit4"== anin.current_animation:
			anin.stop(true)
		play("hit4")
			
	else:
		caido = false
		efeito_hit(1)		
		status = "apanhando"
		
		if "hit"+str(tipo) == anin.current_animation:
			anin.stop(true)
		play("hit"+str(tipo))

	

func f_agarrado():
	status = "normal"
	

func virar_para_player():
	if status == "normal":
		if position.x > PlayerData.position.x:
			transform.x = Vector2(-scale.x, 0)
		else:
			transform.x = Vector2(scale.x, 0)
func parado():
	velocidade = Vector2.ZERO

func recuando():
	tempo_recuar += get_physics_process_delta_time()
	if tempo_recuar > 2:
		recuar = false	
			
	if recuar:
		if transform.x.x > 0:
			velocidade = Vector2(-100,0)
		else:
			velocidade = Vector2(100,0)


func hp_f(valor:int):
	hp -= valor
	$hp.escala = float(hp) / hp_inicial
	
func verificar_posicao_z(atacante:CharacterBody2D, vitima:CharacterBody2D):
	if atacante.pos_base.y > vitima.pos_base.y -40 and atacante.pos_base.y < vitima.pos_base.y+40:
		return true

	
func movimento():
	if PlayerData.status == "voo":
		pass
		#velocidade = Vector2(-100,0)
	else:
		if position.x + 70 > PlayerData.position.x  and position.x - 70 < PlayerData.position.x:
			recuar = true
			tempo_recuar = 0
			#parado()
		else:
			velocidade = position.direction_to(PlayerData.pos_base)* max_velocidade	
#			match comportamento_movimento:
#				1:
#
#					velocidade = Vector2(100,0)
#					timer_comportamento.start(-1)
#
#
#				2: 
#
#					velocidade = Vector2(-100,0)
#					timer_comportamento.start(-1)
#
#				3:
#
#					velocidade = Vector2(0,-100)
#					timer_comportamento.start(-1)
#
#				4:
#
#					velocidade = Vector2(0,100)
#					timer_comportamento.start(-1)
#
#				5:
#
#					velocidade = Vector2(0,100)
#					velocidade = position.direction_to(PlayerData.pos_base)* max_velocidade	
#					timer_comportamento.start(-1)
#			velocidade = Vector2(0,100)
			
#
#
			
			


func on_area_ataque_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo_player":		
		if PlayerData.position.y > position.y - 20 and PlayerData.position.y < position.y + 20:
			parado()
			status = "batendo"
			var comportamento:int = int(randf_range(0,2))
			if comportamento == 0 :			
				play("combo")
			else:	
				play("ataque2")		
#			if player.status != "agarrar" && status != "agarrado":
#				status = "batendo"
#				var comportamento = int(randf_range(0,2))
#				if comportamento == 0 :			
#					play("combo")
#				else:	
#					play("ataque2")
				# play("soco_ai")	
			


#
#func _on_area_ataque_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
#	pass # Replace with function body.
#

func _on_ataque_medio_area_entered(area: Area2D) -> void:	
	if area.name == "area_corpo_player":
		var player_area:CharacterBody2D = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player_area.virar(-1)
			else:
				player_area.virar(1)
			tocar_som("ataque1")
			player_area.emit_signal("acertar",2,20*forca)


func on_dano_arremesso_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo":
		pass
#		var inimigo = area.get_parent()
#		tocar_som("ataque1")
#		inimigo.emit_signal("acertar",3,400)


func tocar_som(som:String):
	$"sons".get_node(som).play()


func on_area_corpo_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo":
		pass
#		var inimigo_proximo:CharacterBody2D = area.get_parent()
#		status = "afastar"
	
	
			
		


func _on_ataque_forte_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo_player":
		var player_area:CharacterBody2D = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player_area.virar(-1)
			else:
				player_area.virar(1)
			tocar_som("ataque1")
			player_area.emit_signal("acertar",3,40*forca)


func _on_ataque_fraco_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo_player":
		var player_area:CharacterBody2D = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player_area.virar(-1)
			else:
				player_area.virar(1)
			tocar_som("ataque_fraco")
			player_area.emit_signal("acertar",2,10*forca)



func on_timer_comportamento_timeout():
	comportamento_movimento = int(randf_range(1,6))			
	timer_comportamento.start(-1)
	




func on_animation_player_animation_finished(anim_name):
	if anim_name == "queda_chao":
		pass			
#		status = "levantando"
#		agarrado = false
	if anim_name == "morte":
		if boss:
			
			queue_free()
			cena.concluir_fase()
		else:
			queue_free()
	
		
	

	if anim_name == "levantando":
		status = "normal"
#		if caido:			
#			status = "normal"
		
	
