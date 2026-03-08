## Handles message formatting logic with theming support.
##
## This class is responsible for formatting log messages with optional timestamps,
## log level indicators, logger names, and color coding based on the current theme.
## It supports both plain text and BBCode-colored output for rich console display.
class_name LogFormatter

## Whether timestamps should be included in formatted messages.
var enable_timestamps: bool = true

## Format string for timestamps using printf-style formatting.
## Default format: [HH:MM:SS.mmm]
var timestamp_format: String = "[%02d:%02d:%02d.%03d]"

## The current theme used for colorizing log messages.
var current_theme: LogTheme

## Initializes the formatter with the default theme.
func _init() -> void:
	current_theme = LogTheme.default_themes[&"Default"]

## Enables or disables timestamp inclusion in formatted messages.
## [br][br]
## [param enabled]: If [code]true[/code], timestamps will be prepended to messages.
func set_timestamps_enabled(enabled: bool) -> void:
	enable_timestamps = enabled

## Returns whether timestamps are currently enabled.
## [br][br]
## Returns [code]true[/code] if timestamps are being included in formatted messages.
func get_timestamps_enabled() -> bool:
	return enable_timestamps

## Sets the theme used for colorizing log messages.
## [br][br]
## [param theme]: The [LogTheme] resource to use for color configuration.
func set_theme(theme: LogTheme) -> void:
	current_theme = theme

## Gets the currently active theme.
## [br][br]
## Returns the current [LogTheme] being used for formatting.
func get_theme() -> LogTheme:
	return current_theme

## Formats a log message as plain text without color codes.
## [br][br]
## [param logger_name]: The name of the logger producing the message.
## [param level]: The [enum LogLevel.Level] of the message.
## [param message]: The actual log message content.
## [br][br]
## Returns a formatted string in the format: [timestamp] [LEVEL] [LoggerName] message
func format_message(logger_name: StringName, level: LogLevel.Level, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		parts.append(_format_timestamp())
	
	# Add log level
	parts.append("[" + LogLevel.level_to_string(level) + "]")
	
	# Add logger name
	parts.append("[" + logger_name + "]")
	
	# Add the actual message
	parts.append(message)
	
	return " ".join(parts)

## Formats a log message with BBCode color tags for rich console output.
## [br][br]
## [param logger_name]: The name of the logger producing the message.
## [param level]: The [enum LogLevel.Level] of the message.
## [param message]: The actual log message content.
## [br][br]
## Returns a BBCode-formatted string with colors applied based on the current theme.
## [br]Use with [method print_rich] for colored console output.
func format_message_with_colors(logger_name: StringName, level: LogLevel.Level, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		var timestamp: String = _format_timestamp()
		parts.append(_colorize(timestamp, current_theme.timestamp_color))
	
	# Add log level with styling
	var level_str: String = "[" + LogLevel.level_to_string(level) + "]"
	parts.append(_colorize(level_str, current_theme.get_color_for_level(level)))
	
	# Add logger name
	var logger_str: String = "[" + logger_name + "]"
	parts.append(_colorize(logger_str, current_theme.get_color_for_level(level)))
	
	# Add the actual message with level-specific color
	parts.append(_colorize(message, current_theme.get_color_for_level(level)))
	
	return " ".join(parts)

## Generates a formatted timestamp string using the current system time.
## [br][br]
## Returns a timestamp in the format specified by [member timestamp_format].
func _format_timestamp() -> String:
	var time: Dictionary = Time.get_datetime_dict_from_system()
	return timestamp_format % [time.hour, time.minute, time.second, Time.get_ticks_msec() % 1000]

## Wraps text in BBCode color tags.
## [br][br]
## [param text]: The text to colorize.
## [param color]: The [Color] to apply.
## [br][br]
## Returns the text wrapped in BBCode color tags.
func _colorize(text: String, color: Color) -> String:
	return "[color=" + color.to_html() + "]" + text + "[/color]"
