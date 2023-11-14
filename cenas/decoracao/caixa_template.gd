extends PhysicsBody2D
class_name Caixa_template

@onready var colisao_base: StaticBody2D = get_node("colisao_base")

var pos_base: Vector2 = Vector2.ZERO

func _process(_delta):
	z_index = abs(position.y)
	pos_base = colisao_base.global_position





