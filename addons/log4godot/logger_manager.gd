## Manages multiple loggers and global configuration with theming support.
##
## This class serves as the central manager for all logging operations.
## It handles the creation and retrieval of named loggers, maintains global
## configuration settings, and manages the collection of available themes.
class_name LoggerManager

## The global minimum log level applied to all loggers.
## Individual loggers can have their own levels, but messages must meet
## or exceed this global level to be output.
var global_log_level: LogLevel.Level = LogLevel.Level.INFO

## The shared output handler used by all managed loggers.
var output: LogOutput

## Dictionary of named logger instances, keyed by their string names.
var named_loggers: Dictionary[String, LoggerInstance] = {}

## Dictionary of available themes, keyed by their string names.
## Includes both built-in themes and any custom themes added at runtime.
var available_themes: Dictionary[String, LogTheme] = {}

## Initializes the manager with default themes and output configuration.
func _init() -> void:
	_initialize_default_themes()
	output = LogOutput.new()
	output.set_theme(available_themes["Default"])

## Loads the default built-in themes into the available themes dictionary.
func _initialize_default_themes() -> void:
	available_themes.merge(LogTheme.default_themes)

## Returns the current global log level.
## Used internally as the global level provider for logger instances.
## [br][br]
## Returns the current global [enum LogLevel.Level].
func _get_global_level() -> LogLevel.Level:
	return global_log_level

## Sets the global minimum log level for all loggers.
## Messages below this level will be filtered out regardless of individual logger settings.
## [br][br]
## [param level]: The new global minimum [enum LogLevel.Level].
func set_global_level(level: LogLevel.Level) -> void:
	global_log_level = level

## Gets the current global minimum log level.
## [br][br]
## Returns the current global [enum LogLevel.Level].
func get_global_level() -> LogLevel.Level:
	return global_log_level

## Enables or disables colored console output for all loggers.
## [br][br]
## [param enabled]: If [code]true[/code], console output will use BBCode colors.
func set_colors_enabled(enabled: bool) -> void:
	output.set_colors_enabled(enabled)

## Enables or disables timestamp inclusion in log messages for all loggers.
## [br][br]
## [param enabled]: If [code]true[/code], timestamps will be prepended to all log messages.
func set_timestamps_enabled(enabled: bool) -> void:
	output.set_timestamps_enabled(enabled)

## Returns whether timestamps are currently enabled.
## [br][br]
## Returns [code]true[/code] if timestamps are being included in log messages.
func get_timestamps_enabled() -> bool:
	return output.get_timestamps_enabled()

## Enables or disables file logging and optionally sets the file path.
## [br][br]
## [param enabled]: If [code]true[/code], log messages will be written to a file.
## [param file_path]: Optional path for the log file. If empty, uses the existing path.
func set_file_logging_enabled(enabled: bool, file_path: String = "") -> void:
	output.set_file_logging_enabled(enabled, file_path)

## Clears the log file content.
func clear_log_file() -> void:
	output.clear_log_file()

#region Theme management methods

## Sets the active theme for log message colorization.
## [br][br]
## [param theme]: The [LogTheme] resource to use for color configuration.
func set_theme(theme: LogTheme) -> void:
	output.set_theme(theme)

## Sets the active theme by its registered name.
## [br][br]
## [param theme_name]: The name of a registered theme (e.g., "Default", "Minimal").
## [br][br]
## Returns [code]true[/code] if the theme was found and set, [code]false[/code] otherwise.
func set_theme_by_name(theme_name: String) -> bool:
	if available_themes.has(theme_name):
		output.set_theme(available_themes[theme_name])
		return true
	return false

## Gets the currently active theme.
## [br][br]
## Returns the current [LogTheme] being used for message formatting.
func get_current_theme() -> LogTheme:
	return output.get_theme()

## Registers a custom theme for later use.
## [br][br]
## [param theme_name]: The name to register the theme under.
## [param theme]: The [LogTheme] resource to register.
func add_custom_theme(theme_name: String, theme: LogTheme) -> void:
	available_themes[theme_name] = theme

## Gets a list of all available theme names.
## [br][br]
## Returns an [Array] of [String] containing all registered theme names.
func get_available_themes() -> Array[String]:
	var theme_names: Array[String] = []
	for key: String in available_themes.keys():
		theme_names.append(key)
	return theme_names

## Gets a theme by its registered name.
## [br][br]
## [param theme_name]: The name of the theme to retrieve.
## [br][br]
## Returns the [LogTheme] if found, or [code]null[/code] if not registered.
func get_theme_by_name(theme_name: String) -> LogTheme:
	return available_themes.get(theme_name)

#endregion

## Gets or creates a named logger instance.
## If a logger with the given name already exists, returns the existing instance.
## Otherwise, creates a new logger with the specified level.
## [br][br]
## [param logger_name]: The unique name for the logger (e.g., "Network", "AI", "Physics").
## [param level]: The initial log level for new loggers. Defaults to the current global level.
## [br][br]
## Returns the [LoggerInstance] for the specified name.
func get_logger(logger_name: String, level: LogLevel.Level = global_log_level) -> LoggerInstance:
	if not named_loggers.has(logger_name):
		named_loggers[logger_name] = LoggerInstance.new(logger_name, level, output, _get_global_level)
	return named_loggers[logger_name]

## Removes a named logger from the manager.
## [br][br]
## [param logger_name]: The name of the logger to remove.
## [br][br]
## Returns [code]true[/code] if the logger was found and removed, [code]false[/code] otherwise.
func remove_logger(logger_name: String) -> bool:
	if named_loggers.has(logger_name):
		named_loggers.erase(logger_name)
		return true
	return false

## Gets a list of all registered logger names.
## [br][br]
## Returns an [Array] of [String] containing all logger names.
func list_loggers() -> Array[String]:
	var logger_names: Array[String] = []
	for key: String in named_loggers.keys():
		logger_names.append(key)
	return logger_names
