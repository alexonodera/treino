extends CharacterBody2D

var EFEITO = preload("res://Effects/hit.tscn")
var EFEITO2 = preload("res://Effects/hit2.tscn")

@export var nome = ""
@export var max_velocidade = 200
@export var gravidade = 2000

@onready var player = $"../../Players/Player"
@onready var anin := $AnimationPlayer
@onready var cena = $"../../"
@onready var timer_agarrado: Timer = get_node("TimerAgarrado")
@onready var timer_area_agarrado: Timer = get_node("TimerAreaAgarrado")
@onready var area_agarrao_inimigo = get_node("area_agarrao_inimigo") as Area2D
var pos_base = Vector2.ZERO
signal acertar(tipo, forca)
signal agarrar(tipo)


var batendo = false
var apanhando = false
var recuar = false
var tempo_recuar = 0
var caindo = false
var agarrado = false
var status: String = "normal"
var apanhando_agarrado = false
var arremessado = false
var tempo_agarrado = 0
var max_tempo_agarrado = 2
var tempo_acao = 0
var tempo_espera = 2

@export var hp = 1500
var hp_inicial = hp


var velocidade = Vector2.ZERO



func _ready() -> void:
	connect("acertar",Callable(self,"acertou"))
	connect("agarrar",Callable(self,"f_agarrou"))
	hp_inicial = hp
	


func _physics_process(delta: float) -> void:

	if hp <= 0 and !arremessado:
		if apanhando_agarrado:
			player.status = "normal"
			apanhando_agarrado = false
		status = "morrendo"
		
		
		
	#print("inimigo: "+status)	
	set_velocity(velocidade)
	move_and_slide()
	
	if status == "normal":	
		
		apanhando_agarrado = false
		arremessado =false
		tempo_agarrado = 0
		$sombra_sprite.visible = true
		$area_corpo/shape.disabled = false
		$area_agarrao_inimigo/shape.disabled = false
		$area_ataque/shape.disabled = false
		$ataque_medio/shape.disabled = true
		$ataque_fraco/shape.disabled = true
		$ataque_forte/shape.disabled = true
		$dano_arremesso/shape.disabled = true
		$corpo/sombra.visible =true
		movimento()
		virar_para_player()
		recuando()
		animacao() 		
		
	elif status == "apanhando":
		$dano_arremesso/shape.disabled = true
		$area_ataque/shape.disabled = true
		
		if anin.current_animation == "levantando":

			$area_corpo/shape.disabled = true
		else:
			$area_corpo/shape.disabled = false
		parado()
		await get_node("AnimationPlayer").animation_finished
		if apanhando_agarrado:
			status = "agarrado"
		else:
			status = "normal"		
	
	elif status == "batendo":
		$dano_arremesso/shape.disabled = true
		$area_corpo/shape.disabled = false
		await get_node("AnimationPlayer").animation_finished
		if apanhando_agarrado:
			status = "agarrado"
		else:
			status = "normal"
	elif status == "caindo":
		$sombra_sprite.visible = false
		$corpo/sombra.visible =false
		$area_corpo/shape.disabled = true
		$area_ataque/shape.disabled = true
		$area_agarrao_inimigo/shape.disabled = true
		
		verificar_queda()
		
	elif status == "agarrado":
		
		pos_base = position
		$area_ataque/shape.disabled = true
		$area_corpo/shape.disabled = false
	
#		tempo_agarrado += delta
#
#		if tempo_agarrado >= max_tempo_agarrado:
#			status= "normal"
#			player.status = "normal"
#
#		if player.status != "agarrar":
#			status = "normal"

		
		if apanhando_agarrado:	
					
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
		
			
	elif status == "morrendo":
		
		parado()		
		$area_corpo/shape.disabled = true
		$area_agarrao_inimigo/shape.disabled = true
		play("hit3_e")
		
		#$corpo/sombra.visible =false
		await get_node("AnimationPlayer").animation_finished
		PlayerData.score += 1
		queue_free()

	z_index = position.y
	if status == "normal":
		pos_base = position

func cair(forca):
	velocidade.y = -800
	velocidade.x = forca
	
	
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
			play("queda2")
	
	velocidade.y += gravidade * get_physics_process_delta_time()
	
	#posição de parada do pulo. Correção de -16 para posição correta.
	if position.y +7  > pos_base.y and position.y < pos_base.y +7 or position.y > pos_base.y:

		#$limite.disabled = false
		remove_collision_exception_with(cena.get_node("Cenario/limite"))
		status = "apanhando"	
		efeito_queda()	
		if hp <= 0:
			if transform.x.x > 0:
				transform.x = Vector2(-scale.x, 0)
			elif transform.x.x < 0:
				transform.x = Vector2(scale.x, 0)
			
			play("hit3_e")
			await anin.animation_finished
			queue_free()
		else:
			play("levantando")
		#await get_node("AnimationPlayer").animation_finished	
		


func efeito_hit(tipo):
	
	var efeito = EFEITO2.instantiate()
	efeito.scale = Vector2(10,10)
	add_child(efeito)
	if tipo == 1:
		var posicao =  $corpo/cabeca.global_position
		#posicao.x += 80
		efeito.global_position = posicao
	elif tipo == 2:
		var posicao =  $corpo.global_position
		#posicao.x -= 80
		efeito.global_position =posicao
		
func efeito_queda():
	var efeito = EFEITO.instantiate()
	efeito.scale = Vector2(10,10)
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

func f_agarrou(tipo):

	parado()	
	status ="agarrado"	
#	timer_agarrado.start(-1)
	if tipo == 1:
		if position.x > player.position.x:
			transform.x = Vector2(-scale.x, 0)
		else:
			transform.x = Vector2(scale.x, 0)
		
		

	

func acertou(tipo, forca):	
	
	parado()
	hp_f(abs(forca))
	if tipo == 5:
		#efeito_hit()
		arremessado = true
		status ="caindo"
		if transform.x.x >0:
			cair(forca)
		else:
			cair(-forca)
	elif tipo == 3:
		efeito_hit(1)		
		status ="caindo"
		if transform.x.x >0:
			cair(-forca)
		else:
			cair(forca)
	elif tipo ==4:
		status= "agarrado"
		efeito_hit(2)		
		apanhando_agarrado = true
		if "hit4"== anin.current_animation:
			anin.stop(true)
		play("hit4")
			
	else:
		efeito_hit(1)
		
		status = "apanhando"
		if "hit"+str(tipo) == anin.current_animation:
			anin.stop(true)
		play("hit"+str(tipo))
	

func f_agarrado():
	status = "normal"
	

func virar_para_player():
	if status == "normal":
		if position.x > player.position.x:
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

func hp_f(valor):
	hp -= valor
	$hp.escala = float(hp) / hp_inicial
	
func verificar_posicao_z(atacante, vitima):
	if atacante.pos_base.y > vitima.pos_base.y -40 and atacante.pos_base.y < vitima.pos_base.y+40:
		return true

	
func movimento():
	if player.status == "voo":
		pass
#velocidade = Vector2(-100,0)
	else:

		if position.x + 100> player.position.x  and position.x - 100 < player.position.x:
			recuar = true
			tempo_recuar = 0
			#parado()
		else:
			velocidade = position.direction_to(player.pos_base)* max_velocidade	


func on_area_ataque_area_entered(area: Area2D) -> void:
	
	if area.name == "area_corpo_player":		
		if player.position.y > position.y - 20 and player.position.y < position.y + 20:
			parado()
			print(status +" "+ player.status)
			if player.status != "agarrar" && status != "agarrado":
				status = "batendo"
				var comportamento = int(randf_range(0,2))
				if comportamento == 0 :
					print("soco1")
					play("combo")
				else:
					print("soco2")
					play("combo")
				# play("soco_ai")	
			


#
#func _on_area_ataque_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
#	pass # Replace with function body.
#

func _on_ataque_medio_area_entered(area: Area2D) -> void:	
	if area.name == "area_corpo_player":
		var player_area = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player.virar(-1)
			else:
				player.virar(1)
			tocar_som("ataque1")
			player_area.emit_signal("acertar",2,100)


func _on_dano_arremesso_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo":
		var inimigo = area.get_parent()
		tocar_som("ataque1")
		inimigo.emit_signal("acertar",3,400)


func tocar_som(som):
	$"sons".get_node(som).play()


func _on_area_corpo_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo":
		var inimigo_proximo = area.get_parent()		
		if status == "normal":
			status = "afastar"
		elif inimigo_proximo.status =="normal":
			inimigo_proximo.recuar = true	
	
			
		


func _on_ataque_forte_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo_player":
		var player_area = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player.virar(-1)
			else:
				player.virar(1)
			tocar_som("ataque1")
			player_area.emit_signal("acertar",3,80)


func _on_ataque_fraco_area_entered(area: Area2D) -> void:
	if area.name == "area_corpo_player":
		var player_area = area.get_parent()
		if verificar_posicao_z(self,player_area):
			if transform.x.x > 0:
				player.virar(-1)
			else:
				player.virar(1)
			tocar_som("ataque_fraco")
			player_area.emit_signal("acertar",2,20)


func on_timer_agarrado_timeout():
	print("bacon")
	status = "normal"
	if status == "agarrado":
		status = "normal"
	area_agarrao_inimigo.set_deferred("monitoring", false)
	$area_agarrao_inimigo/shape.disabled = true
	timer_area_agarrado.start(-1)
	



func on_timer_area_agarrado_timeout():
	print("bacon2")
	area_agarrao_inimigo.set_deferred("monitoring", true)
	$area_agarrao_inimigo/shape.disabled = false
