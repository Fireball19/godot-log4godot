## Manages output destinations and formatting with theming support.
##
## This class coordinates between the formatter and file handler to produce
## log output to both the console and optionally to a file. It handles
## colored console output using BBCode and plain text file output.
## It also emits signals for editor panel integration.
class_name LogOutput

## Emitted when a log message is output. Used by the editor panel.
## [br][br]
## [param timestamp]: The formatted timestamp string.
## [param logger_name]: The name of the logger that produced the message.
## [param level]: The log level of the message.
## [param message]: The actual log message content.
signal log_emitted(timestamp: String, logger_name: StringName, level: LogLevel.Level, message: String)

## Whether colored output is enabled for console logging.
## When enabled, uses BBCode formatting with [method print_rich].
var enable_colors: bool = true

## The formatter instance responsible for creating formatted log messages.
var formatter: LogFormatter

## The file handler instance responsible for file-based logging.
var file_handler: FileLogHandler

## Initializes the output manager with default formatter and file handler instances.
func _init() -> void:
	formatter = LogFormatter.new()
	file_handler = FileLogHandler.new()

## Enables or disables colored console output.
## [br][br]
## [param enabled]: If [code]true[/code], console output will use BBCode colors via [method print_rich].
## If [code]false[/code], plain text output via [method print] is used.
func set_colors_enabled(enabled: bool) -> void:
	enable_colors = enabled

## Enables or disables timestamp inclusion in log messages.
## [br][br]
## [param enabled]: If [code]true[/code], timestamps will be prepended to all log messages.
func set_timestamps_enabled(enabled: bool) -> void:
	formatter.set_timestamps_enabled(enabled)

## Returns whether timestamps are currently enabled.
## [br][br]
## Returns [code]true[/code] if timestamps are being included in log messages.
func get_timestamps_enabled() -> bool:
	return formatter.get_timestamps_enabled()

## Enables or disables file logging and optionally sets the file path.
## [br][br]
## [param enabled]: If [code]true[/code], log messages will be written to a file.
## [param file_path]: Optional path for the log file. If empty, uses the existing path.
func set_file_logging_enabled(enabled: bool, file_path: String = "") -> void:
	if file_path != "":
		file_handler.set_file_path(file_path)
	file_handler.set_enabled(enabled)

## Sets the theme used for colorizing log messages.
## [br][br]
## [param theme]: The [LogTheme] resource to use for color configuration.
func set_theme(theme: LogTheme) -> void:
	formatter.set_theme(theme)

## Gets the currently active theme.
## [br][br]
## Returns the current [LogTheme] being used for formatting.
func get_theme() -> LogTheme:
	return formatter.get_theme()

## Outputs a log message to all configured destinations.
## Sends colored output to the console (if colors enabled) and plain text to file (if enabled).
## Also sends to the editor via EngineDebugger for the Log4Godot panel.
## [br][br]
## [param logger_name]: The name of the logger producing the message.
## [param level]: The [enum LogLevel.Level] of the message.
## [param message]: The actual log message content.
func output_log(logger_name: StringName, level: LogLevel.Level, message: String) -> void:
	# Get timestamp from formatter (single source of truth)
	var timestamp: String = formatter.get_timestamp()
	
	# Emit signal for editor panel (works when in same process)
	log_emitted.emit(timestamp, logger_name, level, message)
	
	# Send to editor via EngineDebugger (the proper way to communicate with editor)
	# This uses the same mechanism as Godot's built-in Output panel
	if EngineDebugger.is_active():
		EngineDebugger.send_message("log4godot:log_entry", [timestamp, String(logger_name), level, message])
	
	# Console output (with colors if enabled)
	_output_to_console(logger_name, level, message)
	
	# File output (plain text without colors)
	var plain_message: String = formatter.format_message(logger_name, level, message)
	file_handler.write_log(plain_message)

## Clears the log file content.
## Delegates to the file handler's clear functionality.
func clear_log_file() -> void:
	file_handler.clear_log_file()

## Outputs a formatted log message to the console.
## Uses colored output via [method print_rich] if colors are enabled,
## otherwise uses plain [method print].
## [br][br]
## [param logger_name]: The name of the logger producing the message.
## [param level]: The [enum LogLevel.Level] of the message.
## [param message]: The actual log message content.
func _output_to_console(logger_name: StringName, level: LogLevel.Level, message: String) -> void:
	if enable_colors:
		var colored_message: String = formatter.format_message_with_colors(logger_name, level, message)
		print_rich(colored_message)
	else:
		var plain_message: String = formatter.format_message(logger_name, level, message)
		print(plain_message)
