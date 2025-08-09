# LoggerInstance.gd
# Individual logger behavior
class_name LoggerInstance

var name: String
var log_level: LogLevel.Level
var output: LogOutput
var global_level_provider: Callable

func _init(logger_name: String, level: LogLevel.Level, log_output: LogOutput, global_provider: Callable):
	name = logger_name
	log_level = level
	output = log_output
	global_level_provider = global_provider

func set_level(level: LogLevel.Level) -> void:
	log_level = level

func get_level() -> LogLevel.Level:
	return log_level

# Log level checking functions
func is_trace_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.TRACE)

func is_debug_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.DEBUG)

func is_info_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.INFO)

func is_warn_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.WARN)

func is_error_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.ERROR)

func is_fatal_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.FATAL)

func is_level_enabled(level: LogLevel.Level) -> bool:
	return _is_level_enabled(level)

func _is_level_enabled(level: LogLevel.Level) -> bool:
	var global_level = global_level_provider.call()
	return level >= log_level and level >= global_level

# Logging functions
func trace(message: String) -> void:
	_log(LogLevel.Level.TRACE, message)

func debug(message: String) -> void:
	_log(LogLevel.Level.DEBUG, message)

func info(message: String) -> void:
	_log(LogLevel.Level.INFO, message)

func warn(message: String) -> void:
	_log(LogLevel.Level.WARN, message)

func error(message: String) -> void:
	_log(LogLevel.Level.ERROR, message)

func fatal(message: String) -> void:
	_log(LogLevel.Level.FATAL, message)

func log(level: LogLevel.Level, message: String) -> void:
	_log(level, message)

func _log(level: LogLevel.Level, message: String) -> void:
	if not _is_level_enabled(level):
		return
	
	output.output_log(name, level, message)
