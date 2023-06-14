extends Node
class_name Core

var caminho_database: String = "user://database.dat"

var database: Dictionary = {
	"itens": [],
	"rel": []
}

var save_selecionado: Dictionary = {}



func cadastrar(item: Dictionary) -> void:
	
	database.itens.push_back(item)

	
func editar(item: Dictionary) -> void:
	
	for i in range(database.itens.size()):
		if database.itens[i].id == item.id:
			database.itens[i] = item
			break
			
func novo_item() -> void:
	var saves = core.procurar_itens("save")
	if saves.size() < 6 :
		var data = Time.get_datetime_string_from_system (false,true) 
#		var horario = Time.get_time_string_from_system(false) 
		var item_n: Dictionary = {}
		item_n.id = core.gerar_id()
		item_n.nome = data
		item_n.template = "save"
		item_n.attrs = {
			"conclusao": "0%",
			"level": "1",
			"estagios_concluidos": [],
			"personagem": {}
		}
#		core.database.itens.push_back(item_n)
		
		core.cadastrar(item_n)
		core.gravar_dados()
		core.save_selecionado = item_n
#		get_tree().change_scene_to_file("res://cenas/fase_template.tscn")	
	
func deletar(id:String) -> void:
	for i in range(database.itens.size()):
		if database.itens[i].id == id:
			database.itens.remove_at(i)
			return
	for x in range(database.rel.size()):
		if database.rel[x].origem == id:
			self.deletar(database.rel[x].alvo)
			database.rel.remove_at(x)
	
	
func proc_um_item(id:String) -> Dictionary:
	var item_n:Dictionary = {}	
	for i in range(database.itens.size()):
		if database.itens[i].id == id:
			item_n = database.itens[i]
	return item_n

func proc_um_item_por_nome(nome:String) -> Dictionary:
	var item_n:Dictionary = {}
	
	for i in database.itens:
		if database.itens[i].nome == nome:
			item_n = database.itens[i]
	return item_n


func procurar_itens(template:String) -> Array:
	var itens: Array = []
	for i in range(database.itens.size()):
		if database.itens[i].template == template:
			itens.push_back(database.itens[i]) 
	return itens
	

func gerar_id()-> String:
	var id:String = str(randi ( )+randi ( )+randi ( ))
	
	return id
	

func gravar_dados() -> void:
	var file = FileAccess.open(caminho_database, FileAccess.WRITE)
	file.store_var(database)
	file.close()
	

func carregar_dados() -> bool:
	if FileAccess.file_exists(caminho_database):
		var file = FileAccess.open(caminho_database, FileAccess.READ)	
		database = file.get_var()	
		file.close()
		return true
	else:
		return false


func procurar_sub_itens(id:String, template:String) -> Array:
	var itens: Array = []
	for i in range(database.rel.size()):
		if database.rel[i].origem == id:
			var item_n = self.proc_um_item(database.rel[i].alvo)
			if item_n.template == template:
				itens.push_back(item_n) 
	return itens

func criar_rel(id_origem:String, id_alvo: String, rel_tipo:String) -> void:
	var flag:bool = false
	for i in range(database.rel.size()):
		if database.rel[i].origem == id_origem && database.rel[i].alvo == id_alvo && database.rel[i].rel_tipo == rel_tipo:
			flag = true
	if flag:
		return
	else:
		var n_rel: Dictionary = {
			"origem": id_origem,
			"alvo": id_alvo,
			"rel_tipo": rel_tipo
		}
		database.rel.push_back(n_rel)
		
#func xp_needed_for_level(level: int, xp_per_level: int) -> int:
#	return xp_per_level * pow(2, level-1)

# função para calcular o quanto de xp precisa para subir de level
#var xp_needed = xp_needed_for_level(10, 50)


		


		
		

