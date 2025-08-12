# LogTheme.gd
# Resource class for log theming configuration
class_name LogTheme
extends Resource

@export var trace_color: Color = Color(0.804, 0.812, 0.824)
@export var debug_color: Color = Color(0.872, 1.0, 0.997)
@export var info_color: Color = Color(0.804, 0.812, 0.824)
@export var warn_color: Color = Color(1.0, 1.0, 0.0)
@export var error_color: Color = Color(1.0, 0.0, 0.0)
@export var fatal_color: Color = Color(1.0, 0.0, 0.0)

@export var timestamp_color: Color = Color(0.804, 0.812, 0.824)

@export var theme_name: String = "Default"

static var default_themes: Dictionary = {
	"Default" : ResourceLoader.load("res://addons/log4godot/themes/default_log_theme.tres"),
	"Minimal" : ResourceLoader.load("res://addons/log4godot/themes/minimal_log_theme.tres"),
	"Whiteout" : ResourceLoader.load("res://addons/log4godot/themes/whiteout_log_theme.tres"),
	"Fallout" : ResourceLoader.load("res://addons/log4godot/themes/fallout_log_theme.tres")
}

func get_color_for_level(level: LogLevel.Level) -> Color:
	match level:
		LogLevel.Level.TRACE:
			return trace_color
		LogLevel.Level.DEBUG:
			return debug_color
		LogLevel.Level.INFO:
			return info_color
		LogLevel.Level.WARN:
			return warn_color
		LogLevel.Level.ERROR:
			return error_color
		LogLevel.Level.FATAL:
			return fatal_color
		_:
			return Color.WHITE
