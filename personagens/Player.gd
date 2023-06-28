extends CharacterBody2D
class_name Player_one

var EFEITO: PackedScene =  preload ("res://Effects/hit2.tscn")
var EFEITO3: PackedScene =  preload ("res://Effects/hit3.tscn")
var EFEITO4: PackedScene =  preload ("res://Effects/hit4.tscn")
var EFEITO5: PackedScene =  preload ("res://Effects/hit5.tscn")
var EFEITO6: PackedScene =  preload ("res://Effects/hit6.tscn")
var EFEITO7: PackedScene =  preload ("res://Effects/hit7.tscn")
var IMORTAL: PackedScene =  preload ("res://Effects/imortal.tscn")
var OLHO: PackedScene =  preload ("res://Effects/olho.tscn")
var QUEDA: PackedScene = preload("res://Effects/hit.tscn")


@onready var anin: AnimationPlayer =$AnimationPlayer
@onready var cena: Node2D  = $"../../"
@onready var timer_imortal: Timer = get_node("TimerImortal")
@onready var timer_combo: Timer = get_node("TimerCombo")
@onready var timer_agarrar: Timer = get_node("TimerAgarrar")
@onready var area_hit: Area2D = get_node("area_corpo_player")
#@onready var barra_hp = cena.get_node("InterfaceLayer/UserInterface/hp")
@onready var camera: Camera2D = get_node("Camera2D")

@export var max_velocidade: int = 200
@export var velocidade_ataque: int = 1
@export var forca: int = 10
@export var defesa: int = 10
@export var massa: int= 2000
@export var hp: int = 1500
@export var altura_pulo: int = -1000
@export var distancia_pulo:float = 1.4
@export var vidas: int = 0



signal acertar(tipo:int, forca:int)


var tipo_voo: int = 0
var ataque_voando:bool = false
var ataque_agarrado:bool = false
var ataque_correndo:bool = false
var inimigo_atingido:bool = false
var joelhada_atingida:bool = false
var pos_base:Vector2 = Vector2.ZERO
var status:String = "normal"
var posicao: int = 0
var tipo_especial: int = 0
var tipo_arremesso: int = 0
var imortal:bool = false
var tempo_agarrado: float = 0


var hp_inicial: int = 0
var velocidade:Vector2 = Vector2.ZERO
var combo: int = 0
var max_combo: int = 4

#var combo_reset:float = 0.5
#var tempo_combo: int = 0

var combo_joelhada: int = 0
var max_combo_joelhada: int = 3


var tempo_espera:float = 0.5
var tempo_correndo: int = 0

var tempo_imortal: int = 10
var tempo_imortal_passando: int = 0

var inimigo_acao:CharacterBody2D = null

@export var NOISE_SHAKE_SPEED:float = 50.0
@export var NOISE_SHAKE_STRENGTH:float = 30.0
@export var SHAKE_DECAY_RATE:float = 10.0

#@onready var camera = $"Camera2D"
@onready var rand = RandomNumberGenerator.new()
#@onready var noise = FastNoiseLite.new()
var noise: FastNoiseLite = FastNoiseLite.new()

var noise_i:float = 0.0
#
var shake_strength:float = 0.0

func _ready() -> void:
	desabilitar_ataques()
	connect("acertar",Callable(self,"acertou"))
	hp_inicial = hp
	PlayerData.vidas = vidas
	randomize()
#	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
#	noise.seed = randi()
#	noise.frequency = 2.0
#	var x =0
#	var y = 0
#	var value = noise.noise.get_noise_2d(x, y)
	randomize()
	noise.seed = randi()
	noise.frequency = 2.0



func _physics_process(delta:float) -> void:
	PlayerData.position = global_position
	PlayerData.status = status
	PlayerData.pos_base = pos_base
	#Código para a tela tremer quando houver um impacto
	shake_strength = lerp(shake_strength,0.0, SHAKE_DECAY_RATE * delta)
#	
	camera.offset = get_noise_offset(delta)
	# Fim do código para a tela tremer quando houver um impacto
#	var pos_olho = $corpo/cabeca/olho.global_position
#	efeito_olho(pos_olho)

	if hp <= 0 and status != "morto" and status != "revivendo":
		status = "morrendo"

	set_velocity(velocidade)
	move_and_slide()

	if imortal:
		area_hit.set_deferred("monitoring", false)
		$area_corpo_player/shape.disabled = true
		timer_imortal.start(-1)
		var pos:Vector2 = $limite.global_position
		efeito_imortal(pos)



	if status == "normal":
		habilitar_areas()
		inimigo_acao = null
		tempo_correndo = 0
		tempo_agarrado = 0
		combo_joelhada = 0
		ataque_agarrado = false
		ataque_correndo = false
		desabilitar_ataques()
		virar(velocidade.x)
		calcular_velocidade()
		animacao()
		if Input.is_action_just_pressed("ataque") and status == "normal":
			tocar_som("golpe_vazio")
			if combo == max_combo:
				combo = 0
			combo_contador()
			status = "batendo"
		
		if Input.is_action_just_pressed("pulo") and status == "normal":
			play("pre_pulo")
			tocar_som("pulo")
			status = "voo"
			tipo_voo = 1
			voo(0)

		if Input.is_action_just_pressed("especial") and status == "normal":
			status = "especial"

			if abs(velocidade.x) > 0:
				tipo_especial = 1
				tocar_som("carregar_especial2")
			else:
				tipo_especial = 2
				tocar_som("carregar_especial")



	elif status == "batendo":
		# combo_contador()
		pass


	elif status == "apanhando":
		if inimigo_acao != null && inimigo_acao.status == "agarrado":
			inimigo_acao.status = "normal"
			inimigo_acao = null
		desabilitar_ataques()
		parar()
		await anin.animation_finished
		status = "normal"


	elif status == "voo":
		$sombra_sprite.visible = false
		$area_corpo_player/shape.disabled = true
		if anin.current_animation != "pos_queda":
			$corpo/sombra.visible = false
		if tipo_voo == 4:
			$area_corpo_player/shape.disabled = true
		verificar_voo()

		if velocidade.x != 0 and (tipo_voo == 1 or tipo_voo == 3):
			if (Input.is_action_just_pressed("ataque") and status == "voo" and anin.current_animation != "pos_queda"):
				ataque_voando = true

				play("voadora2")
				await anin.animation_finished
				ataque_voando = false
		elif velocidade.x == 0 and tipo_voo == 1:
			if (Input.is_action_just_pressed("ataque") and status == "voo" and anin.current_animation != "pos_queda"):
				ataque_voando = true

				play("voadora")
				await anin.animation_finished
				ataque_voando = false

	elif status == "correndo":
		$area_agarrar/shape.disabled = true
		if (Input.is_action_just_pressed("direita") or Input.is_action_just_pressed("esquerda")) and  ! ataque_correndo:
			status = "normal"
		#await get_tree().create_timer(.2).timeout
		if Input.is_action_just_pressed("ataque"):
			ataque_correndo = true
			#tocar_som("golpe_vazio")
			play("ataque_correndo")

			await anin.animation_finished
			ataque_correndo = false
			status = "normal"

		if Input.is_action_just_pressed("pulo") and  ! ataque_correndo:
			play("pre_pulo")
			tocar_som("pulo")
			status = "voo"
			tipo_voo = 3
			voo(0)


	elif status == "agarrar":
#		print(inimigo_acao.nome)
		$area_agarrar/shape.disabled = true
		
		if !ataque_agarrado and inimigo_acao != null:
			if inimigo_acao.status == "morrendo":
				
				status = "normal"
				inimigo_acao = null
				return
		
			
			play("agarrar")
			inimigo_acao.status ="agarrado"
			
			tempo_agarrado += delta
			if tempo_agarrado >= inimigo_acao.max_tempo_agarrado:
				inimigo_acao.status = "normal"
				status = "normal"
				
				
		
			if verificar_posicao_z( self , inimigo_acao):
				if transform.x.x > 0:
					posicao = position.x + 100
					
				else :
					posicao = position.x - 100
				inimigo_acao.position.y = position.y
				inimigo_acao.position.x = posicao
	#			print(inimigo_acao.transform.x.x)
				inimigo_acao.transform.x.x = -transform.x.x
				var direcao = Input.get_action_strength("direita") - Input.get_action_strength("esquerda")

				
				
				if Input.is_action_just_pressed("ataque"):
					if direcao == 0:
						ataque_agarrado = true
						if combo_joelhada < max_combo_joelhada:
							play("ataque4")
							await anin.animation_finished
							inimigo_acao.status ="agarrado"
							ataque_agarrado = false
						else:
							ataque_agarrado = true
							play("especial1")
							inimigo_acao.status ="normal"
							inimigo_acao = null
							await anin.animation_finished
						
					elif direcao > 0:
						if transform.x.x > 0:
							ataque_agarrado = true
							play("especial1")
							inimigo_acao.status ="normal"
							inimigo_acao = null
							await anin.animation_finished
							
							
						else:
							ataque_agarrado = true
							play("arremesso")
							inimigo_acao.status ="normal"
							inimigo_acao.acertou( 5, 900)
							inimigo_acao = null
							await anin.animation_finished
							
							ataque_agarrado = false
						
					else:
						if transform.x.x < 0:
							ataque_agarrado = true
							play("especial1")
							inimigo_acao.status ="normal"
							await anin.animation_finished
							
							
							
						else:
							ataque_agarrado = true
							play("arremesso")
							inimigo_acao.status ="normal"
							inimigo_acao.acertou( 5, 900)
							inimigo_acao = null
							await anin.animation_finished
							ataque_agarrado = false
	#			await anin.animation_finished			

			else:
				inimigo_acao.status ="normal"
				status = "normal"
				inimigo_acao = null
# 		if Input.get_action_strength("direita") or Input.get_action_strength("esquerda"):
# 			if Input.is_action_just_pressed("ataque"):
# 				if Input.get_action_strength("esquerda") ==1 and transform.x.x >0 :
# 					play("arremesso")
# 					tipo_arremesso = 1
# 				elif  Input.get_action_strength("esquerda") ==1 and transform.x.x < 0 :
# #					arremesso para frente
# #					transform.x.x = 0.5
# 					play("especial3")
# 					tipo_arremesso = 2
# 				elif  Input.get_action_strength("esquerda") ==0 and transform.x.x < 0 :
# 					play("arremesso")
# 					tipo_arremesso = 1
# 				elif  Input.get_action_strength("esquerda") ==0 and transform.x.x > 0 :
# #					arremesso para frente
# #					transform.x.x = -0.5
# 					play("especial3")
# 					tipo_arremesso = 2
			
# 				ataque_agarrado = true
# 				await anin.animation_finished
# 				ataque_agarrado = false
# 				status = "normal"
# 		else: 
# 			if Input.is_action_just_pressed("ataque") and anin.current_animation != "arremesso":

# 				if combo_joelhada == max_combo_joelhada:
# 					print("ataque3")
# 					# play("ataque_correndo")
# 					# ataque_agarrado = true
# 					# await anin.animation_finished
# 					# ataque_agarrado = false
					
# 					# combo = 3
# 					# status = "batendo"
# 				else :
# 					play("ataque4")

# 				ataque_agarrado = true
# 				await anin.animation_finished
# 				ataque_agarrado = false
# 		if  !ataque_agarrado:
			# play("agarrar")
	elif status =="especial":
		if tipo_especial == 1:
			var efeito: Efeito = EFEITO4.instantiate()
			efeito.scale = Vector2(10, 10)
			add_child(efeito)

			efeito.global_position = $corpo/braco_direito/pulso.global_position
			parar()
#			anin.playback_speed = 0.9
			play("especial1")
			await anin.animation_finished
			status = "normal"
		else :
			var efeito: Efeito = EFEITO4.instantiate()
			efeito.scale = Vector2(15, 15)
			add_child(efeito)
			efeito.global_position = $corpo/braco_direito.global_position
			parar()
			play("especial3")
			await anin.animation_finished
			status = "normal"
	elif status == "morrendo":
		if PlayerData.vidas > 0:
			$area_corpo_player/shape.disabled = true
			play("hit3")
			await anin.animation_finished
			status = "revivendo"
		else :
			$area_corpo_player/shape.disabled = true
			play("hit3")
			await anin.animation_finished
			status = "morto"

	elif status == "revivendo":
		play("levantando")
		await anin.animation_finished
		imortal = true
		PlayerData.vidas -= 1
		# hp = hp_inicial
#			barra_hp.escala = 1
		status = "normal"


	elif status == "levantando":
		play("levantando")
		await anin.animation_finished
		status = "normal"

	elif status == "morto":
		PlayerData.emit_signal("died")




	if status != "voo":
		z_index = position.y
		pos_base = position

func combo_contador()->void:
	parar()
	
	match combo:
		0:
			play("ataque1")
		1:
			play("ataque1")
		2:
			play("ataque2")
		3:
			play("ataque3")
	
	await anin.animation_finished
	if inimigo_atingido:
		combo +=1
		inimigo_atingido = false
		timer_combo.start(-1)
	else:
		combo = 0
		inimigo_atingido = false
	desabilitar_ataques()
	status = "normal"
	

#func tremer_tela()->void:
#	pass
func tremer_tela(forca_efeito) -> void:
	shake_strength = forca_efeito

#func apply_noise_shake() -> void:
#	shake_strength = NOISE_SHAKE_STRENGTH

func get_noise_offset(delta:float) -> Vector2:
	noise_i += delta * NOISE_SHAKE_SPEED

	return Vector2(
		noise.get_noise_2d(1, noise_i) * shake_strength,
		noise.get_noise_2d(100, noise_i) * shake_strength
	)

func resetar_player():
	pass


func combo_joelhada_mais():
	combo_joelhada += 1


func voo(forca_voo:float):

	add_collision_exception_with(cena.get_node("Cenario/limite"))
	if tipo_voo == 1:
		if abs(velocidade.x) > 0:
			velocidade.y = altura_pulo
		else :
			velocidade.y = altura_pulo
			velocidade.x = velocidade.x * distancia_pulo
	elif tipo_voo == 3:
		velocidade.y = altura_pulo * 0.8
		velocidade.x = velocidade.x * distancia_pulo / 0.95
	elif tipo_voo == 4:
		velocidade.y = -800
		velocidade.x = forca_voo



func verificar_voo():
	if tipo_voo == 1 or tipo_voo == 3:
		if velocidade.y < 0 and  ! ataque_voando:
			play("pulo")

		if velocidade.y > 0 and  ! ataque_voando:
			play("queda")
	elif tipo_voo == 2:
		if velocidade.y < 0:
			play("pulo")

		if velocidade.y > 0:
			play("queda")
	elif tipo_voo == 4:
		$area_corpo_player/shape.disabled = true
		if velocidade.y < 0:
			play("cair")

		if velocidade.y > 0:
			play("queda2")




	velocidade.y += massa * get_physics_process_delta_time()

	#posição de parada do pulo. Correção de -16 para posição correta.
	if position.y + 8 > pos_base.y and position.y < pos_base.y + 8 or position.y > pos_base.y:
	#if position.y > pos_base.y:
		$sombra_sprite.visible = true
		remove_collision_exception_with(cena.get_node("Cenario/limite"))

		if tipo_voo == 2:
			
			status = "apanhando"
#			apply_noise_shake()
			efeito_queda()
			play("levantando")
		#await get_node("AnimationPlayer").animation_finished
		if tipo_voo == 1 or tipo_voo == 3:
			ataque_voando = false
			desabilitar_ataques()
			parar()
			
			play("pos_queda")
			tremer_tela(2)

			$corpo/sombra.visible = true
#			anin.playback_speed = 2 + velocidade_ataque
			await anin.animation_finished
#			anin.playback_speed = 1
			status = "normal"
		elif tipo_voo == 4:
			status = "apanhando"
			efeito_queda()
			play("levantando")


func efeito_hit(tipo:int):

	var efeito: Efeito = EFEITO.instantiate()
	efeito.scale = Vector2(5, 5)
	add_child(efeito)
	if tipo == 1:
		efeito.global_position = $corpo/cabeca.global_position
	elif tipo == 2:
		efeito.global_position = $corpo.global_position

func efeito_hit2(posicao_efeito:Vector2):

	var efeito: Efeito = EFEITO3.instantiate()
	efeito.scale = Vector2(5, 5)
	add_child(efeito)
	efeito.global_position = posicao_efeito

#func efeito_olho(posicao):
#
#	var efeito: Efeito = OLHO.instantiate()
#	efeito.scale = Vector2(0.5, 0.5)
#	add_child(efeito)
#	efeito.global_position = posicao

func efeito_imortal(posicao_efeito:Vector2):

	var efeito: Efeito = IMORTAL.instantiate()
	efeito.scale = Vector2(5, 5)
	efeito.z_index = position.y
	add_child(efeito)

	efeito.global_position = posicao_efeito


func efeito_hit3(posicao_efeito:Vector2):
	var efeito: Efeito = EFEITO6.instantiate()
	efeito.scale = Vector2(10, 10)
	add_child(efeito)
	efeito.global_position = posicao_efeito

func efeito_hit5(posicao_efeito:Vector2):
	var efeito: Efeito = EFEITO7.instantiate()
	efeito.scale = Vector2(4, 4)
	add_child(efeito)
	efeito.global_position = posicao_efeito

func efeito_hit4():
	var efeito: Efeito = EFEITO5.instantiate()
	efeito.scale = Vector2(5, 5)
	add_child(efeito)
	var pos: Vector2 = $ataque_especial_area/shape.global_position
	efeito.global_position = pos
	tremer_tela(40)

func efeito_queda():
	var efeito: Efeito = QUEDA.instantiate()
	efeito.scale = Vector2(10,10)
	add_child(efeito)
	
	efeito.global_position = $limite.global_position
	tremer_tela(40)
#	apply_noise_shake()
	tocar_som("queda")

func desabilitar_ataques():
	$ataque_fraco/shape.disabled = true
	$ataque_medio/shape.disabled = true
	$ataque_forte/shape.disabled = true
	$voadora2/shape.disabled = true
	$ataque_especial_area/shape.disabled = true
	$ataque_especial/shape.disabled = true
	$joelhada/shape.disabled = true
	$arremesso/shape.disabled = true

func habilitar_areas():
	area_hit.set_deferred("monitoring", true)
	$sombra_sprite.visible = true
	$corpo/sombra.visible = true
	$area_agarrar/shape.disabled = false
	if !imortal:
		$area_corpo_player/shape.disabled = false



func parar():
	velocidade = Vector2.ZERO

func play(animation:String) -> void:
	anin.play(animation)

func animacao():

	if status == "normal" and velocidade != Vector2.ZERO:
#		anin.playback_speed = 1
		anin.play("caminhar")
	elif status == "correndo" and velocidade != Vector2.ZERO:
#		anin.playback_speed = 1.45
		anin.play("correr")
	else :
#		anin.playback_speed = 1
		anin.play("parado")

func calcular_velocidade():

	if  ! ataque_correndo:
		velocidade.x = Input.get_action_strength("direita") - Input.get_action_strength("esquerda")
		velocidade.y = Input.get_action_strength("baixo") - Input.get_action_strength("cima")

	if Input.is_action_just_pressed("correr") and status == "normal" and abs(velocidade.x) > 0 and abs(velocidade.y) == 0:
		status = "correndo"

		#correção para movimentação na diagonal
	if status == "correndo":
		velocidade = velocidade.normalized() * max_velocidade * 2
	else :
		velocidade = velocidade.normalized() * max_velocidade

	return velocidade

func acertou(tipo:int, forca:int):
	#verificar qual status necessário
	tremer_tela(forca)
	efeito_hit(1)
	status = "apanhando"
	hp_2(forca)
	parar()
	if tipo == 3:
		if hp > 0:
			if transform.x.x > 0:
				status = "voo"
				tipo_voo = 4
				voo(-forca * 6)
			else :
				status = "voo"
				tipo_voo = 4
				voo(forca * 6)

	else :
		if status =="voo":
			if transform.x.x > 0:
				status = "voo"
				tipo_voo = 4
				voo(-forca * 6)
			else :
				status = "voo"
				tipo_voo = 4
				voo(forca * 6)
		else :
			if "hit" + str(tipo) == anin.current_animation:
				anin.stop(true)
			play("hit" + str(tipo))

func hp_2(valor):
	hp -= valor

#	barra_hp.escala = float(hp) / float(hp_inicial)

func cair(forca:int):
	velocidade.y = -800
	velocidade.x = forca

func virar(lado:float):
	if lado > 0:
		transform.x = Vector2(scale.x, 0)

	elif lado < 0:
		transform.x = Vector2(-scale.x, 0)


func verificar_posicao_z(atacante:CharacterBody2D, vitima:CharacterBody2D):
	if atacante.pos_base.y > vitima.pos_base.y - 40 and atacante.pos_base.y < vitima.pos_base.y + 40:
		return true

func on_ataque_fraco_area_entered(area:Area2D) -> void:
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao: Vector2 = $ataque_fraco/shape.global_position
			efeito_hit2(posicao)
			tocar_som("golpe_fraco")
			tremer_tela(20)
			inimigo.emit_signal("acertar", 1, 30)
			PlayerData.score += 10
			inimigo_atingido = true
		
		
			# combo += 1




func on_ataque_medio_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao:Vector2 = $ataque_medio/shape.global_position
			efeito_hit2(posicao)
			tocar_som("golpe_medio")
			PlayerData.score += 20
			tremer_tela(25)
			inimigo.emit_signal("acertar", 2, 60)
			inimigo_atingido = true
			
			# combo += 1



func on_ataque_forte_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao:Vector2 = $ataque_forte/shape.global_position
			efeito_hit2(posicao)
			tocar_som("golpe_forte")
			PlayerData.score += 30
			tremer_tela(30)
			inimigo.emit_signal("acertar", 3, 800)
			inimigo_atingido = true
			combo = 0





func _on_voadora2_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao:Vector2 = $voadora2/shape.global_position
			efeito_hit2(posicao)
			tocar_som("golpe_forte")
			tremer_tela(40)
			PlayerData.score += 35
			inimigo.emit_signal("acertar", 3, 800)
			inimigo_atingido = true




func on_area_agarrar_area_entered(area:Area2D) -> void:
	if area.name == "area_agarrao_inimigo":
		var inimigo:CharacterBody2D = area.get_parent()
		if abs(velocidade) && status == "normal":
			inimigo_acao = area.get_parent()
			parar()
			
			status = "agarrar"
	

		# parar()	

		# if status == "normal" and inimigo.status == "normal" and abs(velocidade.x) > 0 :
		# 	status = "agarrar"
		# 	parar()
		# 	inimigo.parado()
		# 	inimigo.status = "agarrado"
		# 	timer_agarrar.start(-1)
		# 	# var timer_inimigo_agarrado: Timer = inimigo.get_node("TimerAgarrado")
		# 	# timer_inimigo_agarrado.start(-1)
		# 	inimigo.emit_signal("agarrar", 1)			
		# 	if verificar_posicao_z( self , inimigo):
		# 		if transform.x.x > 0:
		# 			posicao = position.x + 100
		# 		else :
		# 			posicao = position.x - 100				
		# 		inimigo.global_position.y = position.y							
		# 		inimigo.position.x = posicao


		# 		#inimigo.parado()
		# 		PlayerData.score += 5



func on_joelhada_area_entered(area:Area2D) -> void:
	if area.name == "area_corpo":
		var posicao:Vector2 = $joelhada/shape.global_position
		efeito_hit2(posicao)
		tocar_som("golpe_fraco")
		inimigo_acao.acertou(4, 120)
		tremer_tela(30)
		inimigo_acao.status = "apanhando"
		combo_joelhada +=1
		
#	if area.name == "area_corpo": 
#		var inimigo:CharacterBody2D = area.get_parent()
#		if inimigo.status == "agarrado":			
#			if verificar_posicao_z( self , inimigo):
#				var posicao:Vector2 = $joelhada/shape.global_position
#				efeito_hit2(posicao)
#				tocar_som("golpe_fraco")
##				tremer_tela(30)
#				PlayerData.score += 25
#				inimigo.emit_signal("acertar", 4, 120)
#				combo_joelhada += 1


func _on_arremesso_area_entered(area:Area2D) -> void:
	if area.name == "area_agarrao_inimigo":
		var inimigo:CharacterBody2D = area.get_parent()
		if inimigo.status == "agarrado":
			PlayerData.score += 40
			if tipo_arremesso == 1:
				if transform.x.x > 0:
					posicao = position.x + 100
				else :
					posicao = position.x - 100
				inimigo.global_position.y = global_position.y
				inimigo.position.x = posicao
			
				inimigo.emit_signal("acertar", 5, 900)
			else:
				if transform.x.x > 0:
					posicao = position.x + 100
					inimigo.transform.x.x = -0.5
				else :
					posicao = position.x - 100
					inimigo.transform.x.x = 0.5
				inimigo.global_position.y = global_position.y
				inimigo.position.x = posicao
				inimigo.emit_signal("acertar", 5, 900)
		




func _on_ataque_especial_area_entered(area:Area2D) -> void:
	var inimigo:CharacterBody2D = area.get_parent()
	if area.name == "area_corpo":
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao:Vector2 = inimigo.get_node("corpo/cabeca").global_position
			tocar_som("golpe_especial")
			efeito_hit3(posicao)
			tremer_tela(50)
			PlayerData.score += 35
			inimigo.emit_signal("acertar", 3, 800)
			#inimigo_atingido = true


func _on_ataque_especial2_area_entered(area:Area2D) -> void:
	var inimigo:CharacterBody2D = area.get_parent()
	if area.name == "area_corpo":
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao:Vector2 = inimigo.get_node("corpo/cabeca").global_position
			tremer_tela(50)
			efeito_hit3(posicao)
			PlayerData.score += 35
			inimigo.emit_signal("acertar", 3, 800)
			#inimigo_atingido = true


func _on_ataque_especial_area_area_entered(area:Area2D) -> void:
	var inimigo:CharacterBody2D = area.get_parent()
	if area.name == "area_corpo":
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao: Vector2 = Vector2.ZERO
			posicao = inimigo.get_node("corpo/cabeca").global_position
			tocar_som("golpe_especial")
			efeito_hit5(posicao)
			tremer_tela(50)
			PlayerData.score += 60
			inimigo.emit_signal("acertar", 3, 500)
			#inimigo_atingido = true


func tocar_som(som:String):
	$"sons".get_node(som).play()



func on_animation_player_animation_finished(anim_name:String):
	if anim_name == "ataque4":
		play("agarrar")
	if  anim_name == "especial1" || anim_name == "pos_queda" || anim_name == "arremesso" || anim_name == "ataque_correndo":
		status = "normal"

	pass # Replace with function body.


func on_timer_imortal_timeout():
	imortal = false
	


func on_timer_combo_timeout():
	
	combo = 0


func on_timer_combo_joelhada_timeout():
	combo_joelhada = 0



func on_timer_agarrar_timeout():
	pass
#	if status == "agarrar":
#		status = "normal"



