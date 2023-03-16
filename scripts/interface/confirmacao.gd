extends Control

@onready var btn_cancel: Button = get_node("JanelaConfirmacao/Cancel")
@onready var anim: AnimationPlayer = get_node("Anin")

# Called when the node enters the scene tree for the first time.
func _ready():
	var clicar_cancelar = Callable(self, "cancelar_janela")
	btn_cancel.connect("button_down",clicar_cancelar.bind())	

	

func cancelar_janela() -> void:
	anim.play("desaparecer")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
