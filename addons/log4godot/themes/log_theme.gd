## Resource class for log theming configuration.
##
## This resource defines the color scheme used for formatting log messages.
## Each log level can have its own color, and additional colors are provided
## for timestamps and other formatting elements.
## [br][br]
## Log4Godot includes several built-in themes:
## [br]- [b]Default[/b]: Balanced color scheme with distinct colors for each level
## [br]- [b]Minimal[/b]: Muted gray for most levels, red for errors
## [br]- [b]Whiteout[/b]: All white for high contrast displays
## [br]- [b]Fallout[/b]: Retro green terminal aesthetic
## [br][br]
## Example creating a custom theme:
## [codeblock]
## var custom_theme = LogTheme.new()
## custom_theme.theme_name = "MyTheme"
## custom_theme.error_color = Color.MAGENTA
## Log4g.add_custom_theme("MyTheme", custom_theme)
## [/codeblock]
@icon("res://addons/log4godot/icons/log_theme.svg")
class_name LogTheme
extends Resource

## Color used for TRACE level messages.
## TRACE is the most verbose level, used for fine-grained debugging.
@export var trace_color: Color = Color(0.804, 0.812, 0.824)

## Color used for DEBUG level messages.
## DEBUG is used for information useful during development.
@export var debug_color: Color = Color(0.872, 1.0, 0.997)

## Color used for INFO level messages.
## INFO is used for general informational messages.
@export var info_color: Color = Color(0.804, 0.812, 0.824)

## Color used for WARN level messages.
## WARN is used for potentially harmful situations.
@export var warn_color: Color = Color(1.0, 1.0, 0.0)

## Color used for ERROR level messages.
## ERROR is used for error events that might still allow continuation.
@export var error_color: Color = Color(1.0, 0.0, 0.0)

## Color used for FATAL level messages.
## FATAL is used for critical errors that will likely cause abort.
@export var fatal_color: Color = Color(1.0, 0.0, 0.0)

## Color used for timestamp text in log messages.
@export var timestamp_color: Color = Color(0.804, 0.812, 0.824)

## The display name of this theme.
## Used for identification when listing or selecting themes.
@export var theme_name: StringName = &"Default"

## Dictionary of built-in default themes.
## Loaded from resource files in the themes directory.
## Available themes: "Default", "Minimal", "Whiteout", "Fallout"
static var default_themes: Dictionary[StringName, LogTheme] = {
	&"Default" : ResourceLoader.load("res://addons/log4godot/themes/default_log_theme.tres"),
	&"Minimal" : ResourceLoader.load("res://addons/log4godot/themes/minimal_log_theme.tres"),
	&"Whiteout" : ResourceLoader.load("res://addons/log4godot/themes/whiteout_log_theme.tres"),
	&"Fallout" : ResourceLoader.load("res://addons/log4godot/themes/fallout_log_theme.tres")
}

## Gets the color associated with a specific log level.
## [br][br]
## [param level]: The [enum LogLevel.Level] to get the color for.
## [br][br]
## Returns the [Color] configured for the specified level,
## or [constant Color.WHITE] if the level is not recognized.
func get_color_for_level(level: LogLevel.Level) -> Color:
	match level:
		LogLevel.Level.TRACE:
			return trace_color
		LogLevel.Level.DEBUG:
			return debug_color
		LogLevel.Level.INFO:
			return info_color
		LogLevel.Level.WARN:
			return warn_color
		LogLevel.Level.ERROR:
			return error_color
		LogLevel.Level.FATAL:
			return fatal_color
		_:
			return Color.WHITE
