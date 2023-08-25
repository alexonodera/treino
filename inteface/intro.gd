extends Node2D

@onready var timer:Timer = get_node("Timer")


func _ready():
	timer.start(-1)

func on_animation_player_animation_finished(_anim_name):
	pass # Replace with function body.


func _on_timer_timeout():
	TransicaoTela.cena = "res://cenas/titulo.tscn"
	TransicaoTela.aparecer()
	
