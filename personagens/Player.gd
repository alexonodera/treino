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
var MAGIA: PackedScene =  preload ("res://Effects/magia.tscn")


@export var anin: AnimationPlayer
@onready var cena: Node2D  = $"../../"
@onready var timer_imortal: Timer = get_node("TimerImortal")
@onready var timer_combo: Timer = get_node("TimerCombo")

@onready var area_hit: Area2D = get_node("area_corpo_player")
#@onready var barra_hp = cena.get_node("InterfaceLayer/UserInterface/hp")
@onready var camera: Camera2D = PlayerData.camera
@onready var colisao_z: CollisionShape2D = get_node("area_pulo/shape")
@onready var limite: CollisionShape2D = get_node("limite")
@onready var area_sobre: CollisionShape2D = get_node("area_sobre/shape")


@export var nome: String = "mr_bacon"
@export var max_velocidade: int = 200
@export var velocidade_ataque: int = 1
@export var forca: int = 1000
@export var defesa: int = 10
@export var massa: int= 2000
@export var hp: int = 1500
@export var altura_pulo: int = -1000
@export var distancia_pulo:float = 1.4
@export var vidas: int = 2
var pontuacao: int = 0



signal acertar(tipo:int, forca:int)

var sobre_objeto:bool = false
var tipo_voo: int = 0
var ataque_voando:bool = false
var ataque_agarrado:bool = false
var ataque_correndo:bool = false
var inimigo_atingido:bool = false
var joelhada_atingida:bool = false
var pos_base:Vector2 = Vector2.ZERO
var pos_base_ant: Vector2= Vector2.ZERO
var zindex_ant: int = 0
var status:String = "normal"
var posicao: int = 0
var tipo_especial: int = 0
var tipo_arremesso: int = 0
var imortal:bool = false
var tempo_agarrado: float = 0
var jogador:String = ""
var tag_virar:bool = true


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

var tempo_imortal: float = 5
var tempo_imortal_passando: float = 0

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

var nao_repetir:int = 0

func _ready() -> void:
	desabilitar_ataques()
	connect("acertar",Callable(self,"acertou"))
	hp_inicial = hp
	randomize()
#	PlayerData.player = self
	noise.seed = randi()
	noise.frequency = 2.0

	



func _physics_process(delta:float) -> void:
	
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
		tempo_imortal_passando += delta	
		if tempo_imortal_passando >= tempo_imortal:	
			area_hit.set_deferred("monitoring", true)
			$area_corpo_player/shape.disabled = false
			imortal = false
			nao_repetir = 0
			tempo_imortal_passando = 0



	if status == "normal":
		
		habilitar_areas()
		desabilitar_ataques()
		virar(velocidade.x)
		calcular_velocidade()
		animacao()
		if Input.is_action_just_pressed("ataque"+jogador) and status == "normal":
			tocar_som("golpe_vazio")
			if combo == max_combo:
				combo = 0
			combo_contador()
			status = "batendo"
		
		if Input.is_action_just_pressed("pulo"+jogador) and status == "normal":
			play("pre_pulo")
			tocar_som("pulo")
			status = "voo"
			tipo_voo = 1
			voo(0)

		if Input.is_action_just_pressed("especial"+jogador) and status == "normal":
			status = "especial"

			if abs(velocidade.x) > 0:
				tipo_especial = 1
				tocar_som("carregar_especial2")
			else:
				tipo_especial = 2
				tocar_som("carregar_especial2")



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
		colisao_z.disabled = false
		$sombra_sprite.visible = false
		$area_corpo_player/shape.disabled = true
		if anin.current_animation != "pos_queda":
			$corpo/sombra.visible = false
		if tipo_voo == 4:
			$area_corpo_player/shape.disabled = true
		verificar_voo()

		if velocidade.x != 0 and (tipo_voo == 1 or tipo_voo == 3):
			if (Input.is_action_just_pressed("ataque"+jogador) and status == "voo" and anin.current_animation != "pos_queda"):
				ataque_voando = true
				play("voadora2")
				await anin.animation_finished
				ataque_voando = false
		elif velocidade.x == 0 and tipo_voo == 1:
			if (Input.is_action_just_pressed("ataque"+jogador) and status == "voo" and anin.current_animation != "pos_queda"):
				ataque_voando = true
				play("voadora")
				await anin.animation_finished
				ataque_voando = false

	elif status == "correndo":
		$area_agarrar/shape.disabled = true
		if (Input.is_action_just_pressed("direita"+jogador) or Input.is_action_just_pressed("esquerda"+jogador)) and  ! ataque_correndo:
			status = "normal"
		#await get_tree().create_timer(.2).timeout
		if Input.is_action_just_pressed("ataque"+jogador):
			ataque_correndo = true
			#tocar_som("golpe_vazio")
			play("ataque_correndo")

			await anin.animation_finished
			ataque_correndo = false
			status = "normal"

		if Input.is_action_just_pressed("pulo"+jogador) and  ! ataque_correndo:
			play("pre_pulo")
			tocar_som("pulo")
			status = "voo"
			tipo_voo = 3
			voo(0)


	elif status == "agarrar":

		$area_agarrar/shape.disabled = true
		
		if !ataque_agarrado and inimigo_acao != null:
			if inimigo_acao.status == "morrendo":				
				status = "normal"
				inimigo_acao = null
				return
		
			
#			play("agarrar")
			inimigo_acao.status ="agarrado"
			
			
			
			tempo_agarrado += delta
			if tempo_agarrado >= inimigo_acao.max_tempo_agarrado:
				inimigo_acao.status = "normal"
				status = "normal"
				
				
		
			if verificar_posicao_z( self , inimigo_acao):
				play("agarrar")
				if transform.x.x > 0:
					posicao = int(position.x) + 100		
					inimigo_acao.transform.x = Vector2(-scale.x, 0)			
				else :
					posicao = int(position.x) - 100
					inimigo_acao.transform.x = Vector2(scale.x, 0)	
				inimigo_acao.position.y = position.y
				inimigo_acao.position.x = posicao

#				inimigo_acao.transform.x.x = -transform.x.x
				var direcao = Input.get_action_strength("direita"+jogador) - Input.get_action_strength("esquerda"+jogador)

				
				
				if Input.is_action_just_pressed("ataque"+jogador):
					if direcao == 0:
		
						ataque_agarrado = true
						if combo_joelhada < max_combo_joelhada:
							play("ataque4")
							await anin.animation_finished
							if inimigo_acao != null:
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
		if vidas >= 0:
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
		area_hit.set_deferred("monitoring", false)
		$area_corpo_player/shape.disabled = true
		var pos:Vector2 = $limite.global_position	
		if nao_repetir == 0:		
			efeito_imortal(pos)	
			nao_repetir = 1
		hp = hp_inicial
#			barra_hp.escala = 1
		status = "normal"


	elif status == "levantando":
		play("levantando")
		await anin.animation_finished
		status = "normal"

	elif status == "morto":
		#play("morto")
		#await anin.animation_finished
		game_over()
		#queue_free()
		#PlayerData.emit_signal("died")
		
		

	elif status == "fim_estagio":
		parar()
		anin.play("comemorar")

	elif status == "pegar_item":
		pegar_item()


	if status != "voo":
		if sobre_objeto:
			pos_base = pos_base_ant
			z_index = zindex_ant
		else:
			z_index = int(position.y)
			pos_base = position

func pegar_item()->void:
	parar()
	anin.play("pegar_item")
	await anin.animation_finished
	status= "normal"


	
func game_over():
	PlayerData.fase.game_over()
	

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
			combo = -1
			
	
	await anin.animation_finished
	if inimigo_atingido and combo <3:
		combo +=1
		inimigo_atingido = false
		timer_combo.start(-1)
	else:
		combo = 0
		inimigo_atingido = false
	desabilitar_ataques()
	status = "normal"
	
func atirar() ->void:
	var b = MAGIA.instantiate()
	cena.add_child(b)
	b.transform.x = transform.x
	b.position = $corpo/braco_esquedo.global_position
#	b.position.y -= 100

	

		



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
	
	for objeto in get_tree().get_nodes_in_group("cenario"):		
		add_collision_exception_with(objeto.get_node("colisao_base"))
#	for objeto in get_tree().get_nodes_in_group("cenario"):		
#			add_collision_exception_with(objeto.get_node("limite3"))
#			remove_collision_exception_with(objeto.get_node("colisao_base"))
#		remove_collision_exception_with(base)

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
	#for objeto in get_tree().get_nodes_in_group("cenario"):		
		#add_collision_exception_with(objeto.get_node("colisao_base"))

	if tipo_voo == 1 or tipo_voo == 3:
		if velocidade.y < 0 and  ! ataque_voando:
			play("pulo")
			colisao_z.disabled= true
			area_sobre.disabled= true

		if velocidade.y > 0 and  ! ataque_voando:
			play("queda")
			for objeto in get_tree().get_nodes_in_group("cenario"):		
				add_collision_exception_with(objeto.get_node("colisao_base"))
			colisao_z.disabled= false
			area_sobre.disabled= false
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
		for objeto in get_tree().get_nodes_in_group("cenario"):		
#			add_collision_exception_with(objeto.get_node("limite3"))
			remove_collision_exception_with(objeto.get_node("colisao_base"))
	

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

#func efeito_hit2(posicao_efeito:Vector2):
#	var n_efeito:int = 2
#	var efeito: Efeito = EFEITO.instantiate()
#	efeito.scale = Vector2(5, 5)
#	add_child(efeito)
#	efeito.global_position = posicao_efeito

func efeito_especial(posicao_e:Vector2, efeito_obj:PackedScene,tamanho:Vector2):

	var efeito = efeito_obj.instantiate()
	efeito.scale = tamanho
	add_child(efeito)
	efeito.global_position = posicao_e

func efeito_imortal(posicao_efeito:Vector2):

	var efeito: Efeito = IMORTAL.instantiate()
	efeito.scale = Vector2(1, 1)
	efeito.z_index = int(position.y)
	add_child(efeito)
	efeito.global_position = posicao_efeito


#func efeito_hit3(posicao_efeito:Vector2):
#	var efeito: Efeito = EFEITO6.instantiate()
#	efeito.scale = Vector2(10, 10)
#	add_child(efeito)
#	efeito.global_position = posicao_efeito

#func efeito_hit5(posicao_efeito:Vector2):
#
#	var efeito: Efeito = EFEITO7.instantiate()
#	efeito.scale = Vector2(4, 4)
#	add_child(efeito)
#	efeito.global_position = posicao_efeito

#func efeito_hit4():
#	var efeito: Efeito = EFEITO5.instantiate()
#	efeito.scale = Vector2(5, 5)
#	add_child(efeito)
#	var pos: Vector2 = $ataque_especial_area/shape.global_position
#	efeito.global_position = pos
#	tremer_tela(40)

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
	inimigo_acao = null
	tempo_correndo = 0
	tempo_agarrado = 0
	combo_joelhada = 0
	ataque_agarrado = false
	ataque_correndo = false
	area_hit.set_deferred("monitoring", true)
	colisao_z.disabled = true
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

	if velocidade.x == 0 and velocidade.y == 0:
		tag_virar = true
	if status == "normal" and velocidade != Vector2.ZERO:
		if tag_virar:
			
			anin.play("virar")
			await anin.animation_finished	
			tag_virar = false		
		else:
			anin.play("caminhar")
			

		
	elif status == "correndo" and velocidade != Vector2.ZERO:
#		anin.playback_speed = 1.45
		anin.play("correr")
	else :
#		anin.playback_speed = 1
		anin.play("parado")

func calcular_velocidade():

	if  ! ataque_correndo:
		velocidade.x = Input.get_action_strength("direita"+jogador) - Input.get_action_strength("esquerda"+jogador)
		velocidade.y = Input.get_action_strength("baixo"+jogador) - Input.get_action_strength("cima"+jogador)

	if Input.is_action_just_pressed("correr"+jogador) and status == "normal" and abs(velocidade.x) > 0 and abs(velocidade.y) == 0:
		status = "correndo"

		#correção para movimentação na diagonal
	if status == "correndo":
		velocidade = velocidade.normalized() * max_velocidade * 2
	else :
		velocidade = velocidade.normalized() * max_velocidade

	return velocidade

func acertou(tipo:int, forca_n:int):
	#verificar qual status necessário
	tremer_tela(forca_n)
	efeito_hit(1)
	status = "apanhando"
	hp_2(forca_n)
	parar()
	if tipo == 3:
		if hp > 0:
			if transform.x.x > 0:
				status = "voo"
				tipo_voo = 4
				voo(-forca_n * 6)
			else :
				status = "voo"
				tipo_voo = 4
				voo(forca_n * 6)

	else :
		if status =="voo":
			if transform.x.x > 0:
				status = "voo"
				tipo_voo = 4
				voo(-forca_n * 6)
			else :
				status = "voo"
				tipo_voo = 4
				voo(forca_n * 6)
		else :
			if "hit" + str(tipo) == anin.current_animation:
				anin.stop(true)
			anin.play("hit" + str(tipo))

func hp_2(valor):
	if valor < 0:
		var hp_tmp: int = hp - valor
		if hp_tmp > hp_inicial:
			hp =  hp_inicial
		else:
			hp -= valor
	else:
		hp -= valor
		if hp <= 0:
			vidas -= 1

#	barra_hp.escala = float(hp) / float(hp_inicial)

func cair(forca_c:int):
	velocidade.y = -800
	velocidade.x = forca_c

func virar(lado:float):	
	if lado > 0:

		transform.x = Vector2(scale.x, 0)

	elif lado < 0:
	
		transform.x = Vector2(-scale.x, 0)


func verificar_posicao_z(atacante:CharacterBody2D, vitima):
	if atacante.pos_base.y > vitima.pos_base.y - 20 and atacante.pos_base.y < vitima.pos_base.y + 20:
		return true



func on_ataque_fraco_area_entered(area:Area2D) -> void:
	if area.name == "area_corpo":
		#anin.stop()	
		#await get_tree().create_timer(0.3)
		#anin.play()

		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao_p: Vector2 = $ataque_fraco/shape.global_position
			var tamanho:Vector2 =  Vector2(2,2)
			efeito_especial(posicao_p, EFEITO3, tamanho)	
			
			tocar_som("golpe_fraco")
			tremer_tela(20)
			pontuacao += 30
			
			inimigo.emit_signal("acertar", 1, 30)
			
			inimigo_atingido = true
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_p: Vector2 = $ataque_fraco/shape.global_position
			var tamanho:Vector2 =  Vector2(2,2)
			efeito_especial(posicao_p, EFEITO3, tamanho)
			tocar_som("golpe_fraco")
			tremer_tela(20)
			
			objeto.emit_signal("acertar", transform.x, 30)
			
			inimigo_atingido = true
		
		
			# combo += 1




func on_ataque_medio_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao_p:Vector2 = $ataque_medio/shape.global_position
			var tamanho:Vector2 =  Vector2(4,4)
			efeito_especial(posicao_p, EFEITO3, tamanho)
			tocar_som("golpe_medio")			
			tremer_tela(25)
			pontuacao += 60
			inimigo.emit_signal("acertar", 2, 60)
			inimigo_atingido = true
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_p: Vector2 = $ataque_medio/shape.global_position
			var tamanho:Vector2 =  Vector2(2,2)
			efeito_especial(posicao_p, EFEITO3, tamanho)
			tocar_som("golpe_medio")
			tremer_tela(25)
			objeto.emit_signal("acertar", transform.x, 60)
			inimigo_atingido = true
			
			# combo += 1



func on_ataque_forte_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao_p:Vector2 = $ataque_forte/shape.global_position
			var tamanho:Vector2 =  Vector2(8,8)
			efeito_especial(posicao_p, EFEITO3, tamanho)
			tocar_som("golpe_forte")
			
			tremer_tela(30)
			pontuacao += 100
			inimigo.emit_signal("acertar", 3, 160)
			inimigo_atingido = true
			combo = 0
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_p: Vector2 = $ataque_forte/shape.global_position
			var tamanho:Vector2 =  Vector2(8,8)
			efeito_especial(posicao_p, EFEITO3, tamanho)
			tocar_som("golpe_forte")
			tremer_tela(30)
			objeto.emit_signal("acertar", transform.x, 160)
			inimigo_atingido = true





func _on_voadora2_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
			var posicao_v:Vector2 = $voadora2/shape.global_position
			var tamanho:Vector2 =  Vector2(8,8)
			efeito_especial(posicao_v, EFEITO3, tamanho)
			tocar_som("golpe_forte")
			tremer_tela(40)
			pontuacao += 100
			inimigo.emit_signal("acertar", 3, 160)
			inimigo_atingido = true
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_v: Vector2 = $voadora2/shape.global_position
			var tamanho:Vector2 =  Vector2(8,8)
			efeito_especial(posicao_v, EFEITO3, tamanho)
			tocar_som("golpe_forte")
			tremer_tela(40)
			objeto.emit_signal("acertar", transform.x, 160)
			inimigo_atingido = true




func on_area_agarrar_area_entered(area:Area2D) -> void:
	if area.name == "area_agarrao_inimigo":
		var inimigo:CharacterBody2D = area.get_parent()
		if abs(velocidade) && status == "normal":
			inimigo_acao = inimigo
			parar()			
			status = "agarrar"
			inimigo_acao.position.y = position.y
	



func on_joelhada_area_entered(area:Area2D) -> void:
	if area.name == "area_corpo":
		var posicao_p:Vector2 = $joelhada/shape.global_position
		var tamanho:Vector2 =  Vector2(6,6)
		efeito_especial(posicao_p, EFEITO3, tamanho)
		tocar_som("golpe_fraco")
		inimigo_acao.acertou(4, 120* forca)
		tremer_tela(30)
		inimigo_acao.status = "apanhando"
		combo_joelhada +=1
		



func _on_arremesso_area_entered(area:Area2D) -> void:
	if area.name == "area_agarrao_inimigo":
		var inimigo:CharacterBody2D = area.get_parent()
		if inimigo.status == "agarrado":
			
			if tipo_arremesso == 1:
				if transform.x.x > 0:
					posicao = int(position.x) + 100
				else :
					posicao = int(position.x) - 100
				inimigo.global_position.y = global_position.y
				inimigo.position.x = posicao
			
				pontuacao += 100
				inimigo.emit_signal("acertar", 5, 900)
			else:
				if transform.x.x > 0:
					posicao = int(position.x) + 100
					inimigo.transform.x.x = -0.5
				else :
					posicao = int(position.x)- 100
					inimigo.transform.x.x = 0.5
				inimigo.global_position.y = global_position.y
				inimigo.position.x = posicao
				pontuacao += 100
				inimigo.emit_signal("acertar", 5, 900)
		

func _on_ataque_especial_area_entered(area:Area2D) -> void:
	
	if area.name == "area_corpo":
		var inimigo:CharacterBody2D = area.get_parent()
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao_n:Vector2 = inimigo.get_node("corpo/cabeca").global_position
			tocar_som("golpe_especial")
			var tamanho:Vector2 =  Vector2(16,16)
			efeito_especial(posicao_n, EFEITO3, tamanho)
			tremer_tela(50)
			
			pontuacao += 100
			inimigo.emit_signal("acertar", 3, 220)
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_n: Vector2 = objeto.global_position
			var tamanho:Vector2 =  Vector2(8,8)
			efeito_especial(posicao_n, EFEITO3, tamanho)
			tocar_som("golpe_especial")
			tremer_tela(50)
			objeto.emit_signal("acertar", transform.x, 220)
			
			inimigo_atingido = true
			#inimigo_atingido = true


func _on_ataque_especial2_area_entered(area:Area2D) -> void:
	var inimigo:CharacterBody2D = area.get_parent()
	if area.name == "area_corpo":
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao_a2:Vector2 = inimigo.get_node("corpo/cabeca").global_position
			tremer_tela(50)
			var tamanho:Vector2 =  Vector2(16,16)
			efeito_especial(posicao_a2, EFEITO3, tamanho)
			
			pontuacao += 100
			inimigo.emit_signal("acertar", 3, 220)
	if area.name == "area_acerto":
		var objeto: PhysicsBody2D = area.get_parent()
		if verificar_posicao_z( self , objeto):
			var posicao_a2: Vector2 = objeto.global_position
			var tamanho:Vector2 =  Vector2(16,16)
			efeito_especial(posicao_a2, EFEITO3, tamanho)
			tocar_som("golpe_especial")
			tremer_tela(50)
			objeto.emit_signal("acertar", transform.x, 220)
			
			inimigo_atingido = true
			#inimigo_atingido = true
			#inimigo_atingido = true


func _on_ataque_especial_area_area_entered(area:Area2D) -> void:
	var inimigo:CharacterBody2D = area.get_parent()
	if area.name == "area_corpo":
		if verificar_posicao_z( self , inimigo):
#			var posicao = $ataque_especial/shape.global_position
			var posicao_n: Vector2 = Vector2.ZERO
			posicao_n = inimigo.get_node("corpo/cabeca").global_position
			tocar_som("golpe_especial")
			var tamanho:Vector2 =  Vector2(16,16)
			efeito_especial(posicao_n, EFEITO3, tamanho)
			tremer_tela(50)
			
			pontuacao += 100
			inimigo.emit_signal("acertar", 3, 500)
			#inimigo_atingido = true
			



func tocar_som(som:String):
	$"sons".get_node(som).play()



func on_animation_player_animation_finished(anim_name:String):
	
	#if anim_name == "virar":
		#print("aqui virar 2")
		#tag_virar =false
	if anim_name == "ataque4":
		anin.play("agarrar")
	if  anim_name == "especial1" || anim_name == "pos_queda" || anim_name == "arremesso" || anim_name == "ataque_correndo":
		status = "normal"

	



func on_timer_imortal_timeout():

	imortal = false
	area_hit.set_deferred("monitoring", true)
	$area_corpo_player/shape.disabled = false
	
	


func on_timer_combo_timeout():

	combo = 0


func on_timer_combo_joelhada_timeout():
	combo_joelhada = 0







func on_area_pulo_area_entered(area):
	if area.name == "colisao_z":
		var corpo:CharacterBody2D = area.get_parent()	
		if corpo.pos_base.y >pos_base.y - 10 and corpo.pos_base.y < pos_base.y + 10:
			velocidade.x = velocidade.x * -1
			tocar_som("golpe_fraco")
			tremer_tela(30)






func on_area_sobre_area_entered(area):
	
	if area.name == "area_superior" and sobre_objeto == false:	
	
		var corpo:CharacterBody2D = area.get_parent()
		if corpo.pos_base.y > pos_base.y - 15 and corpo.pos_base.y < pos_base.y + 15:			
			parar()
			zindex_ant = corpo.z_index +1
			pos_base_ant = pos_base			
			var nova_pos = corpo.get_node("area_superior/shape").global_position
			pos_base = nova_pos
			sobre_objeto = true
		
		


func on_area_sobre_area_exited(area):

	if area.name == "area_superior" and sobre_objeto == true:
		
		var corpo:CharacterBody2D = area.get_parent()

		if corpo.pos_base.y > pos_base_ant.y - 20 and corpo.pos_base.y < pos_base_ant.y +20 and area.name =="area_superior":
				
			if velocidade.y >0 and status != "voo":
				pos_base_ant.y += 30
				pos_base = pos_base_ant
				for objeto in get_tree().get_nodes_in_group("cenario"):
					var base = objeto.get_node("colisao_base")
					add_collision_exception_with(base)
#				limite.disabled = true
			elif velocidade.y < 0 and status != "voo":
				pos_base_ant.y -= 30
				pos_base = pos_base_ant
				z_index = zindex_ant -10
			
			
			status = "voo"
			sobre_objeto = false
#			position.y += 100
