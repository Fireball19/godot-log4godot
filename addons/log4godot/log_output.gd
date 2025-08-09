# LogOutput.gd
# Manages output destinations and formatting
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

func output_log(logger_name: String, level: LogLevel.Level, message: String) -> void:
	var formatted_message = formatter.format_message(logger_name, level, message)
	
	# Console output
	_output_to_console(level, formatted_message)
	
	# File output
	file_handler.write_log(formatted_message)

func clear_log_file() -> void:
	file_handler.clear_log()

func _output_to_console(level: LogLevel.Level, formatted_message: String) -> void:
	if enable_colors:
		var color = LogLevel.get_color(level)
		print_rich("[color=" + color.to_html() + "]" + formatted_message + "[/color]")
	else:
		print(formatted_message)
