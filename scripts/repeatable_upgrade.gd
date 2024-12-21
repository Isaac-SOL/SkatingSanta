class_name RepeatableUpgrade extends Resource

@export var id: StringName
@export var name: String
@export var icon: Texture2D
@export var dependencies: Array[StringName]

func check_dependencies(picked_upgrades: Array[StringName]) -> bool:
	for depency in dependencies:
		if depency not in picked_upgrades:
			return false
	return true
