# LogLevel.gd
# Handles log level definitions and conversions
class_name LogLevel

enum Level {
	TRACE = 0,
	DEBUG = 1,
	INFO = 2,
	WARN = 3,
	ERROR = 4,
	FATAL = 5
}

const LEVEL_NAMES = {
	Level.TRACE: "TRACE",
	Level.DEBUG: "DEBUG",
	Level.INFO: "INFO",
	Level.WARN: "WARN",
	Level.ERROR: "ERROR",
	Level.FATAL: "FATAL"
}

const LEVEL_COLORS = {
	Level.TRACE: Color.WHITE,
	Level.DEBUG: Color.CYAN,
	Level.INFO: Color.GREEN,
	Level.WARN: Color.YELLOW,
	Level.ERROR: Color.ORANGE_RED,
	Level.FATAL: Color.RED
}

static func from_string(level_string: String) -> Level:
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

static func level_to_string(level: Level) -> String:
	return LEVEL_NAMES.get(level, "UNKNOWN")

static func get_color(level: Level) -> Color:
	return LEVEL_COLORS.get(level, Color.WHITE)
