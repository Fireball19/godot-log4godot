# test_logger_main.gd
# Unit tests for the main Logger autoload class
extends GutTest

var logger_node: Node
var test_file_path: String = "user://test_main_logger.log"

func before_each():
	# Create a Logger instance for testing (simulating the autoload)
	logger_node = preload("res://addons/log4godot/logger.gd").new()
	logger_node._ready()
	
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_each():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	if logger_node:
		logger_node.free()
	logger_node = null

# Test initialization
func test_logger_initialization():
	assert_not_null(logger_node.manager, "Should have manager instance")
	assert_not_null(logger_node.manager.main_logger, "Should have main logger")

# Test global logger shortcut methods
func test_trace_shortcut():
	logger_node.set_global_level(LogLevel.Level.TRACE)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.trace("Trace message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("TRACE"), "Should contain TRACE level")
	assert_true(content.contains("Trace message"), "Should contain trace message")

func test_debug_shortcut():
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.debug("Debug message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("DEBUG"), "Should contain DEBUG level")
	assert_true(content.contains("Debug message"), "Should contain debug message")

func test_info_shortcut():
	logger_node.set_global_level(LogLevel.Level.INFO)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.info("Info message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("INFO"), "Should contain INFO level")
	assert_true(content.contains("Info message"), "Should contain info message")

func test_warn_shortcut():
	logger_node.set_global_level(LogLevel.Level.WARN)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.warn("Warn message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("WARN"), "Should contain WARN level")
	assert_true(content.contains("Warn message"), "Should contain warn message")

func test_error_shortcut():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.error("Error message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("ERROR"), "Should contain ERROR level")
	assert_true(content.contains("Error message"), "Should contain error message")

func test_fatal_shortcut():
	logger_node.set_global_level(LogLevel.Level.FATAL)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.fatal("Fatal message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("FATAL"), "Should contain FATAL level")
	assert_true(content.contains("Fatal message"), "Should contain fatal message")

func test_log_shortcut():
	logger_node.set_global_level(LogLevel.Level.INFO)
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.log(LogLevel.Level.INFO, "Generic log message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("INFO"), "Should contain INFO level")
	assert_true(content.contains("Generic log message"), "Should contain generic message")

# Test level checking shortcuts
func test_is_trace_enabled():
	logger_node.set_global_level(LogLevel.Level.TRACE)
	assert_true(logger_node.is_trace_enabled(), "Should enable TRACE")
	
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	assert_false(logger_node.is_trace_enabled(), "Should disable TRACE")

func test_is_debug_enabled():
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	assert_true(logger_node.is_debug_enabled(), "Should enable DEBUG")
	
	logger_node.set_global_level(LogLevel.Level.INFO)
	assert_false(logger_node.is_debug_enabled(), "Should disable DEBUG")

func test_is_info_enabled():
	logger_node.set_global_level(LogLevel.Level.INFO)
	assert_true(logger_node.is_info_enabled(), "Should enable INFO")
	
	logger_node.set_global_level(LogLevel.Level.WARN)
	assert_false(logger_node.is_info_enabled(), "Should disable INFO")

func test_is_warn_enabled():
	logger_node.set_global_level(LogLevel.Level.WARN)
	assert_true(logger_node.is_warn_enabled(), "Should enable WARN")
	
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_false(logger_node.is_warn_enabled(), "Should disable WARN")

func test_is_error_enabled():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_true(logger_node.is_error_enabled(), "Should enable ERROR")
	
	logger_node.set_global_level(LogLevel.Level.FATAL)
	assert_false(logger_node.is_error_enabled(), "Should disable ERROR")

func test_is_fatal_enabled():
	logger_node.set_global_level(LogLevel.Level.FATAL)
	assert_true(logger_node.is_fatal_enabled(), "Should enable FATAL")

func test_is_level_enabled():
	logger_node.set_global_level(LogLevel.Level.WARN)
	
	assert_false(logger_node.is_level_enabled(LogLevel.Level.DEBUG), "DEBUG should be disabled")
	assert_true(logger_node.is_level_enabled(LogLevel.Level.WARN), "WARN should be enabled")
	assert_true(logger_node.is_level_enabled(LogLevel.Level.ERROR), "ERROR should be enabled")

# Test configuration methods
func test_set_get_global_level():
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_eq(logger_node.get_global_level(), LogLevel.Level.ERROR, "Should update global level")

func test_set_colors_enabled():
	logger_node.set_colors_enabled(false)
	assert_false(logger_node.manager.output.enable_colors, "Should disable colors")
	
	logger_node.set_colors_enabled(true)
	assert_true(logger_node.manager.output.enable_colors, "Should enable colors")

func test_set_file_logging_enabled():
	logger_node.set_file_logging_enabled(true, test_file_path)
	assert_true(FileAccess.file_exists(test_file_path), "Should create log file")

func test_clear_log_file():
	logger_node.set_file_logging_enabled(true, test_file_path)
	logger_node.info("Message before clear")
	logger_node.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Log Cleared"), "Should clear log file")

# Test named logger management
func test_get_logger():
	var named_logger = logger_node.get_logger("TestLogger")
	
	assert_not_null(named_logger, "Should return logger instance")
	assert_eq(named_logger.name, "TestLogger", "Should have correct name")

func test_get_logger_with_level():
	var named_logger = logger_node.get_logger("TestLogger", LogLevel.Level.ERROR)
	assert_eq(named_logger.log_level, LogLevel.Level.ERROR, "Should use specified level")

func test_get_logger_default_level():
	var named_logger = logger_node.get_logger("TestLogger")
	assert_eq(named_logger.log_level, LogLevel.Level.INFO, "Should use default INFO level")

func test_remove_logger():
	logger_node.get_logger("ToRemove")
	var removed = logger_node.remove_logger("ToRemove")
	assert_true(removed, "Should remove existing logger")
	
	var not_removed = logger_node.remove_logger("NonExistent")
	assert_false(not_removed, "Should return false for non-existent logger")

func test_list_loggers():
	logger_node.get_logger("Logger1")
	logger_node.get_logger("Logger2")
	
	var loggers = logger_node.list_loggers()
	assert_eq(loggers.size(), 2, "Should list all named loggers")
	assert_true(loggers.has("Logger1"), "Should contain Logger1")
	assert_true(loggers.has("Logger2"), "Should contain Logger2")

# Test utility methods
func test_log_level_from_string():
	assert_eq(logger_node.log_level_from_string("DEBUG"), LogLevel.Level.DEBUG, "Should parse DEBUG")
	assert_eq(logger_node.log_level_from_string("invalid"), LogLevel.Level.INFO, "Should default to INFO")

func test_log_level_to_string():
	assert_eq(logger_node.log_level_to_string(LogLevel.Level.ERROR), "ERROR", "Should convert ERROR to string")

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
	
	assert_true(content.contains("Main logger message"), "Should contain main logger message")
	assert_true(content.contains("Named logger message"), "Should contain named logger message")
	assert_true(content.contains("[Named]"), "Should show named logger name")

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
	
	assert_false(content.contains("Debug message"), "DEBUG should be filtered")
	assert_false(content.contains("Info message"), "INFO should be filtered")
	assert_true(content.contains("Warn message"), "WARN should pass through")
	assert_true(content.contains("Error message"), "ERROR should pass through")

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
	assert_eq(logger_node.get_global_level(), LogLevel.Level.ERROR, "Global level should persist")
	assert_false(logger_node.manager.output.enable_colors, "Color setting should persist")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Test error message"), "Should log with persistent configuration")

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
	
	assert_true(content.contains("Backwards compatible message"), "Should support old-style usage")
