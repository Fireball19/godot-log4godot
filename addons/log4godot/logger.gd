extends Node

# Log levels enum
enum LogLevel {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	FATAL = 5
}

# Color definitions for different log levels
const LOG_COLORS = {
	LogLevel.TRACE: Color.WHITE,
	LogLevel.DEBUG: Color.CYAN,
	LogLevel.INFO: Color.GREEN,
	LogLevel.WARN: Color.YELLOW,
	LogLevel.ERROR: Color.ORANGE_RED,
	LogLevel.FATAL: Color.RED
}

# Log level names
const LOG_LEVEL_NAMES = {
	LogLevel.TRACE: "TRACE",
	LogLevel.DEBUG: "DEBUG",
	LogLevel.INFO: "INFO",
	LogLevel.WARN: "WARN",
	LogLevel.ERROR: "ERROR",
	LogLevel.FATAL: "FATAL"
}

# Global settings
var global_log_level: LogLevel = LogLevel.INFO
var enable_colors: bool = true
var enable_timestamps: bool = true
var enable_file_logging: bool = false
var log_file_path: String = "user://game.log"

# Named loggers dictionary
var named_loggers: Dictionary = {}

# Main logger instance
var _main_logger: LoggerInstance

class LoggerInstance:
	var name: String
	var log_level: LogLevel
	var parent_logger: Node
	
	func _init(logger_name: String, level: LogLevel, parent: Node):
		name = logger_name
		log_level = level
		parent_logger = parent
	
	func set_level(level: LogLevel) -> void:
		log_level = level
	
	func get_level() -> LogLevel:
		return log_level
	
	# Log level checking functions
	func is_trace_enabled() -> bool:
		return _is_level_enabled(LogLevel.TRACE)
	
	func is_debug_enabled() -> bool:
		return _is_level_enabled(LogLevel.DEBUG)
	
	func is_info_enabled() -> bool:
		return _is_level_enabled(LogLevel.INFO)
	
	func is_warn_enabled() -> bool:
		return _is_level_enabled(LogLevel.WARN)
	
	func is_error_enabled() -> bool:
		return _is_level_enabled(LogLevel.ERROR)
	
	func is_fatal_enabled() -> bool:
		return _is_level_enabled(LogLevel.FATAL)
	
	func is_level_enabled(level: LogLevel) -> bool:
		return _is_level_enabled(level)
	
	func _is_level_enabled(level: LogLevel) -> bool:
		return level >= log_level and level >= parent_logger.global_log_level
	
	func trace(message: String) -> void:
		_log(LogLevel.TRACE, message)
	
	func debug(message: String) -> void:
		_log(LogLevel.DEBUG, message)
	
	func info(message: String) -> void:
		_log(LogLevel.INFO, message)
	
	func warn(message: String) -> void:
		_log(LogLevel.WARN, message)
	
	func error(message: String) -> void:
		_log(LogLevel.ERROR, message)
	
	func fatal(message: String) -> void:
		_log(LogLevel.FATAL, message)
	
	func log(level: LogLevel, message: String) -> void:
		_log(level, message)
	
	func _log(level: LogLevel, message: String) -> void:
		# Check if this log level should be processed
		if not _is_level_enabled(level):
			return
		
		var formatted_message = parent_logger._format_message(name, level, message)
		parent_logger._output_log(level, formatted_message)

func _ready():
	_main_logger = LoggerInstance.new("Main", global_log_level, self)
	
	# Create log file if file logging is enabled
	if enable_file_logging:
		_ensure_log_file()

func _ensure_log_file():
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.store_line("=== Logger Session Started: " + Time.get_datetime_string_from_system() + " ===")
		file.close()

func _format_message(logger_name: String, level: LogLevel, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		var time = Time.get_datetime_dict_from_system()
		var timestamp = "%02d:%02d:%02d.%03d" % [time.hour, time.minute, time.second, Time.get_ticks_msec() % 1000]
		parts.append("[" + timestamp + "]")
	
	# Add log level
	parts.append("[" + LOG_LEVEL_NAMES[level] + "]")
	
	# Add logger name if not main
	if logger_name != "Main":
		parts.append("[" + logger_name + "]")
	
	# Add the actual message
	parts.append(message)
	
	return " ".join(parts)

func _output_log(level: LogLevel, formatted_message: String) -> void:
	# Console output with colors
	if enable_colors and LOG_COLORS.has(level):
		print_rich("[color=" + LOG_COLORS[level].to_html() + "]" + formatted_message + "[/color]")
	else:
		print(formatted_message)
	
	# File output if enabled
	if enable_file_logging:
		_write_to_file(formatted_message)

func _write_to_file(message: String) -> void:
	var file = FileAccess.open(log_file_path, FileAccess.WRITE)
	if file:
		file.seek_end()
		file.store_line(message)
		file.close()

# Global logger methods (shortcuts for main logger)
func trace(message: String) -> void:
	_main_logger.trace(message)

func debug(message: String) -> void:
	_main_logger.debug(message)

func info(message: String) -> void:
	_main_logger.info(message)

func warn(message: String) -> void:
	_main_logger.warn(message)

func error(message: String) -> void:
	_main_logger.error(message)

func fatal(message: String) -> void:
	_main_logger.fatal(message)

func log(level: LogLevel, message: String) -> void:
	_main_logger.log(level, message)

# Global log level checking functions
func is_trace_enabled() -> bool:
	return _main_logger.is_trace_enabled()

func is_debug_enabled() -> bool:
	return _main_logger.is_debug_enabled()

func is_info_enabled() -> bool:
	return _main_logger.is_info_enabled()

func is_warn_enabled() -> bool:
	return _main_logger.is_warn_enabled()

func is_error_enabled() -> bool:
	return _main_logger.is_error_enabled()

func is_fatal_enabled() -> bool:
	return _main_logger.is_fatal_enabled()

func is_level_enabled(level: LogLevel) -> bool:
	return _main_logger.is_level_enabled(level)

# Named logger management
func get_logger(logger_name: String, level: LogLevel = global_log_level) -> LoggerInstance:
	if not named_loggers.has(logger_name):
		named_loggers[logger_name] = LoggerInstance.new(logger_name, level, self)
	return named_loggers[logger_name]

func remove_logger(logger_name: String) -> bool:
	if named_loggers.has(logger_name):
		named_loggers.erase(logger_name)
		return true
	return false

func list_loggers() -> Array[String]:
	var logger_names: Array[String] = []
	for key in named_loggers.keys():
		logger_names.append(key)
	return logger_names

# Configuration methods
func set_global_level(level: LogLevel) -> void:
	global_log_level = level
	_main_logger.set_level(level)

func get_global_level() -> LogLevel:
	return global_log_level

func set_colors_enabled(enabled: bool) -> void:
	enable_colors = enabled

func set_timestamps_enabled(enabled: bool) -> void:
	enable_timestamps = enabled

func set_file_logging_enabled(enabled: bool, file_path: String = log_file_path) -> void:
	enable_file_logging = enabled
	if enabled and file_path != log_file_path:
		log_file_path = file_path
		_ensure_log_file()

func clear_log_file() -> void:
	if enable_file_logging:
		var file = FileAccess.open(log_file_path, FileAccess.WRITE)
		if file:
			file.store_line("=== Log Cleared: " + Time.get_datetime_string_from_system() + " ===")
			file.close()

# Utility methods
func log_level_from_string(level_string: String) -> LogLevel:
	match level_string.to_upper():
		"TRACE":
			return LogLevel.TRACE
		"DEBUG":
			return LogLevel.DEBUG
		"INFO":
			return LogLevel.INFO
		"WARN", "WARNING":
			return LogLevel.WARN
		"ERROR":
			return LogLevel.ERROR
		"FATAL":
			return LogLevel.FATAL
		_:
			return LogLevel.INFO

func log_level_to_string(level: LogLevel) -> String:
	return LOG_LEVEL_NAMES.get(level, "UNKNOWN")
