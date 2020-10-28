extends Node

enum ObjectType {
	ARCHITECTURE, TROOP, PERSON
}

static func object_distance(a, b) -> int:
	return a.map_position.distance_to(b.map_position)

static func nearest_architecture_of_faction(faction, map_position, exclude = null):
	var result
	var min_dist = 9e9
	for arch in faction.get_architectures():
		if arch == exclude:
			 continue
		var dist = Util.m_dist(map_position, arch.map_position)
		if dist < min_dist:
			min_dist = dist
			result = arch
	return result
	
class InfluenceContainer:
	var influences: Array
	var conditions: Array
	

static func apply_influences(influence_container, in_operation, params: Dictionary):
	if params.has("value"):
		var value = params['value']
		var level = params['level'] if params.has('level') else 1
		
		if not check_conditions(influence_container, params):
			return value
		
		for influence in influence_container.influences:
			if in_operation == influence['Operation']:
				if influence['Operation'].begins_with('modify'):
					value = value * max(0, 1 + influence["Value"] * level)
				elif influence['Operation'].begins_with('add'):
					value = value + influence["Value"] * level
				else:
					assert('Value Operation shall start with add or modify')
		return value
	else:
		assert('Applying influences must provide value in params')

static func _op_cond(op_not, op_value):
	return (not op_not and op_value) or (op_not and not op_value)

static func check_conditions(influence_container, params: Dictionary):
	for condition in influence_container.conditions:
		var operator = Util.dict_try_get(condition, "Operator", [])
		var op_not = operator.has('not')
		match condition['Operation']:
			'gender_male':
				if params.has('person'):
					if _op_cond(op_not, params['person'].gender):
						return false
			'gender_female':
				if params.has('person'):
					if _op_cond(op_not, not params['person'].gender):
						return false
			'is_leader': 
				if params.has('troop') and params.has('person'):
					if _op_cond(op_not, params['troop'].get_leader() != params['person']):
						return false
			'is_military_type':
				if params.has('troop'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['troop'].military_kind.type in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['troop'].military_kind.type != condition['Id']):
							return false
				elif params.has('military_kind'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['military_kind'].type in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['military_kind'].type != condition['Id']):
							return false
			'is_terrain':
				if params.has('troop'):
					if condition['Id'] is Array:
						if _op_cond(op_not, not (params['troop'].get_current_terrain().id in condition['Id'])):
							return false
					else:
						if _op_cond(op_not, params['troop'].get_current_terrain().id != condition['Id']):
							return false
			'is_on_own_architecture':
				if params.has('troop'):
					var arch = params['troop'].get_on_architecture()
					if _op_cond(op_not, arch == null or !arch.get_belonged_faction().is_friend_to(params['troop'].get_belonged_faction())):
						return false
			'is_on_enemy_architecture':
				if params.has('troop'):
					var arch = params['troop'].get_on_architecture()
					if _op_cond(op_not, arch == null or !arch.get_belonged_faction().is_enemy_to(params['troop'].get_belonged_faction())):
						return false
			'target_is_troop':
				if params.has('target'):
					if _op_cond(op_not, params['target'].object_type() != ObjectType.TROOP):
						return false
			'target_is_architecture':
				if params.has('target'):
					if _op_cond(op_not, params['target'].object_type() != ObjectType.ARCHITECTURE):
						return false
			'internal_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].internal_exp < condition['Value']):
						return false
			'combat_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].combat_exp < condition['Value']):
						return false
			'command_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_command() < condition['Value']):
						return false
			'command_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].command_exp < condition['Value']):
						return false
			'strength_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_strength() < condition['Value']):
						return false
			'strength_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].strength_exp < condition['Value']):
						return false
			'intelligence_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_intelligence() < condition['Value']):
						return false
			'intelligence_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].intelligence_exp < condition['Value']):
						return false
			'politics_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_politics() < condition['Value']):
						return false
			'politics_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].politics_exp < condition['Value']):
						return false
			'glamour_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].get_glamour() < condition['Value']):
						return false
			'glamour_experience_at_least':
				if params.has('person'):
					if _op_cond(op_not, params['person'].glamour_exp < condition['Value']):
						return false
	return true

static func influence_troop_leader_offensive_factor(influence_container, level: int, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_offence":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_defensive_factor(influence_container, level: int, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "modify_person_troop_defence":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_critical_factor(influence_container, level: int, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "add_person_troop_critical":
			return 1 + influence["Value"] * level
	
	return 1

static func influence_troop_leader_anti_critical_factor(influence_container, level: int, params: Dictionary):
	if not check_conditions(influence_container, params):
		return 1
	
	for influence in influence_container.influences:
		if influence['Operation'] == "add_person_troop_anti_critical":
			return 1 + influence["Value"] * level
	
	return 1
