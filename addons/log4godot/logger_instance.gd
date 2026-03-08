## Individual logger behavior and configuration.
##
## This class represents a single named logger instance with its own log level
## configuration. It provides convenience methods for logging at each level
## and respects both its own level and the global level for filtering.
## [br][br]
## Example usage:
## [codeblock]
## var logger = Log4g.get_logger("Network", LogLevel.Level.DEBUG)
## logger.debug("Connection established")
## logger.error("Connection lost: " + error_message)
## [/codeblock]
class_name LoggerInstance

## The unique name identifying this logger instance.
## Used in formatted output to identify the source of log messages.
var name: StringName

## The minimum log level for this logger instance.
## Messages below this level will be filtered out (unless overridden by global level).
var log_level: LogLevel.Level

## The output handler used to write formatted log messages.
var output: LogOutput

## Callable that returns the current global log level.
## Used to ensure messages respect both instance and global filtering.
var global_level_provider: Callable

## Initializes a new logger instance with the specified configuration.
## [br][br]
## [param logger_name]: The unique name for this logger (e.g., "Network", "AI").
## [param level]: The initial minimum log level for this logger.
## [param log_output]: The [LogOutput] instance to use for message output.
## [param global_provider]: A [Callable] that returns the current global [enum LogLevel.Level].
func _init(logger_name: StringName, level: LogLevel.Level, log_output: LogOutput, global_provider: Callable) -> void:
	name = logger_name
	log_level = level
	output = log_output
	global_level_provider = global_provider

## Sets the minimum log level for this logger.
## Messages with a level below this will be filtered out.
## [br][br]
## [param level]: The new minimum [enum LogLevel.Level] for this logger.
func set_level(level: LogLevel.Level) -> void:
	log_level = level

## Gets the current minimum log level for this logger.
## [br][br]
## Returns the current [enum LogLevel.Level] setting.
func get_level() -> LogLevel.Level:
	return log_level

## Checks if TRACE level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if TRACE messages would be output.
func is_trace_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.TRACE)

## Checks if DEBUG level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if DEBUG messages would be output.
func is_debug_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.DEBUG)

## Checks if INFO level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if INFO messages would be output.
func is_info_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.INFO)

## Checks if WARN level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if WARN messages would be output.
func is_warn_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.WARN)

## Checks if ERROR level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if ERROR messages would be output.
func is_error_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.ERROR)

## Checks if FATAL level logging is enabled for this logger.
## [br][br]
## Returns [code]true[/code] if FATAL messages would be output.
func is_fatal_enabled() -> bool:
	return _is_level_enabled(LogLevel.Level.FATAL)

## Checks if a specific log level is enabled for this logger.
## [br][br]
## [param level]: The [enum LogLevel.Level] to check.
## [br][br]
## Returns [code]true[/code] if messages at the specified level would be output.
func is_level_enabled(level: LogLevel.Level) -> bool:
	return _is_level_enabled(level)

## Internal method to check if a level is enabled.
## A level is enabled if it meets or exceeds both the instance level and global level.
## [br][br]
## [param level]: The [enum LogLevel.Level] to check.
## [br][br]
## Returns [code]true[/code] if the level passes both instance and global filtering.
func _is_level_enabled(level: LogLevel.Level) -> bool:
	var global_level: LogLevel.Level = global_level_provider.call()
	return level >= log_level and level >= global_level

## Logs a message at TRACE level.
## TRACE is the most detailed logging level, used for fine-grained debugging.
## [br][br]
## [param message]: The message to log.
func trace(message: String) -> void:
	_log(LogLevel.Level.TRACE, message)

## Logs a message at DEBUG level.
## DEBUG is used for information useful during development and debugging.
## [br][br]
## [param message]: The message to log.
func debug(message: String) -> void:
	_log(LogLevel.Level.DEBUG, message)

## Logs a message at INFO level.
## INFO is used for general informational messages about application progress.
## [br][br]
## [param message]: The message to log.
func info(message: String) -> void:
	_log(LogLevel.Level.INFO, message)

## Logs a message at WARN level.
## WARN is used for potentially harmful situations that should be noted.
## [br][br]
## [param message]: The message to log.
func warn(message: String) -> void:
	_log(LogLevel.Level.WARN, message)

## Logs a message at ERROR level.
## ERROR is used for error events that might still allow the application to continue.
## [br][br]
## [param message]: The message to log.
func error(message: String) -> void:
	_log(LogLevel.Level.ERROR, message)

## Logs a message at FATAL level.
## FATAL is used for critical errors that will likely cause the application to abort.
## [br][br]
## [param message]: The message to log.
func fatal(message: String) -> void:
	_log(LogLevel.Level.FATAL, message)

## Logs a message at the specified level.
## This is the generic logging method that allows specifying any level.
## [br][br]
## [param level]: The [enum LogLevel.Level] for this message.
## [param message]: The message to log.
func log(level: LogLevel.Level, message: String) -> void:
	_log(level, message)

## Internal logging method that performs level filtering and outputs the message.
## [br][br]
## [param level]: The [enum LogLevel.Level] for this message.
## [param message]: The message to log.
func _log(level: LogLevel.Level, message: String) -> void:
	if not _is_level_enabled(level):
		return
	
	output.output_log(name, level, message)
