# test_log_level.gd
# Unit tests for LogLevel class using gdUnit4
extends GdUnitTestSuite

func before_test():
	print("Setting up LogLevel test")

func after_test():
	print("Tearing down LogLevel test")

# Test enum values
func test_level_enum_values():
	assert_int(LogLevel.Level.TRACE).is_equal(0)
	assert_int(LogLevel.Level.DEBUG).is_equal(1)
	assert_int(LogLevel.Level.INFO).is_equal(2)
	assert_int(LogLevel.Level.WARN).is_equal(3)
	assert_int(LogLevel.Level.ERROR).is_equal(4)
	assert_int(LogLevel.Level.FATAL).is_equal(5)

# Test from_string method
func test_from_string_valid_levels():
	assert_int(LogLevel.from_string("TRACE")).is_equal(LogLevel.Level.TRACE)
	assert_int(LogLevel.from_string("DEBUG")).is_equal(LogLevel.Level.DEBUG)
	assert_int(LogLevel.from_string("INFO")).is_equal(LogLevel.Level.INFO)
	assert_int(LogLevel.from_string("WARN")).is_equal(LogLevel.Level.WARN)
	assert_int(LogLevel.from_string("WARNING")).is_equal(LogLevel.Level.WARN)
	assert_int(LogLevel.from_string("ERROR")).is_equal(LogLevel.Level.ERROR)
	assert_int(LogLevel.from_string("FATAL")).is_equal(LogLevel.Level.FATAL)

func test_from_string_case_insensitive():
	assert_int(LogLevel.from_string("trace")).is_equal(LogLevel.Level.TRACE)
	assert_int(LogLevel.from_string("Debug")).is_equal(LogLevel.Level.DEBUG)
	assert_int(LogLevel.from_string("INFO")).is_equal(LogLevel.Level.INFO)
	assert_int(LogLevel.from_string("wArN")).is_equal(LogLevel.Level.WARN)

func test_from_string_invalid_level():
	assert_int(LogLevel.from_string("INVALID")).is_equal(LogLevel.Level.INFO)
	assert_int(LogLevel.from_string("")).is_equal(LogLevel.Level.INFO)
	assert_int(LogLevel.from_string("123")).is_equal(LogLevel.Level.INFO)

# Test level_to_string method
func test_level_to_string():
	assert_str(LogLevel.level_to_string(LogLevel.Level.TRACE)).is_equal("TRACE")
	assert_str(LogLevel.level_to_string(LogLevel.Level.DEBUG)).is_equal("DEBUG")
	assert_str(LogLevel.level_to_string(LogLevel.Level.INFO)).is_equal("INFO")
	assert_str(LogLevel.level_to_string(LogLevel.Level.WARN)).is_equal("WARN")
	assert_str(LogLevel.level_to_string(LogLevel.Level.ERROR)).is_equal("ERROR")
	assert_str(LogLevel.level_to_string(LogLevel.Level.FATAL)).is_equal("FATAL")

func test_level_to_string_invalid():
	# Test with invalid enum value (should return UNKNOWN)
	assert_str(LogLevel.level_to_string(99)).is_equal("UNKNOWN")

# Test get_color method
func test_get_color():
	assert_object(LogLevel.get_color(LogLevel.Level.TRACE)).is_equal(Color.WHITE)
	assert_object(LogLevel.get_color(LogLevel.Level.DEBUG)).is_equal(Color.CYAN)
	assert_object(LogLevel.get_color(LogLevel.Level.INFO)).is_equal(Color.GREEN)
	assert_object(LogLevel.get_color(LogLevel.Level.WARN)).is_equal(Color.YELLOW)
	assert_object(LogLevel.get_color(LogLevel.Level.ERROR)).is_equal(Color.ORANGE_RED)
	assert_object(LogLevel.get_color(LogLevel.Level.FATAL)).is_equal(Color.RED)

func test_get_color_invalid():
	# Test with invalid enum value (should return WHITE)
	assert_object(LogLevel.get_color(99)).is_equal(Color.WHITE)

# Test level names constant
func test_level_names_constant():
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.TRACE)).is_true()
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.DEBUG)).is_true()
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.INFO)).is_true()
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.WARN)).is_true()
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.ERROR)).is_true()
	assert_bool(LogLevel.LEVEL_NAMES.has(LogLevel.Level.FATAL)).is_true()

# Test level colors constant
func test_level_colors_constant():
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.TRACE)).is_true()
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.DEBUG)).is_true()
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.INFO)).is_true()
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.WARN)).is_true()
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.ERROR)).is_true()
	assert_bool(LogLevel.LEVEL_COLORS.has(LogLevel.Level.FATAL)).is_true()
