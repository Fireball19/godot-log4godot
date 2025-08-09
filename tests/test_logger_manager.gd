# test_logger_manager.gd
# Unit tests for LoggerManager class
extends GutTest

var manager: LoggerManager
var test_file_path: String = "user://test_manager.log"

func before_each():
	manager = LoggerManager.new()
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_each():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	manager = null

# Test initialization
func test_initialization():
	assert_eq(manager.global_log_level, LogLevel.Level.INFO, "Should initialize with INFO level")
	assert_not_null(manager.output, "Should have output instance")
	assert_not_null(manager.main_logger, "Should have main logger")
	assert_eq(manager.named_loggers.size(), 0, "Should start with no named loggers")

func test_main_logger_initialization():
	var main_logger = manager.get_main_logger()
	assert_eq(main_logger.name, "Main", "Main logger should have 'Main' name")
	assert_eq(main_logger.log_level, LogLevel.Level.INFO, "Main logger should have INFO level")

# Test global level management
func test_set_get_global_level():
	manager.set_global_level(LogLevel.Level.ERROR)
	assert_eq(manager.get_global_level(), LogLevel.Level.ERROR, "Should update global level")
	
	# Main logger level should also be updated
	assert_eq(manager.main_logger.log_level, LogLevel.Level.ERROR, "Main logger level should be updated")

func test_global_level_affects_new_loggers():
	manager.set_global_level(LogLevel.Level.WARN)
	
	var logger = manager.get_logger("TestLogger")
	# Logger should use global level as default
	assert_eq(logger.log_level, LogLevel.Level.WARN, "New logger should use global level")

# Test configuration methods
func test_set_colors_enabled():
	manager.set_colors_enabled(false)
	assert_false(manager.output.enable_colors, "Should disable colors in output")
	
	manager.set_colors_enabled(true)
	assert_true(manager.output.enable_colors, "Should enable colors in output")

func test_set_file_logging_enabled():
	manager.set_file_logging_enabled(true, test_file_path)
	# File should be created
	assert_true(FileAccess.file_exists(test_file_path), "Should create log file")
	
	manager.set_file_logging_enabled(false)
	# Should disable file logging

func test_clear_log_file():
	manager.set_file_logging_enabled(true, test_file_path)
	manager.get_main_logger().info("Test message")
	
	manager.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Log Cleared"), "Should clear log file")

# Test logger management
func test_get_logger_creates_new():
	var logger = manager.get_logger("NetworkLogger")
	
	assert_not_null(logger, "Should create new logger")
	assert_eq(logger.name, "NetworkLogger", "Should have correct name")
	assert_true(manager.named_loggers.has("NetworkLogger"), "Should be stored in named_loggers")

func test_get_logger_returns_existing():
	var logger1 = manager.get_logger("TestLogger")
	var logger2 = manager.get_logger("TestLogger")
	
	assert_eq(logger1, logger2, "Should return same instance for same name")

func test_get_logger_with_custom_level():
	var logger = manager.get_logger("CustomLogger", LogLevel.Level.ERROR)
	assert_eq(logger.log_level, LogLevel.Level.ERROR, "Should use custom level")

func test_get_logger_with_default_level():
	manager.set_global_level(LogLevel.Level.WARN)
	var logger = manager.get_logger("DefaultLogger")
	assert_eq(logger.log_level, LogLevel.Level.WARN, "Should use global level as default")

func test_remove_logger_existing():
	manager.get_logger("ToRemove")
	assert_true(manager.named_loggers.has("ToRemove"), "Logger should exist")
	
	var removed = manager.remove_logger("ToRemove")
	assert_true(removed, "Should return true for successful removal")
	assert_false(manager.named_loggers.has("ToRemove"), "Logger should be removed")

func test_remove_logger_non_existing():
	var removed = manager.remove_logger("NonExistent")
	assert_false(removed, "Should return false for non-existent logger")

func test_list_loggers_empty():
	var loggers = manager.list_loggers()
	assert_eq(loggers.size(), 0, "Should return empty array when no loggers")

func test_list_loggers_with_loggers():
	manager.get_logger("Logger1")
	manager.get_logger("Logger2")
	manager.get_logger("Logger3")
	
	var loggers = manager.list_loggers()
	assert_eq(loggers.size(), 3, "Should return all logger names")
	assert_true(loggers.has("Logger1"), "Should contain Logger1")
	assert_true(loggers.has("Logger2"), "Should contain Logger2")
	assert_true(loggers.has("Logger3"), "Should contain Logger3")

func test_list_loggers_after_removal():
	manager.get_logger("Logger1")
	manager.get_logger("Logger2")
	manager.remove_logger("Logger1")
	
	var loggers = manager.list_loggers()
	assert_eq(loggers.size(), 1, "Should have one logger after removal")
	assert_false(loggers.has("Logger1"), "Should not contain removed logger")
	assert_true(loggers.has("Logger2"), "Should contain remaining logger")

# Test global level provider functionality
func test_global_level_provider():
	var test_logger = manager.get_logger("TestLogger", LogLevel.Level.DEBUG)
	
	# Set global level higher than logger level
	manager.set_global_level(LogLevel.Level.ERROR)
	
	# Logger should respect global level
	assert_false(test_logger.is_debug_enabled(), "DEBUG should be disabled due to global level")
	assert_true(test_logger.is_error_enabled(), "ERROR should be enabled")

# Test multiple loggers interaction
func test_multiple_loggers_independent():
	var logger1 = manager.get_logger("Logger1", LogLevel.Level.DEBUG)
	var logger2 = manager.get_logger("Logger2", LogLevel.Level.ERROR)
	
	assert_eq(logger1.log_level, LogLevel.Level.DEBUG, "Logger1 should have DEBUG level")
	assert_eq(logger2.log_level, LogLevel.Level.ERROR, "Logger2 should have ERROR level")
	
	# Changing one shouldn't affect the other
	logger1.set_level(LogLevel.Level.WARN)
	assert_eq(logger1.log_level, LogLevel.Level.WARN, "Logger1 should be updated")
	assert_eq(logger2.log_level, LogLevel.Level.ERROR, "Logger2 should remain unchanged")

func test_multiple_loggers_share_output():
	manager.set_file_logging_enabled(true, test_file_path)
	
	var logger1 = manager.get_logger("Logger1", LogLevel.Level.INFO)
	var logger2 = manager.get_logger("Logger2", LogLevel.Level.INFO)
	
	logger1.info("Message from Logger1")
	logger2.info("Message from Logger2")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Message from Logger1"), "Should contain message from Logger1")
	assert_true(content.contains("Message from Logger2"), "Should contain message from Logger2")

# Test configuration changes affect all loggers
func test_configuration_affects_all_loggers():
	var logger1 = manager.get_logger("Logger1", LogLevel.Level.INFO)
	var logger2 = manager.get_logger("Logger2", LogLevel.Level.INFO)
	
	manager.set_file_logging_enabled(true, test_file_path)
	
	logger1.info("Test message 1")
	logger2.info("Test message 2")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Test message 1"), "Both loggers should use same file output")
	assert_true(content.contains("Test message 2"), "Both loggers should use same file output")

# Test main logger accessibility
func test_main_logger_separate_from_named():
	var main = manager.get_main_logger()
	var named_main = manager.get_logger("Main")
	
	assert_ne(main, named_main, "Main logger should be separate from named 'Main' logger")
	assert_eq(main.name, "Main", "Main logger should have 'Main' name")
	assert_eq(named_main.name, "Main", "Named 'Main' logger should also have 'Main' name")

func test_main_logger_global_level_sync():
	var main = manager.get_main_logger()
	
	manager.set_global_level(LogLevel.Level.FATAL)
	assert_eq(main.log_level, LogLevel.Level.FATAL, "Main logger should sync with global level")

# Test edge cases
func test_logger_name_edge_cases():
	# Test empty name
	var empty_logger = manager.get_logger("")
	assert_eq(empty_logger.name, "", "Should handle empty logger name")
	
	# Test name with spaces
	var space_logger = manager.get_logger("Logger With Spaces")
	assert_eq(space_logger.name, "Logger With Spaces", "Should handle names with spaces")
	
	# Test special characters
	var special_logger = manager.get_logger("Logger@#$%")
	assert_eq(special_logger.name, "Logger@#$%", "Should handle special characters in name")

func test_global_level_extreme_values():
	# Test all possible log levels
	for level in LogLevel.Level.values():
		manager.set_global_level(level)
		assert_eq(manager.get_global_level(), level, "Should handle level: " + LogLevel.level_to_string(level))

# Test memory management and cleanup
func test_logger_cleanup():
	# Create many loggers
	for i in range(100):
		manager.get_logger("Logger" + str(i))
	
	assert_eq(manager.list_loggers().size(), 100, "Should create 100 loggers")
	
	# Remove half of them
	for i in range(50):
		manager.remove_logger("Logger" + str(i))
	
	assert_eq(manager.list_loggers().size(), 50, "Should have 50 loggers remaining")

# Test concurrent-like scenarios
func test_rapid_logger_creation():
	var logger_names: Array[String] = []
	
	# Rapidly create and access loggers
	for i in range(10):
		var name = "RapidLogger" + str(i)
		logger_names.append(name)
		var logger = manager.get_logger(name)
		logger.info("Message from " + name)
	
	assert_eq(manager.list_loggers().size(), 10, "Should create all loggers")
	
	# Verify all names are present
	var listed_loggers = manager.list_loggers()
	for name in logger_names:
		assert_true(listed_loggers.has(name), "Should contain logger: " + name)

func test_logger_level_inheritance():
	# Test that new loggers inherit current global level
	manager.set_global_level(LogLevel.Level.WARN)
	var logger1 = manager.get_logger("InheritLogger1")
	
	manager.set_global_level(LogLevel.Level.ERROR)
	var logger2 = manager.get_logger("InheritLogger2")
	
	assert_eq(logger1.log_level, LogLevel.Level.WARN, "Logger1 should inherit WARN level")
	assert_eq(logger2.log_level, LogLevel.Level.ERROR, "Logger2 should inherit ERROR level")
	
