# Logger.gd
# Main Logger Node - Public API with theming support
extends Node

var manager: LoggerManager

func _ready():
	manager = LoggerManager.new()

# Global logger methods (shortcuts for main logger)
func trace(message: String) -> void:
	manager.get_main_logger().trace(message)

func debug(message: String) -> void:
	manager.get_main_logger().debug(message)

func info(message: String) -> void:
	manager.get_main_logger().info(message)

func warn(message: String) -> void:
	manager.get_main_logger().warn(message)

func error(message: String) -> void:
	manager.get_main_logger().error(message)

func fatal(message: String) -> void:
	manager.get_main_logger().fatal(message)

func log(level: LogLevel.Level, message: String) -> void:
	manager.get_main_logger().log(level, message)

# Global log level checking functions
func is_trace_enabled() -> bool:
	return manager.get_main_logger().is_trace_enabled()

func is_debug_enabled() -> bool:
	return manager.get_main_logger().is_debug_enabled()

func is_info_enabled() -> bool:
	return manager.get_main_logger().is_info_enabled()

func is_warn_enabled() -> bool:
	return manager.get_main_logger().is_warn_enabled()

func is_error_enabled() -> bool:
	return manager.get_main_logger().is_error_enabled()

func is_fatal_enabled() -> bool:
	return manager.get_main_logger().is_fatal_enabled()

func is_level_enabled(level: LogLevel.Level) -> bool:
	return manager.get_main_logger().is_level_enabled(level)

# Configuration methods
func set_global_level(level: LogLevel.Level) -> void:
	manager.set_global_level(level)

func get_global_level() -> LogLevel.Level:
	return manager.get_global_level()

func set_colors_enabled(enabled: bool) -> void:
	manager.set_colors_enabled(enabled)

func set_timestamps_enabled(enabled: bool) -> void:
	manager.set_timestamps_enabled(enabled)

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

func get_global_logger() -> LoggerInstance:
	return manager.get_main_logger()

# Utility methods for backwards compatibility
func log_level_from_string(level_string: String) -> LogLevel.Level:
	return LogLevel.from_string(level_string)

func log_level_to_string(level: LogLevel.Level) -> String:
	return LogLevel.level_to_string(level)
