extends Node


signal updated
signal died

var score: = 0 : set = set_score
var deaths: = 0 : set = set_deaths
var vidas: = 2 : set = set_vidas
var position:Vector2 = Vector2.ZERO
var pos_base:Vector2 = Vector2.ZERO
var status:String = ""
var player: CharacterBody2D = null 





func reset():
	self.score = 0
	self.deaths = 0




func set_score(new_score: int) -> void:
	score = new_score
	emit_signal("updated")


func set_deaths(new_value: int) -> void:
	deaths = new_value
	emit_signal("died")
	
func set_vidas(vidas_restantes: int) -> void:
	vidas = vidas_restantes
	emit_signal("updated")
	if vidas < 0:
#		vidas = 0
		emit_signal("died")
