# Logger.gd
# Main Logger Node - Public API with theming support
@icon("res://addons/log4godot/icons/logger.svg")
class_name GlobalLogger
extends Node

var manager: LoggerManager

func _ready() -> void:
	manager = LoggerManager.new()

# Configuration methods
func set_global_level(level: LogLevel.Level) -> void:
	manager.set_global_level(level)

func get_global_level() -> LogLevel.Level:
	return manager.get_global_level()

func set_colors_enabled(enabled: bool) -> void:
	manager.set_colors_enabled(enabled)

func set_timestamps_enabled(enabled: bool) -> void:
	manager.set_timestamps_enabled(enabled)
	
func get_timestamps_enabled() -> bool:
	return manager.get_timestamps_enabled()

func set_file_logging_enabled(enabled: bool, file_path: String = "user://game.log") -> void:
	manager.set_file_logging_enabled(enabled, file_path)

func clear_log_file() -> void:
	manager.clear_log_file()

#region Theme management methods
func set_theme(theme: LogTheme) -> void:
	manager.set_theme(theme)

func set_theme_by_name(theme_name: String) -> bool:
	return manager.set_theme_by_name(theme_name)

func get_current_theme() -> LogTheme:
	return manager.get_current_theme()

func add_custom_theme(theme_name: String, theme: LogTheme) -> void:
	manager.add_custom_theme(theme_name, theme)

func get_available_themes() -> Array[String]:
	return manager.get_available_themes()

func get_theme_by_name(theme_name: String) -> LogTheme:
	return manager.get_theme_by_name(theme_name)
#endregion

# Named logger management
func get_logger(logger_name: String, level: LogLevel.Level = LogLevel.Level.INFO) -> LoggerInstance:
	return manager.get_logger(logger_name, level)

func remove_logger(logger_name: String) -> bool:
	return manager.remove_logger(logger_name)

func list_loggers() -> Array[String]:
	return manager.list_loggers()

# Utility methods for backwards compatibility
func log_level_from_string(level_string: String) -> LogLevel.Level:
	return LogLevel.from_string(level_string)

func log_level_to_string(level: LogLevel.Level) -> String:
	return LogLevel.level_to_string(level)
