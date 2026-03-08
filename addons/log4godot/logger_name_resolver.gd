# LoggerNameResolver.gd
# Handles deriving logger names from objects
class_name LoggerNameResolver

## Derives a logger name from an object.
## Returns the class_name, script filename, or Godot class name.
## [br][br]
## Priority:
## 1. The class_name if defined in the script
## 2. The script filename (without extension) converted to PascalCase
## 3. The Godot base class name if no script is attached
static func derive_logger_name(object: Object) -> StringName:
	if object == null:
		return "Unknown"
	
	var script: Script = object.get_script()
	
	if script != null:
		# Priority 1: Use class_name if defined
		var global_name: StringName = script.get_global_name()
		if global_name != "":
			return global_name
		
		# Priority 2: Use script filename without extension
		var script_path: String = script.resource_path
		if script_path != "":
			var filename: String = script_path.get_file().get_basename()
			# Convert snake_case to PascalCase for consistency
			return to_pascal_case(filename)
	
	# Priority 3: Fall back to Godot's class name
	return object.get_class()

## Converts a snake_case or kebab-case string to PascalCase.
## Example: "my_player_script" -> "MyPlayerScript"
static func to_pascal_case(text: String) -> StringName:
	var result: String = ""
	var capitalize_next: bool = true
	
	for i: int in range(text.length()):
		var c: String = text[i]
		if c == "_" or c == "-":
			capitalize_next = true
		elif capitalize_next:
			result += c.to_upper()
			capitalize_next = false
		else:
			result += c
	
	return result
