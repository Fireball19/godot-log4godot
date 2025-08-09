# test_log_level.gd
# Unit tests for LogLevel class
extends GutTest

func before_each():
	gut.p("Setting up LogLevel test")

func after_each():
	gut.p("Tearing down LogLevel test")

# Test enum values
func test_level_enum_values():
	assert_eq(LogLevel.Level.TRACE, 0, "TRACE should be 0")
	assert_eq(LogLevel.Level.DEBUG, 1, "DEBUG should be 1")
	assert_eq(LogLevel.Level.INFO, 2, "INFO should be 2")
	assert_eq(LogLevel.Level.WARN, 3, "WARN should be 3")
	assert_eq(LogLevel.Level.ERROR, 4, "ERROR should be 4")
	assert_eq(LogLevel.Level.FATAL, 5, "FATAL should be 5")

# Test from_string method
func test_from_string_valid_levels():
	assert_eq(LogLevel.from_string("TRACE"), LogLevel.Level.TRACE, "Should parse TRACE")
	assert_eq(LogLevel.from_string("DEBUG"), LogLevel.Level.DEBUG, "Should parse DEBUG")
	assert_eq(LogLevel.from_string("INFO"), LogLevel.Level.INFO, "Should parse INFO")
	assert_eq(LogLevel.from_string("WARN"), LogLevel.Level.WARN, "Should parse WARN")
	assert_eq(LogLevel.from_string("WARNING"), LogLevel.Level.WARN, "Should parse WARNING as WARN")
	assert_eq(LogLevel.from_string("ERROR"), LogLevel.Level.ERROR, "Should parse ERROR")
	assert_eq(LogLevel.from_string("FATAL"), LogLevel.Level.FATAL, "Should parse FATAL")

func test_from_string_case_insensitive():
	assert_eq(LogLevel.from_string("trace"), LogLevel.Level.TRACE, "Should parse lowercase trace")
	assert_eq(LogLevel.from_string("Debug"), LogLevel.Level.DEBUG, "Should parse mixed case Debug")
	assert_eq(LogLevel.from_string("INFO"), LogLevel.Level.INFO, "Should parse uppercase INFO")
	assert_eq(LogLevel.from_string("wArN"), LogLevel.Level.WARN, "Should parse mixed case wArN")

func test_from_string_invalid_level():
	assert_eq(LogLevel.from_string("INVALID"), LogLevel.Level.INFO, "Should default to INFO for invalid input")
	assert_eq(LogLevel.from_string(""), LogLevel.Level.INFO, "Should default to INFO for empty string")
	assert_eq(LogLevel.from_string("123"), LogLevel.Level.INFO, "Should default to INFO for numeric string")

# Test level_to_string method
func test_level_to_string():
	assert_eq(LogLevel.level_to_string(LogLevel.Level.TRACE), "TRACE", "Should convert TRACE to string")
	assert_eq(LogLevel.level_to_string(LogLevel.Level.DEBUG), "DEBUG", "Should convert DEBUG to string")
	assert_eq(LogLevel.level_to_string(LogLevel.Level.INFO), "INFO", "Should convert INFO to string")
	assert_eq(LogLevel.level_to_string(LogLevel.Level.WARN), "WARN", "Should convert WARN to string")
	assert_eq(LogLevel.level_to_string(LogLevel.Level.ERROR), "ERROR", "Should convert ERROR to string")
	assert_eq(LogLevel.level_to_string(LogLevel.Level.FATAL), "FATAL", "Should convert FATAL to string")

func test_level_to_string_invalid():
	# Test with invalid enum value (should return UNKNOWN)
	assert_eq(LogLevel.level_to_string(99), "UNKNOWN", "Should return UNKNOWN for invalid level")

# Test get_color method
func test_get_color():
	assert_eq(LogLevel.get_color(LogLevel.Level.TRACE), Color.WHITE, "TRACE should be WHITE")
	assert_eq(LogLevel.get_color(LogLevel.Level.DEBUG), Color.CYAN, "DEBUG should be CYAN")
	assert_eq(LogLevel.get_color(LogLevel.Level.INFO), Color.GREEN, "INFO should be GREEN")
	assert_eq(LogLevel.get_color(LogLevel.Level.WARN), Color.YELLOW, "WARN should be YELLOW")
	assert_eq(LogLevel.get_color(LogLevel.Level.ERROR), Color.ORANGE_RED, "ERROR should be ORANGE_RED")
	assert_eq(LogLevel.get_color(LogLevel.Level.FATAL), Color.RED, "FATAL should be RED")

func test_get_color_invalid():
	# Test with invalid enum value (should return WHITE)
	assert_eq(LogLevel.get_color(99), Color.WHITE, "Invalid level should return WHITE")

# Test level names constant
func test_level_names_constant():
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.TRACE), "LEVEL_NAMES should contain TRACE")
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.DEBUG), "LEVEL_NAMES should contain DEBUG")
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.INFO), "LEVEL_NAMES should contain INFO")
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.WARN), "LEVEL_NAMES should contain WARN")
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.ERROR), "LEVEL_NAMES should contain ERROR")
	assert_true(LogLevel.LEVEL_NAMES.has(LogLevel.Level.FATAL), "LEVEL_NAMES should contain FATAL")

# Test level colors constant
func test_level_colors_constant():
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.TRACE), "LEVEL_COLORS should contain TRACE")
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.DEBUG), "LEVEL_COLORS should contain DEBUG")
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.INFO), "LEVEL_COLORS should contain INFO")
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.WARN), "LEVEL_COLORS should contain WARN")
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.ERROR), "LEVEL_COLORS should contain ERROR")
	assert_true(LogLevel.LEVEL_COLORS.has(LogLevel.Level.FATAL), "LEVEL_COLORS should contain FATAL")
