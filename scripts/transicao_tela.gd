extends CanvasLayer

@onready var anin: AnimationPlayer = get_node("AnimationPlayer")

var cena: String = ""

func aparecer():
	anin.play("desaparecer")
	


func on_animation_player_animation_finished(anim_name):
	if anim_name == "desaparecer":
		if cena:
			var _mudar_cena: bool = get_tree().change_scene_to_file(cena)
		else:
			get_tree().reload_current_scene()
		anin.play("aparecer")
