# LogFormatter.gd
# Handles message formatting logic with theming support
class_name LogFormatter

var enable_timestamps: bool = true
var timestamp_format: String = "[%02d:%02d:%02d.%03d]"
var current_theme: LogTheme

func _init():
	current_theme = LogTheme.default_themes["Default"]

func set_timestamps_enabled(enabled: bool) -> void:
	enable_timestamps = enabled

func set_theme(theme: LogTheme) -> void:
	current_theme = theme

func get_theme() -> LogTheme:
	return current_theme

func format_message(logger_name: String, level: LogLevel.Level, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		parts.append(_format_timestamp())
	
	# Add log level
	parts.append("[" + LogLevel.level_to_string(level) + "]")
	
	# Add logger name if not main
	if logger_name != "Main":
		parts.append("[" + logger_name + "]")
	
	# Add the actual message
	parts.append(message)
	
	return " ".join(parts)

func format_message_with_colors(logger_name: String, level: LogLevel.Level, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		var timestamp = _format_timestamp()
		parts.append(_colorize(timestamp, current_theme.timestamp_color))
	
	# Add log level with styling
	var level_str = "[" + LogLevel.level_to_string(level) + "]"
	parts.append(_colorize(level_str, current_theme.get_color_for_level(level)))
	
	# Add logger name if not main
	if logger_name != "Main":
		var logger_str = "[" + logger_name + "]"
		parts.append(_colorize(logger_str, current_theme.get_color_for_level(level)))
	
	# Add the actual message with level-specific color
	parts.append(_colorize(message, current_theme.get_color_for_level(level)))
	
	return " ".join(parts)

func _format_timestamp() -> String:
	var time = Time.get_datetime_dict_from_system()
	return timestamp_format % [time.hour, time.minute, time.second, Time.get_ticks_msec() % 1000]

func _colorize(text: String, color: Color) -> String:
	return "[color=" + color.to_html() + "]" + text + "[/color]"
