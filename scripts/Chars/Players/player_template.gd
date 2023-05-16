extends CharacterBody2D
class_name Player


@onready var area_hit = get_node("AreaHit") as Area2D
@onready var anin: AnimationPlayer =$Anin
@onready var timer_imortal: Timer = get_node("TimerImortal")


@export var max_velocidade: int = 200
@export var velocidade_ataque : int = 1
@export var forca: int = 10
@export var defesa: int = 10
@export var massa: int = 2000
@export var hp: int = 1500
@export var altura_pulo: int = -1000
@export var distancia_pulo:float = 1.4
@export var vidas: int = 0


var hp_inicial: int = 0


var tipo_voo:int = 0
var ataque_voando:bool = false
var ataque_agarrado:bool = false
var ataque_correndo:bool = false
var inimigo_atingido:bool = false
var joelhada_atingida:bool = false
var pos_base:Vector2 = Vector2.ZERO
var status:String = "normal"
var substatus: String = "normal"

var posicao: int = 0
var tipo_especial: int = 0
var tipo_arremesso: int = 0

#var imortal:bool = false
#var tempo_imortal_renascimento:int = 10
#var tempo_imortal_passando:int = 0


var velocidade:Vector2 = Vector2.ZERO
var combo: int = 0
var max_combo: int = 4
var combo_reset:float = 0.5
var tempo_combo: int = 0


var combo_joelhada: int = 0
var max_combo_joelhada: int = 2


var tempo_espera:float = 0.5
var tempo_correndo:int = 0


signal acertar(tipo, forca)

func _ready() -> void:
	connect("acertar",Callable(self,"acertou"))
	
	
	
func _physics_process(delta:float) -> void:
	
	set_velocity(velocidade)
	move_and_slide()
	
	match status:
		"normal":
			virar(velocidade.x)
			calcular_velociade()
			animacao()
			
			if Input.is_action_just_pressed("pulo") and status == "normal":
				
#				play("pre_pulo")
#				tocar_som("pulo")
				status = "voo"
				tipo_voo = 1
				voo(0)
		"batendo":
			pass
		"apanhando":
			pass
		"voo":
#			$sombra_sprite.visible = false
#			if anin.current_animation != "pos_queda":
#				$corpo/sombra.visible = false
#			if tipo_voo == 4:
#				$area_corpo_player/shape.disabled = true
			verificar_voo()

#			if velocidade.x != 0 and (tipo_voo == 1 or tipo_voo == 3):
#				if (Input.is_action_just_pressed("ataque") and status == "voo" and anin.current_animation != "pos_queda"):
#					ataque_voando = true
#
#					play("voadora2")
#					await anin.animation_finished
#					ataque_voando = false
#			elif velocidade.x == 0 and tipo_voo == 1:
#				if (Input.is_action_just_pressed("ataque") and status == "voo" and anin.current_animation != "pos_queda"):
#					ataque_voando = true
#
#					play("voadora")
#					await anin.animation_finished
#					ataque_voando = false
		"levantando":
			anin.play("levantando")
			pass
		"correndo":
			pass
		"agarrando":
			pass
		"especial":
			pass
		"morrendo":
			pass	
		"revivendo":
			pass
		"morto":
			pass
			
	if status != "voo":
		z_index = position.y
		pos_base = position		
			
func animacao()-> void:
	if status == "normal" and velocidade != Vector2.ZERO:
#		anin.playback_speed = 1
		anin.play("caminhar")
	elif status == "correndo" and velocidade != Vector2.ZERO:
#		anin.playback_speed = 1.45
		anin.play("caminhar")
	else :
#		anin.playback_speed = 1
		anin.play("parado")

func virar(lado:float)->void:
	if lado > 0:
		transform.x = Vector2(scale.x, 0)

	elif lado < 0:
		transform.x = Vector2(-scale.x, 0)

func calcular_velociade()->Vector2:

	if  substatus != "ataque_correndo":
		velocidade.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
		velocidade.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

#	if Input.is_action_just_pressed("ui_select") and status == "normal" and abs(velocidade.x) > 0 and abs(velocidade.y) == 0:
#		status = "correndo"

		#correção para movimentação na diagonal
	if status == "correndo":
		velocidade = velocidade.normalized() * max_velocidade * 2
	else :
		velocidade = velocidade.normalized() * max_velocidade

	return velocidade
	
func voo(forca_voo):

#	add_collision_exception_with(cena.get_node("Cenario/limite"))
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
#			play("pulo")
			play("cair")

		if velocidade.y > 0 and  ! ataque_voando:
#			play("queda")
			play("cair_baixo")			
	elif tipo_voo == 2:
		if velocidade.y < 0:
#			play("pulo")
			play("cair")
		if velocidade.y > 0:
			play("cair_baixo")
	elif tipo_voo == 4:
#		$area_corpo_player/shape.disabled = true
		area_hit.set_deferred("monitoring", true)
		if velocidade.y < 0:
			play("cair")

		if velocidade.y > 0:
#			play("queda2")
			play("cair_baixo")

	velocidade.y += massa * get_physics_process_delta_time()

	#posição de parada do pulo. Correção de -16 para posição correta.
	if position.y + 8 > pos_base.y and position.y < pos_base.y + 8 or position.y > pos_base.y:
	#if position.y > pos_base.y:
		
#		remove_collision_exception_with(cena.get_node("Cenario/limite"))

		if tipo_voo == 2:
			
			status = "apanhando"
#			apply_noise_shake()
#			efeito_queda()
			play("cair_chao")
		#await get_node("AnimationPlayer").animation_finished
		if tipo_voo == 1 or tipo_voo == 3:
			ataque_voando = false
#			desabilitar_ataques()
			parar()
			
#			play("pos_queda")
			play("cair_chao")

#			$corpo/sombra.visible = true
#			anin.playback_speed = 2 + velocidade_ataque
#			await anin.animation_finished
#			anin.playback_speed = 1
#			status = "normal"
		elif tipo_voo == 4:
			status = "apanhando"
#			efeito_queda()
			play("cair_chao")

func play(animation:String) -> void:

	anin.play(animation)
	
func parar():
	velocidade = Vector2.ZERO
	



		
func on_anin_animation_finished(anim_name):
	if anim_name == "cair_chao":
		status = "levantando"		
		
	if anim_name == "levantando":
		status = "normal"


func _on_timer_imortal_timeout():
	area_hit.set_deferred("monitoring", true)



