extends CharacterBody2D


@export var speed = 400
@export var jump_height = 50
var is_on_ground = true
var initial_y = 0
var is_jumping = false

func get_input():
	if is_on_ground:
		var input_direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		set_velocity(input_direction * speed)
#		velocity = 

#	var is_jumping = velocity.y < 0
	if position.y >= initial_y:
		is_on_ground = true

func _physics_process(delta):
	get_input()

	if is_on_ground and Input.is_action_just_pressed("ui_accept"):
		is_jumping = true
		initial_y = position.y
		velocity.y = -jump_height
		is_on_ground = false

	move_and_slide()

