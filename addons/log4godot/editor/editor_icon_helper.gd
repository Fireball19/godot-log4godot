## Utility class for accessing Godot's native editor icons in plugins.
##
## This class provides easy access to the built-in editor icons that Godot uses
## throughout its interface. These icons automatically adapt to the editor theme
## and provide a consistent look for plugin UIs.
## [br][br]
## Usage:
## [codeblock]
## # Get an icon by name
## var play_icon := EditorIconHelper.get_icon("Play")
## 
## # Get an icon with custom color
## var colored_icon := EditorIconHelper.get_icon("Error", Color.RED)
## 
## # Get a list of all available icon names
## var icon_names := EditorIconHelper.get_available_icon_names()
## [/codeblock]
## [br][br]
## Note: This class only works in editor context. When running in-game,
## methods will return null or empty values.
@tool
class_name EditorIconHelper
extends RefCounted

## Cache for loaded icons to avoid repeated lookups.
static var _icon_cache: Dictionary = {}

## Returns an editor theme icon by name.
## [br][br]
## [param icon_name]: The name of the icon (e.g., "Play", "Node", "Error").
## [param modulate_color]: Optional color to tint the icon. Use Color.BLACK (default) for no modulation.
## [br][br]
## Returns the [Texture2D] icon, or null if not in editor or icon not found.
static func get_icon(icon_name: String) -> Texture2D:
	if not Engine.is_editor_hint():
		return null
	
	# Return cached or fetch new
	return _get_raw_icon(icon_name)


## Checks if a specific icon exists in the editor theme.
## [br][br]
## [param icon_name]: The name of the icon to check.
## [br][br]
## Returns true if the icon exists, false otherwise.
static func has_icon(icon_name: String) -> bool:
	if not Engine.is_editor_hint():
		return false
	
	var base_control := EditorInterface.get_base_control()
	if base_control == null:
		return false
	
	return base_control.has_theme_icon(icon_name, "EditorIcons")
	

## Returns an editor color from the editor settings.
## Useful for matching plugin UI to the current editor theme.
## [br][br]
## [param setting_path]: The path to the color setting (e.g., "text_editor/theme/highlighting/background_color").
## [param default_color]: The fallback color if the setting doesn't exist.
## [br][br]
## Returns the [Color] from settings or the default.
static func get_editor_color(setting_path: String, default_color: Color) -> Color:
	if not Engine.is_editor_hint():
		return default_color
	
	var settings := EditorInterface.get_editor_settings()
	if settings == null:
		return default_color
	
	if settings.has_setting(setting_path):
		return settings.get_setting(setting_path)
	
	return default_color


## Returns the editor's base control node.
## Useful for accessing theme resources directly.
## [br][br]
## Returns the base [Control] node, or null if not in editor.
static func get_editor_base_control() -> Control:
	if not Engine.is_editor_hint():
		return null
	
	return EditorInterface.get_base_control()


## Clears the icon cache. Call this if icons need to be refreshed
## (e.g., after an editor theme change).
static func clear_cache() -> void:
	_icon_cache.clear()


## Internal: Gets the raw icon from the editor theme without modulation.
static func _get_raw_icon(icon_name: String) -> Texture2D:
	if _icon_cache.has(icon_name):
		return _icon_cache[icon_name]
	
	var base_control := EditorInterface.get_base_control()
	if base_control == null:
		return null
	
	var icon := base_control.get_theme_icon(icon_name, "EditorIcons")
	if icon:
		_icon_cache[icon_name] = icon
	
	return icon
