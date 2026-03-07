## Main Logger Node - Public API with theming support.
##
## This is the primary interface for the Log4Godot logging system.
## It is designed to be used as an autoload singleton (Log4g) and provides
## methods for configuration, logger management, and theme customization.
## [br][br]
## Example usage:
## [codeblock]
## # Configure global settings
## Log4g.set_global_level(LogLevel.Level.DEBUG)
## Log4g.set_file_logging_enabled(true, "user://game.log")
##
## # Create and use named loggers
## var network_logger = Log4g.get_logger("Network")
## network_logger.info("Connected to server")
## [/codeblock]
@icon("res://addons/log4godot/icons/logger.svg")
class_name GlobalLogger
extends Node

## The internal manager that handles all logging operations.
var manager: LoggerManager

## Called when the node enters the scene tree.
## Initializes the logger manager instance.
func _ready() -> void:
	manager = LoggerManager.new()

## Sets the global minimum log level for all loggers.
## Messages below this level will be filtered out regardless of individual logger settings.
## [br][br]
## [param level]: The new global minimum [enum LogLevel.Level].
func set_global_level(level: LogLevel.Level) -> void:
	manager.set_global_level(level)

## Gets the current global minimum log level.
## [br][br]
## Returns the current global [enum LogLevel.Level].
func get_global_level() -> LogLevel.Level:
	return manager.get_global_level()

## Enables or disables colored console output for all loggers.
## [br][br]
## [param enabled]: If [code]true[/code], console output will use BBCode colors via [method print_rich].
func set_colors_enabled(enabled: bool) -> void:
	manager.set_colors_enabled(enabled)

## Enables or disables timestamp inclusion in log messages.
## [br][br]
## [param enabled]: If [code]true[/code], timestamps will be prepended to all log messages.
func set_timestamps_enabled(enabled: bool) -> void:
	manager.set_timestamps_enabled(enabled)

## Returns whether timestamps are currently enabled.
## [br][br]
## Returns [code]true[/code] if timestamps are being included in log messages.
func get_timestamps_enabled() -> bool:
	return manager.get_timestamps_enabled()

## Enables or disables file logging and optionally sets the file path.
## [br][br]
## [param enabled]: If [code]true[/code], log messages will be written to a file.
## [param file_path]: The path for the log file. Defaults to "user://game.log".
func set_file_logging_enabled(enabled: bool, file_path: String = "user://game.log") -> void:
	manager.set_file_logging_enabled(enabled, file_path)

## Clears the log file content and writes a "Log Cleared" header.
func clear_log_file() -> void:
	manager.clear_log_file()

#region Theme management methods

## Sets the active theme for log message colorization.
## [br][br]
## [param theme]: The [LogTheme] resource to use for color configuration.
func set_theme(theme: LogTheme) -> void:
	manager.set_theme(theme)

## Sets the active theme by its registered name.
## Available built-in themes: "Default", "Minimal", "Whiteout", "Fallout".
## [br][br]
## [param theme_name]: The name of a registered theme.
## [br][br]
## Returns [code]true[/code] if the theme was found and set, [code]false[/code] otherwise.
func set_theme_by_name(theme_name: String) -> bool:
	return manager.set_theme_by_name(theme_name)

## Gets the currently active theme.
## [br][br]
## Returns the current [LogTheme] being used for message formatting.
func get_current_theme() -> LogTheme:
	return manager.get_current_theme()

## Registers a custom theme for later use.
## [br][br]
## [param theme_name]: The name to register the theme under.
## [param theme]: The [LogTheme] resource to register.
func add_custom_theme(theme_name: String, theme: LogTheme) -> void:
	manager.add_custom_theme(theme_name, theme)

## Gets a list of all available theme names (built-in and custom).
## [br][br]
## Returns an [Array] of [String] containing all registered theme names.
func get_available_themes() -> Array[String]:
	return manager.get_available_themes()

## Gets a theme by its registered name.
## [br][br]
## [param theme_name]: The name of the theme to retrieve.
## [br][br]
## Returns the [LogTheme] if found, or [code]null[/code] if not registered.
func get_theme_by_name(theme_name: String) -> LogTheme:
	return manager.get_theme_by_name(theme_name)

#endregion

## Gets or creates a named logger instance.
## If a logger with the given name already exists, returns the existing instance.
## Otherwise, creates a new logger with the specified level.
## [br][br]
## [param logger_name]: The unique name for the logger (e.g., "Network", "AI", "Physics").
## [param level]: The initial log level for new loggers. Defaults to INFO.
## [br][br]
## Returns the [LoggerInstance] for the specified name.
## [br][br]
## Example:
## [codeblock]
## var ai_logger = Log4g.get_logger("AI", LogLevel.Level.DEBUG)
## ai_logger.debug("AI state: " + state_name)
## [/codeblock]
func get_logger(logger_name: String, level: LogLevel.Level = LogLevel.Level.INFO) -> LoggerInstance:
	return manager.get_logger(logger_name, level)

## Creates or retrieves a logger using the name derived from the given object.
## The logger name is determined in the following priority:
## 1. The class_name if defined in the script
## 2. The script filename (without extension) if no class_name
## 3. The Godot base class name if no script is attached
## [br][br]
## Example usage:
## [codeblock]
## class_name Player
## extends CharacterBody2D
##
## var logger: LoggerInstance
##
## func _ready():
##     logger = Log4g.get_logger_for(self)  # Creates logger named "Player"
##     logger.info("Player initialized")
## [/codeblock]
func get_logger_for(object: Object, level: LogLevel.Level = LogLevel.Level.INFO) -> LoggerInstance:
	var logger_name: String = LoggerNameResolver.derive_logger_name(object)
	return manager.get_logger(logger_name, level)

## Removes a named logger from the manager.
## [br][br]
## [param logger_name]: The name of the logger to remove.
## [br][br]
## Returns [code]true[/code] if the logger was found and removed, [code]false[/code] otherwise.
func remove_logger(logger_name: String) -> bool:
	return manager.remove_logger(logger_name)

## Gets a list of all registered logger names.
## [br][br]
## Returns an [Array] of [String] containing all logger names currently registered.
func list_loggers() -> Array[String]:
	return manager.list_loggers()

## Converts a string representation of a log level to its enum value.
## Provided for backwards compatibility and convenience.
## [br][br]
## [param level_string]: The string to convert (e.g., "DEBUG", "ERROR").
## [br][br]
## Returns the corresponding [enum LogLevel.Level] value.
func log_level_from_string(level_string: String) -> LogLevel.Level:
	return LogLevel.from_string(level_string)

## Converts a log level enum value to its string representation.
## Provided for backwards compatibility and convenience.
## [br][br]
## [param level]: The [enum LogLevel.Level] value to convert.
## [br][br]
## Returns the string name of the level.
func log_level_to_string(level: LogLevel.Level) -> String:
	return LogLevel.level_to_string(level)
