# LoggerManager.gd
# Manages multiple loggers and global configuration with theming support
class_name LoggerManager

var global_log_level: LogLevel.Level = LogLevel.Level.INFO
var output: LogOutput
var named_loggers: Dictionary = {}
var main_logger: LoggerInstance
var available_themes: Dictionary = {}

func _init():
	_initialize_default_themes()
	output = LogOutput.new()
	output.set_theme(available_themes["Default"])
	main_logger = LoggerInstance.new("Main", global_log_level, output, _get_global_level)
	
func _initialize_default_themes() -> void:
	available_themes.merge(LogTheme.default_themes)

func _get_global_level() -> LogLevel.Level:
	return global_log_level

# Configuration methods
func set_global_level(level: LogLevel.Level) -> void:
	global_log_level = level
	main_logger.set_level(level)

func get_global_level() -> LogLevel.Level:
	return global_log_level

func set_colors_enabled(enabled: bool) -> void:
	output.set_colors_enabled(enabled)

func set_timestamps_enabled(enabled: bool) -> void:
	output.set_timestamps_enabled(enabled)

func set_file_logging_enabled(enabled: bool, file_path: String = "") -> void:
	output.set_file_logging_enabled(enabled, file_path)

func clear_log_file() -> void:
	output.clear_log_file()

#region Theme management methods
func set_theme(theme: LogTheme) -> void:
	output.set_theme(theme)

func set_theme_by_name(theme_name: String) -> bool:
	if available_themes.has(theme_name):
		output.set_theme(available_themes[theme_name])
		return true
	return false

func get_current_theme() -> LogTheme:
	return output.get_theme()

func add_custom_theme(theme_name: String, theme: LogTheme) -> void:
	available_themes[theme_name] = theme

func get_available_themes() -> Array[String]:
	var theme_names: Array[String] = []
	for key in available_themes.keys():
		theme_names.append(key)
	return theme_names

func get_theme_by_name(theme_name: String) -> LogTheme:
	return available_themes.get(theme_name)
#endregion

# Logger management
func get_logger(logger_name: String, level: LogLevel.Level = global_log_level) -> LoggerInstance:
	if not named_loggers.has(logger_name):
		named_loggers[logger_name] = LoggerInstance.new(logger_name, level, output, _get_global_level)
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

func get_main_logger() -> LoggerInstance:
	return main_logger
