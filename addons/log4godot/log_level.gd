## Handles log level definitions and conversions.
##
## This class provides an enumeration of all available log levels and utility
## methods for converting between log levels and their string representations.
## Log levels are ordered by severity from TRACE (lowest) to FATAL (highest).
class_name LogLevel

## Enumeration of available log levels ordered by severity.
## Lower values represent less severe/more verbose logging.
enum Level {
	## Most detailed logging level. Used for fine-grained debugging information.
	TRACE = 0,
	## Debug-level messages useful during development.
	DEBUG = 1,
	## Informational messages that highlight progress of the application.
	INFO = 2,
	## Warning messages for potentially harmful situations.
	WARN = 3,
	## Error messages for error events that might still allow the application to continue.
	ERROR = 4,
	## Critical errors that will likely cause the application to abort.
	FATAL = 5
}

## Dictionary mapping log levels to their string representations.
const LEVEL_NAMES: Dictionary[LogLevel.Level, StringName] = {
	Level.TRACE: &"TRACE",
	Level.DEBUG: &"DEBUG",
	Level.INFO: &"INFO",
	Level.WARN: &"WARN",
	Level.ERROR: &"ERROR",
	Level.FATAL: &"FATAL"
}

## Dictionary mapping log levels to their default display colors.
const LEVEL_COLORS: Dictionary[LogLevel.Level, Color] = {
	Level.TRACE: Color.WHITE,
	Level.DEBUG: Color.CYAN,
	Level.INFO: Color.GREEN,
	Level.WARN: Color.YELLOW,
	Level.ERROR: Color.ORANGE_RED,
	Level.FATAL: Color.RED
}

## Converts a string representation of a log level to its enum value.
## Case-insensitive matching is performed.
## [br][br]
## [param level_string]: The string to convert (e.g., "DEBUG", "debug", "Warning").
## [br][br]
## Returns the corresponding [enum Level] value, or [constant Level.INFO] if not recognized.
static func from_string(level_string: StringName) -> Level:
	match level_string.to_upper():
		"TRACE":
			return Level.TRACE
		"DEBUG":
			return Level.DEBUG
		"INFO":
			return Level.INFO
		"WARN", "WARNING":
			return Level.WARN
		"ERROR":
			return Level.ERROR
		"FATAL":
			return Level.FATAL
		_:
			return Level.INFO

## Converts a log level enum value to its string representation.
## [br][br]
## [param level]: The [enum Level] value to convert.
## [br][br]
## Returns the string name of the level, or "UNKNOWN" if not found.
static func level_to_string(level: Level) -> String:
	return LEVEL_NAMES.get(level, "UNKNOWN")

## Gets the default color associated with a log level.
## [br][br]
## [param level]: The [enum Level] to get the color for.
## [br][br]
## Returns the [Color] associated with the level, or [constant Color.WHITE] if not found.
static func get_color(level: Level) -> Color:
	return LEVEL_COLORS.get(level, Color.WHITE)
