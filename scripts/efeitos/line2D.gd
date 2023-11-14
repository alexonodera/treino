extends Line2D

@export var length: int = 30 
@onready var parent:Node2D = get_parent()


func _ready():
	set_as_top_level(true)
	clear_points()
	
func _physics_process(_delta):
	z_index = abs(parent.global_position.y)
	add_point(parent.global_position)
	
	if points.size() > length:
		remove_point(0)
	
	
