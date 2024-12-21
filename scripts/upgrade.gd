class_name Upgrade extends Resource

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export_multiline var description: String
@export var dependencies: Array[StringName]

func check_dependencies(picked_upgrades: Array[StringName]) -> bool:
	for dependency in dependencies:
		if dependency not in picked_upgrades:
			return false
	return true
