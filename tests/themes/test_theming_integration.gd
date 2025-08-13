# test_theming_integration.gd
# Integration tests for the theming system across Log4Godot components
extends GdUnitTestSuite

var formatter: LogFormatter
var output: LogOutput
var manager: LoggerManager
var logger_node: Node
var test_file_path: String = "user://test_theming.log"

func before_test():
	formatter = LogFormatter.new()
	output = LogOutput.new()
	manager = LoggerManager.new()
	
	# Create Logger node for testing
	logger_node = preload("res://addons/log4godot/logger.gd").new()
	logger_node._ready()
	
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test():
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	if logger_node:
		logger_node.free()
	
	formatter = null
	output = null
	manager = null
	logger_node = null

# Test LogFormatter theming integration
func test_formatter_theme_setting():
	var custom_theme = LogTheme.new()
	custom_theme.error_color = Color.MAGENTA
	custom_theme.theme_name = "Test Theme"
	
	formatter.set_theme(custom_theme)
	var retrieved_theme = formatter.get_theme()
	
	assert_object(retrieved_theme).is_equal(custom_theme)
	assert_str(retrieved_theme.theme_name).is_equal("Test Theme")
	assert_object(retrieved_theme.error_color).is_equal(Color.MAGENTA)

func test_formatter_colored_message_formatting():
	var custom_theme = LogTheme.new()
	custom_theme.error_color = Color(1, 0.5, 0)  # Orange
	custom_theme.info_color = Color(0, 1, 0.5)   # Green-cyan
	formatter.set_theme(custom_theme)
	formatter.set_timestamps_enabled(false)
	
	var error_message = formatter.format_message_with_colors("TestLogger", LogLevel.Level.ERROR, "Error text")
	var info_message = formatter.format_message_with_colors("TestLogger", LogLevel.Level.INFO, "Info text")
	
	# Should contain color tags with hex values
	assert_str(error_message).contains("[color=ff8000ff]")  # Orange hex
	assert_str(info_message).contains("[color=00ff80ff]")   # Green-cyan hex
	assert_str(error_message).contains("Error text")
	assert_str(info_message).contains("Info text")

func test_formatter_timestamp_coloring():
	var custom_theme = LogTheme.new()
	custom_theme.timestamp_color = Color.BLUE
	formatter.set_theme(custom_theme)
	formatter.set_timestamps_enabled(true)
	
	var message = formatter.format_message_with_colors("Test", LogLevel.Level.INFO, "Message")
	
	# Should contain blue timestamp
	assert_str(message).contains("[color=0000ffff]")  # Blue hex
	assert_str(message).contains("Message")

# Test LogOutput theming integration
func test_output_theme_setting():
	var custom_theme = LogTheme.new()
	custom_theme.theme_name = "Output Test Theme"
	
	output.set_theme(custom_theme)
	var retrieved_theme = output.get_theme()
	
	assert_object(retrieved_theme).is_equal(custom_theme)
	assert_str(retrieved_theme.theme_name).is_equal("Output Test Theme")

func test_output_theme_propagation_to_formatter():
	var custom_theme = LogTheme.new()
	custom_theme.warn_color = Color.PURPLE
	
	output.set_theme(custom_theme)
	var formatter_theme = output.formatter.get_theme()
	
	assert_object(formatter_theme).is_equal(custom_theme)
	assert_object(formatter_theme.warn_color).is_equal(Color.PURPLE)

# Test LoggerManager theming integration
func test_manager_theme_initialization():
	var default_theme = manager.get_current_theme()
	
	assert_object(default_theme).is_not_null()
	assert_str(default_theme.theme_name).is_equal("Default")

func test_manager_set_theme():
	var fallout_theme = manager.get_theme_by_name("Fallout")
	assert_object(fallout_theme).is_not_null()
	
	manager.set_theme(fallout_theme)
	var current_theme = manager.get_current_theme()
	
	assert_object(current_theme).is_equal(fallout_theme)
	assert_str(current_theme.theme_name).is_equal("Fallout")

func test_manager_set_theme_by_name():
	var success = manager.set_theme_by_name("Minimal")
	assert_bool(success).is_true()
	
	var current_theme = manager.get_current_theme()
	assert_str(current_theme.theme_name).is_equal("Minimal")

func test_manager_set_invalid_theme_by_name():
	var success = manager.set_theme_by_name("NonExistentTheme")
	assert_bool(success).is_false()
	
	# Theme should remain unchanged
	var current_theme = manager.get_current_theme()
	assert_str(current_theme.theme_name).is_equal("Default")

func test_manager_custom_theme_management():
	var custom_theme = LogTheme.new()
	custom_theme.theme_name = "MyCustomTheme"
	custom_theme.error_color = Color.ORANGE
	
	manager.add_custom_theme("MyCustomTheme", custom_theme)
	
	var available_themes = manager.get_available_themes()
	assert_array(available_themes).contains(["MyCustomTheme"])
	
	var retrieved_theme = manager.get_theme_by_name("MyCustomTheme")
	assert_object(retrieved_theme).is_equal(custom_theme)
	assert_object(retrieved_theme.error_color).is_equal(Color.ORANGE)

func test_manager_get_available_themes():
	var themes = manager.get_available_themes()
	
	assert_int(themes.size()).is_greater_equal(4)
	assert_array(themes).contains(["Default"])
	assert_array(themes).contains(["Minimal"])
	assert_array(themes).contains(["Whiteout"])
	assert_array(themes).contains(["Fallout"])

# Test main Logger node theming integration
func test_logger_node_theme_setting():
	var minimal_theme = logger_node.get_theme_by_name("Minimal")
	logger_node.set_theme(minimal_theme)
	
	var current_theme = logger_node.get_current_theme()
	assert_object(current_theme).is_equal(minimal_theme)
	assert_str(current_theme.theme_name).is_equal("Minimal")

func test_logger_node_set_theme_by_name():
	var success = logger_node.set_theme_by_name("Whiteout")
	assert_bool(success).is_true()
	
	var current_theme = logger_node.get_current_theme()
	assert_str(current_theme.theme_name).is_equal("Whiteout")

func test_logger_node_get_available_themes():
	var themes = logger_node.get_available_themes()
	
	assert_array(themes).contains(["Default"])
	assert_array(themes).contains(["Minimal"])
	assert_array(themes).contains(["Whiteout"])
	assert_array(themes).contains(["Fallout"])

func test_logger_node_custom_theme_addition():
	var custom_theme = LogTheme.new()
	custom_theme.theme_name = "NodeCustomTheme"
	
	logger_node.add_custom_theme("NodeCustomTheme", custom_theme)
	
	var themes = logger_node.get_available_themes()
	assert_array(themes).contains(["NodeCustomTheme"])
	
	var retrieved = logger_node.get_theme_by_name("NodeCustomTheme")
	assert_object(retrieved).is_equal(custom_theme)

# Test theme effects on actual logging output
func test_themed_logging_to_file():
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.set_colors_enabled(false)  # File output should be plain text
	logger_node.set_theme_by_name("Fallout")
	
	logger_node.error("Fallout themed error")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# File output should be plain text regardless of theme
	assert_str(content).contains("[ERROR]")
	assert_str(content).contains("Fallout themed error")
	assert_str(content).not_contains("[color=")

func test_theme_affects_named_loggers():
	var custom_theme = LogTheme.new()
	custom_theme.debug_color = Color.CYAN
	custom_theme.theme_name = "NamedLoggerTheme"
	
	manager.set_theme(custom_theme)
	var named_logger = manager.get_logger("ThemedLogger", LogLevel.Level.DEBUG)
	
	# The named logger should use the same output with the current theme
	assert_object(named_logger.output).is_equal(manager.output)
	assert_str(named_logger.output.get_theme().theme_name).is_equal("NamedLoggerTheme")

# Test theme persistence across configuration changes
func test_theme_persistence():
	logger_node.set_theme_by_name("Minimal")
	logger_node.set_colors_enabled(false)
	logger_node.set_timestamps_enabled(false)
	
	var current_theme = logger_node.get_current_theme()
	assert_str(current_theme.theme_name).is_equal("Minimal")
	
	logger_node.set_colors_enabled(true)
	current_theme = logger_node.get_current_theme()
	assert_str(current_theme.theme_name).is_equal("Minimal")

# Test default theme loading and properties
func test_default_theme_properties():
	var default_theme = manager.get_theme_by_name("Default")
	
	assert_str(default_theme.theme_name).is_equal("Default")
	assert_object(default_theme.error_color).is_equal(Color.RED)
	assert_object(default_theme.warn_color).is_equal(Color.YELLOW)

func test_minimal_theme_properties():
	var minimal_theme = manager.get_theme_by_name("Minimal")
	
	assert_str(minimal_theme.theme_name).is_equal("Minimal")
	# Minimal theme should have only error/fatal in red, others muted
	assert_object(minimal_theme.error_color).is_equal(Color.RED)
	assert_object(minimal_theme.fatal_color).is_equal(Color.RED)

func test_whiteout_theme_properties():
	var whiteout_theme = manager.get_theme_by_name("Whiteout")
	
	assert_str(whiteout_theme.theme_name).is_equal("Whiteout")
	# All colors should be white in whiteout theme
	assert_object(whiteout_theme.trace_color).is_equal(Color.WHITE)
	assert_object(whiteout_theme.debug_color).is_equal(Color.WHITE)
	assert_object(whiteout_theme.info_color).is_equal(Color.WHITE)
	assert_object(whiteout_theme.warn_color).is_equal(Color.WHITE)
	assert_object(whiteout_theme.error_color).is_equal(Color.WHITE)
	assert_object(whiteout_theme.fatal_color).is_equal(Color.WHITE)

func test_fallout_theme_properties():
	var fallout_theme = manager.get_theme_by_name("Fallout")
	
	assert_str(fallout_theme.theme_name).is_equal("Fallout")
	# All colors should be green in fallout theme
	assert_object(fallout_theme.trace_color).is_equal(Color.GREEN)
	assert_object(fallout_theme.debug_color).is_equal(Color.GREEN)
	assert_object(fallout_theme.info_color).is_equal(Color.GREEN)
	assert_object(fallout_theme.warn_color).is_equal(Color.GREEN)
	assert_object(fallout_theme.error_color).is_equal(Color.GREEN)
	assert_object(fallout_theme.fatal_color).is_equal(Color.GREEN)

# Test concurrent theming scenarios
func test_multiple_loggers_same_theme():
	var custom_theme = LogTheme.new()
	custom_theme.theme_name = "SharedTheme"
	manager.set_theme(custom_theme)
	
	var logger1 = manager.get_logger("Logger1")
	var logger2 = manager.get_logger("Logger2")
	
	# Both loggers should share the same output with the same theme
	assert_object(logger1.output).is_equal(logger2.output)
	assert_str(logger1.output.get_theme().theme_name).is_equal("SharedTheme")
	assert_str(logger2.output.get_theme().theme_name).is_equal("SharedTheme")

# Test error cases
func test_null_theme_handling():
	# This should not crash the system
	var original_theme = manager.get_current_theme()
	
	# Try to set null theme (should be handled gracefully)
	if manager.get_theme_by_name("NonExistent") == null:
		# The current theme should remain unchanged
		var current_theme = manager.get_current_theme()
		assert_object(current_theme).is_equal(original_theme)
