# test_log_theme.gd
# Unit tests for LogTheme class using gdUnit4
extends GdUnitTestSuite

var theme: LogTheme

func before_test():
	theme = LogTheme.new()

func after_test():
	theme = null

# Test initialization
func test_initialization():
	assert_object(theme).is_not_null()
	assert_str(theme.theme_name).is_equal("Default")
	assert_object(theme.trace_color).is_not_null()
	assert_object(theme.debug_color).is_not_null()
	assert_object(theme.info_color).is_not_null()
	assert_object(theme.warn_color).is_not_null()
	assert_object(theme.error_color).is_not_null()
	assert_object(theme.fatal_color).is_not_null()
	assert_object(theme.timestamp_color).is_not_null()

# Test default color values
func test_default_colors():
	var expected_gray = Color(0.804, 0.812, 0.824)
	
	assert_object(theme.trace_color).is_equal(expected_gray)
	assert_object(theme.info_color).is_equal(expected_gray)
	assert_object(theme.timestamp_color).is_equal(expected_gray)
	
	assert_object(theme.debug_color).is_equal(Color(0.872, 1.0, 0.997))
	assert_object(theme.warn_color).is_equal(Color.YELLOW)
	assert_object(theme.error_color).is_equal(Color.RED)
	assert_object(theme.fatal_color).is_equal(Color.RED)

# Test get_color_for_level method
func test_get_color_for_level_all_levels():
	assert_object(theme.get_color_for_level(LogLevel.Level.TRACE)).is_equal(theme.trace_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.DEBUG)).is_equal(theme.debug_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.INFO)).is_equal(theme.info_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.WARN)).is_equal(theme.warn_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.ERROR)).is_equal(theme.error_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.FATAL)).is_equal(theme.fatal_color)

func test_get_color_for_level_invalid():
	# Test with invalid level (should return WHITE as fallback)
	var invalid_level = 999 as LogLevel.Level
	assert_object(theme.get_color_for_level(invalid_level)).is_equal(Color.WHITE)

# Test custom color assignment
func test_custom_color_assignment():
	var custom_red = Color(0.8, 0.2, 0.2)
	var custom_blue = Color(0.2, 0.2, 0.8)
	
	theme.error_color = custom_red
	theme.debug_color = custom_blue
	
	assert_object(theme.error_color).is_equal(custom_red)
	assert_object(theme.debug_color).is_equal(custom_blue)
	
	assert_object(theme.get_color_for_level(LogLevel.Level.ERROR)).is_equal(custom_red)
	assert_object(theme.get_color_for_level(LogLevel.Level.DEBUG)).is_equal(custom_blue)

# Test theme name
func test_theme_name():
	theme.theme_name = "Custom Theme"
	assert_str(theme.theme_name).is_equal("Custom Theme")
	
	theme.theme_name = ""
	assert_str(theme.theme_name).is_equal("")

# Test default themes static dictionary
func test_default_themes_exist():
	assert_object(LogTheme.default_themes).is_not_null()
	assert_bool(LogTheme.default_themes.has("Default")).is_true()
	assert_bool(LogTheme.default_themes.has("Minimal")).is_true()
	assert_bool(LogTheme.default_themes.has("Whiteout")).is_true()
	assert_bool(LogTheme.default_themes.has("Fallout")).is_true()

func test_default_themes_are_log_themes():
	for theme_name in LogTheme.default_themes.keys():
		var loaded_theme = LogTheme.default_themes[theme_name]
		assert_object(loaded_theme).is_instanceof(LogTheme)
		assert_str(loaded_theme.theme_name).is_equal(theme_name)

# Test color consistency
func test_color_consistency():
	# Colors should remain consistent across multiple calls
	var initial_error_color = theme.get_color_for_level(LogLevel.Level.ERROR)
	var second_error_color = theme.get_color_for_level(LogLevel.Level.ERROR)
	
	assert_object(initial_error_color).is_equal(second_error_color)

# Test edge cases with extreme color values
func test_extreme_color_values():
	# Test with extreme alpha values
	theme.trace_color = Color(1, 1, 1, 0)  # Transparent
	theme.debug_color = Color(0, 0, 0, 1)  # Black
	
	assert_object(theme.get_color_for_level(LogLevel.Level.TRACE)).is_equal(Color(1, 1, 1, 0))
	assert_object(theme.get_color_for_level(LogLevel.Level.DEBUG)).is_equal(Color.BLACK)

# Test color modification doesn't affect other levels
func test_color_isolation():
	var original_info_color = theme.info_color
	theme.error_color = Color.MAGENTA
	
	# Changing error color shouldn't affect info color
	assert_object(theme.get_color_for_level(LogLevel.Level.INFO)).is_equal(original_info_color)
	assert_object(theme.get_color_for_level(LogLevel.Level.ERROR)).is_equal(Color.MAGENTA)
