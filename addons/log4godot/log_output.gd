# LogOutput.gd
# Manages output destinations and formatting with theming support
class_name LogOutput

var enable_colors: bool = true
var formatter: LogFormatter
var file_handler: FileLogHandler

func _init():
	formatter = LogFormatter.new()
	file_handler = FileLogHandler.new()

func set_colors_enabled(enabled: bool) -> void:
	enable_colors = enabled

func set_timestamps_enabled(enabled: bool) -> void:
	formatter.set_timestamps_enabled(enabled)

func set_file_logging_enabled(enabled: bool, file_path: String = "") -> void:
	if file_path != "":
		file_handler.set_file_path(file_path)
	file_handler.set_enabled(enabled)

func set_theme(theme: LogTheme) -> void:
	formatter.set_theme(theme)

func get_theme() -> LogTheme:
	return formatter.get_theme()

func output_log(logger_name: String, level: LogLevel.Level, message: String) -> void:
	# Console output (with colors if enabled)
	_output_to_console(logger_name, level, message)
	
	# File output (plain text without colors)
	var plain_message = formatter.format_message(logger_name, level, message)
	file_handler.write_log(plain_message)

func clear_log_file() -> void:
	file_handler.clear_log_file()

func _output_to_console(logger_name: String, level: LogLevel.Level, message: String) -> void:
	if enable_colors:
		var colored_message = formatter.format_message_with_colors(logger_name, level, message)
		print_rich(colored_message)
	else:
		var plain_message = formatter.format_message(logger_name, level, message)
		print(plain_message)
