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

	
func deletar(id:String) -> void:
	for i in range(database.itens.size()):
		if database.itens[i].id == id:
			print(i)
			database.itens.remove_at(i)
			return
	
func proc_um_item(id:String) -> Dictionary:
	var item_n:Dictionary = {}
	
	for i in database.itens:
		if database.itens[i].id == id:
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
			itens.push_back(self.proc_um_item(database.rel[i].alvo)) 
	return itens



