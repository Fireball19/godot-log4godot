# Logger.gd
# Main Logger Node - Public API and backwards compatibility
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
