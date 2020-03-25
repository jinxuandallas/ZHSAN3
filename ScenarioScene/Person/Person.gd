extends Node
class_name Person

enum Task { NONE, AGRICULTURE, COMMERCE, MORALE, ENDURANCE, MOVE, RECRUIT_TROOP, TRAIN_TROOP, PRODUCE_EQUIPMENT }

var id: int setget forbidden
var scenario

var surname: String setget forbidden
var given_name: String setget forbidden
var courtesy_name: String setget forbidden

var _belonged_architecture setget set_belonged_architecture,get_belonged_architecture

var command: int setget forbidden
var strength: int setget forbidden
var intelligence: int setget forbidden
var politics: int setget forbidden
var glamour: int setget forbidden

var working_task setget forbidden
var producing_equipment setget forbidden

var task_days = 0 setget forbidden

func forbidden(x):
	assert(false)


func load_data(json: Dictionary):
	id = json["_Id"]
	surname = json["Surname"]
	given_name = json["GivenName"]
	courtesy_name = json["CourtesyName"]
	command = json["Command"]
	strength = json["Strength"]
	intelligence = json["Intelligence"]
	politics = json["Politics"]
	glamour = json["Glamour"]
	working_task = json["Task"]
	producing_equipment = scenario.military_kinds.get(json["ProducingEquipment"])
	
func save_data() -> Dictionary:
	return {
		"_Id": id,
		"Surname": surname,
		"GivenName": given_name,
		"CourtesyName": courtesy_name,
		"Command": command,
		"Strength": strength,
		"Intelligence": intelligence,
		"Politics": politics,
		"Glamour": glamour,
		"Task": working_task,
		"ProducingEquipment": producing_equipment.id
	}

func get_name() -> String:
	return surname + given_name
	
func get_belonged_architecture(): 
	return _belonged_architecture
	
func set_belonged_architecture(arch, force = false):
	_belonged_architecture = arch
	if not force:
		arch.add_person(self, true)
		
func get_agriculture_ability():
	return 0.25 * intelligence + 0.5 * politics + 0.25 * glamour
	
func get_commerce_ability():
	return 0.5 * intelligence + 0.25 * politics + 0.25 * glamour
	
func get_morale_ability():
	return 0.25 * command + 0.25 * strength + 0.5 * glamour
	
func get_endurance_ability():
	return 0.25 * command + 0.25 * strength + 0.25 * intelligence + 0.25 * politics
	
func get_recruit_troop_ability():
	return 0.5 * strength + 0.5 * glamour
	
func get_train_troop_ability():
	return 0.5 * command + 0.5 * strength
	
func get_produce_equipment_ability():
	return 0.5 * intelligence + 0.5 * politics
	
func set_working_task(work):
	working_task = work
	
func get_working_task_str():
	match working_task:
		Task.NONE: return tr('NONE')
		Task.AGRICULTURE: return tr('AGRICULTURE')
		Task.COMMERCE: return tr('COMMERCE')
		Task.MORALE: return tr('MORALE')
		Task.ENDURANCE: return tr('ENDURANCE')
		Task.RECRUIT_TROOP: return tr('RECRUIT_TROOP')
		Task.TRAIN_TROOP: return tr('TRAIN_TROOP')
		Task.PRODUCE_EQUIPMENT: return tr('PRODUCE_EQUIPMENT')
		_: return tr('NONE')
		
func get_producing_equipment_name():
	if producing_equipment == null:
		return "--"
	else:
		return producing_equipment.get_name()
		
func move_to_architecture(arch):
	var old_arch = get_belonged_architecture()
	set_belonged_architecture(arch)
	working_task = Task.MOVE
	task_days = int(ScenarioUtil.arch_distance(old_arch, arch) * 0.2)
		
func day_event():
	if task_days > 0:
		task_days -= 1
	
