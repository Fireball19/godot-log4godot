# test_logger_main.gd
# Unit tests for the main Logger autoload class using gdUnit4
extends GdUnitTestSuite

var logger_node: Node
var test_file_path: String = "user://test_main_logger.log"

func before_test():
	# Create a Logger instance for testing (simulating the autoload)
	logger_node = preload("res://addons/log4godot/logger.gd").new()
	logger_node._ready()
	
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	if logger_node:
		logger_node.free()
	logger_node = null

# Test initialization
func test_logger_initialization():
	assert_object(logger_node.manager).is_not_null()
	assert_object(logger_node.manager.main_logger).is_not_null()

# Test global logger shortcut methods
func test_trace_shortcut():
	logger_node.set_global_level(LogLevel.Level.TRACE)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.trace("Trace message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("TRACE")
	assert_str(content).contains("Trace message")

func test_debug_shortcut():
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.debug("Debug message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("DEBUG")
	assert_str(content).contains("Debug message")

func test_info_shortcut():
	logger_node.set_global_level(LogLevel.Level.INFO)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.info("Info message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("INFO")
	assert_str(content).contains("Info message")

func test_warn_shortcut():
	logger_node.set_global_level(LogLevel.Level.WARN)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.warn("Warn message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("WARN")
	assert_str(content).contains("Warn message")

func test_error_shortcut():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.error("Error message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("ERROR")
	assert_str(content).contains("Error message")

func test_fatal_shortcut():
	logger_node.set_global_level(LogLevel.Level.FATAL)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.fatal("Fatal message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("FATAL")
	assert_str(content).contains("Fatal message")

func test_log_shortcut():
	logger_node.set_global_level(LogLevel.Level.INFO)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.log(LogLevel.Level.INFO, "Generic log message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("INFO")
	assert_str(content).contains("Generic log message")

# Test level checking shortcuts
func test_is_trace_enabled():
	logger_node.set_global_level(LogLevel.Level.TRACE)
	assert_bool(logger_node.is_trace_enabled()).is_true()
	
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	assert_bool(logger_node.is_trace_enabled()).is_false()

func test_is_debug_enabled():
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	assert_bool(logger_node.is_debug_enabled()).is_true()
	
	logger_node.set_global_level(LogLevel.Level.INFO)
	assert_bool(logger_node.is_debug_enabled()).is_false()

func test_is_info_enabled():
	logger_node.set_global_level(LogLevel.Level.INFO)
	assert_bool(logger_node.is_info_enabled()).is_true()
	
	logger_node.set_global_level(LogLevel.Level.WARN)
	assert_bool(logger_node.is_info_enabled()).is_false()

func test_is_warn_enabled():
	logger_node.set_global_level(LogLevel.Level.WARN)
	assert_bool(logger_node.is_warn_enabled()).is_true()
	
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_bool(logger_node.is_warn_enabled()).is_false()

func test_is_error_enabled():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_bool(logger_node.is_error_enabled()).is_true()
	
	logger_node.set_global_level(LogLevel.Level.FATAL)
	assert_bool(logger_node.is_error_enabled()).is_false()

func test_is_fatal_enabled():
	logger_node.set_global_level(LogLevel.Level.FATAL)
	assert_bool(logger_node.is_fatal_enabled()).is_true()

func test_is_level_enabled():
	logger_node.set_global_level(LogLevel.Level.WARN)
	
	assert_bool(logger_node.is_level_enabled(LogLevel.Level.DEBUG)).is_false()
	assert_bool(logger_node.is_level_enabled(LogLevel.Level.WARN)).is_true()
	assert_bool(logger_node.is_level_enabled(LogLevel.Level.ERROR)).is_true()

# Test configuration methods
func test_set_get_global_level():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_int(logger_node.get_global_level()).is_equal(LogLevel.Level.ERROR)

func test_set_colors_enabled():
	logger_node.set_colors_enabled(false)
	assert_bool(logger_node.manager.output.enable_colors).is_false()
	
	logger_node.set_colors_enabled(true)
	assert_bool(logger_node.manager.output.enable_colors).is_true()

func test_set_file_logging_enabled():
	logger_node.set_file_logging_enabled(true, test_file_path)
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_clear_log_file():
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.info("Message before clear")
	logger_node.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")

# Test named logger management
func test_get_logger():
	var named_logger = logger_node.get_logger("TestLogger")
	
	assert_object(named_logger).is_not_null()
	assert_str(named_logger.name).is_equal("TestLogger")

func test_get_logger_with_level():
	var named_logger = logger_node.get_logger("TestLogger", LogLevel.Level.ERROR)
	assert_int(named_logger.log_level).is_equal(LogLevel.Level.ERROR)

func test_get_logger_default_level():
	var named_logger = logger_node.get_logger("TestLogger")
	assert_int(named_logger.log_level).is_equal(LogLevel.Level.INFO)

func test_remove_logger():
	logger_node.get_logger("ToRemove")
	var removed = logger_node.remove_logger("ToRemove")
	assert_bool(removed).is_true()
	
	var not_removed = logger_node.remove_logger("NonExistent")
	assert_bool(not_removed).is_false()

func test_list_loggers():
	logger_node.get_logger("Logger1")
	logger_node.get_logger("Logger2")
	
	var loggers = logger_node.list_loggers()
	assert_int(loggers.size()).is_equal(2)
	assert_array(loggers).contains(["Logger1"])
	assert_array(loggers).contains(["Logger2"])

# Test utility methods
func test_log_level_from_string():
	assert_int(logger_node.log_level_from_string("DEBUG")).is_equal(LogLevel.Level.DEBUG)
	assert_int(logger_node.log_level_from_string("invalid")).is_equal(LogLevel.Level.INFO)

func test_log_level_to_string():
	assert_str(logger_node.log_level_to_string(LogLevel.Level.ERROR)).is_equal("ERROR")

# Test integration scenarios
func test_main_logger_vs_named_logger():
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	# Use main logger
	logger_node.info("Main logger message")
	
	# Use named logger
	var named = logger_node.get_logger("Named")
	named.info("Named logger message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Main logger message")
	assert_str(content).contains("Named logger message")
	assert_str(content).contains("[Named]")

func test_level_filtering_consistency():
	logger_node.set_global_level(LogLevel.Level.WARN)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	# These should be filtered out
	logger_node.debug("Debug message")
	logger_node.info("Info message")
	
	# These should pass through
	logger_node.warn("Warn message")
	logger_node.error("Error message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).not_contains("Debug message")
	assert_str(content).not_contains("Info message")
	assert_str(content).contains("Warn message")
	assert_str(content).contains("Error message")

func test_configuration_persistence():
	# Test that configuration changes persist across operations
	logger_node.set_global_level(LogLevel.Level.ERROR)
	logger_node.set_colors_enabled(false)
	logger_node.set_timestamps_enabled(true)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	# Create and use a named logger
	var named = logger_node.get_logger("Persistent")
	named.error("Test error message")
	
	# Verify configuration is still applied
	assert_int(logger_node.get_global_level()).is_equal(LogLevel.Level.ERROR)
	assert_bool(logger_node.manager.output.enable_colors).is_false()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test error message")

# Test backwards compatibility
func test_backwards_compatibility():
	# Test that the old-style usage still works
	logger_node.set_global_level(LogLevel.Level.INFO)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	# Old-style direct logging
	logger_node.info("Backwards compatible message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Backwards compatible message")
