extends Node2D

@onready var timer:Timer = get_node("Timer")
@export var cena: String =""
@export var anin: AnimationPlayer


func _ready():
	timer.start(-1)

func _process(_delta):
	if Input.is_action_just_pressed("start") or Input.is_action_just_pressed("start_p2"):
		TransicaoTela.cena = "res://cenas/titulo.tscn"
		TransicaoTela.aparecer()			
	

func on_animation_player_animation_finished(_anim_name):
	pass # Replace with function body.


func _on_timer_timeout():
	TransicaoTela.cena = cena
	TransicaoTela.aparecer()
	
