# test_logger_manager.gd
# Unit tests for LoggerManager class using gdUnit4
extends GdUnitTestSuite

var manager: LoggerManager
var test_file_path: String = "user://test_manager.log"

func before_test():
	manager = LoggerManager.new()
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	manager = null

# Test initialization
func test_initialization():
	assert_int(manager.global_log_level).is_equal(LogLevel.Level.INFO)
	assert_object(manager.output).is_not_null()
	assert_object(manager.main_logger).is_not_null()
	assert_int(manager.named_loggers.size()).is_equal(0)

func test_main_logger_initialization():
	var main_logger = manager.get_main_logger()
	assert_str(main_logger.name).is_equal("Main")
	assert_int(main_logger.log_level).is_equal(LogLevel.Level.INFO)

# Test global level management
func test_set_get_global_level():
	manager.set_global_level(LogLevel.Level.ERROR)
	assert_int(manager.get_global_level()).is_equal(LogLevel.Level.ERROR)
	
	# Main logger level should also be updated
	assert_int(manager.main_logger.log_level).is_equal(LogLevel.Level.ERROR)

func test_global_level_affects_new_loggers():
	manager.set_global_level(LogLevel.Level.WARN)
	
	var logger = manager.get_logger("TestLogger")
	# Logger should use global level as default
	assert_int(logger.log_level).is_equal(LogLevel.Level.WARN)

# Test configuration methods
func test_set_colors_enabled():
	manager.set_colors_enabled(false)
	assert_bool(manager.output.enable_colors).is_false()
	
	manager.set_colors_enabled(true)
	assert_bool(manager.output.enable_colors).is_true()

func test_set_file_logging_enabled():
	manager.set_file_logging_enabled(true, test_file_path)
	# File should be created
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()
	
	manager.set_file_logging_enabled(false)
	# Should disable file logging

func test_clear_log_file():
	manager.set_file_logging_enabled(true, test_file_path)
	manager.get_main_logger().info("Test message")
	
	manager.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")

# Test logger management
func test_get_logger_creates_new():
	var logger = manager.get_logger("NetworkLogger")
	
	assert_object(logger).is_not_null()
	assert_str(logger.name).is_equal("NetworkLogger")
	assert_bool(manager.named_loggers.has("NetworkLogger")).is_true()

func test_get_logger_returns_existing():
	var logger1 = manager.get_logger("TestLogger")
	var logger2 = manager.get_logger("TestLogger")
	
	assert_object(logger1).is_equal(logger2)

func test_get_logger_with_custom_level():
	var logger = manager.get_logger("CustomLogger", LogLevel.Level.ERROR)
	assert_int(logger.log_level).is_equal(LogLevel.Level.ERROR)

func test_get_logger_with_default_level():
	manager.set_global_level(LogLevel.Level.WARN)
	var logger = manager.get_logger("DefaultLogger")
	assert_int(logger.log_level).is_equal(LogLevel.Level.WARN)

func test_remove_logger_existing():
	manager.get_logger("ToRemove")
	assert_bool(manager.named_loggers.has("ToRemove")).is_true()
	
	var removed = manager.remove_logger("ToRemove")
	assert_bool(removed).is_true()
	assert_bool(manager.named_loggers.has("ToRemove")).is_false()

func test_remove_logger_non_existing():
	var removed = manager.remove_logger("NonExistent")
	assert_bool(removed).is_false()

func test_list_loggers_empty():
	var loggers = manager.list_loggers()
	assert_int(loggers.size()).is_equal(0)

func test_list_loggers_with_loggers():
	manager.get_logger("Logger1")
	manager.get_logger("Logger2")
	manager.get_logger("Logger3")
	
	var loggers = manager.list_loggers()
	assert_int(loggers.size()).is_equal(3)
	assert_array(loggers).contains(["Logger1"])
	assert_array(loggers).contains(["Logger2"])
	assert_array(loggers).contains(["Logger3"])

func test_list_loggers_after_removal():
	manager.get_logger("Logger1")
	manager.get_logger("Logger2")
	manager.remove_logger("Logger1")
	
	var loggers = manager.list_loggers()
	assert_int(loggers.size()).is_equal(1)
	assert_array(loggers).not_contains(["Logger1"])
	assert_array(loggers).contains(["Logger2"])

# Test global level provider functionality
func test_global_level_provider():
	var test_logger = manager.get_logger("TestLogger", LogLevel.Level.DEBUG)
	
	# Set global level higher than logger level
	manager.set_global_level(LogLevel.Level.ERROR)
	
	# Logger should respect global level
	assert_bool(test_logger.is_debug_enabled()).is_false()
	assert_bool(test_logger.is_error_enabled()).is_true()

# Test multiple loggers interaction
func test_multiple_loggers_independent():
	var logger1 = manager.get_logger("Logger1", LogLevel.Level.DEBUG)
	var logger2 = manager.get_logger("Logger2", LogLevel.Level.ERROR)
	
	assert_int(logger1.log_level).is_equal(LogLevel.Level.DEBUG)
	assert_int(logger2.log_level).is_equal(LogLevel.Level.ERROR)
	
	# Changing one shouldn't affect the other
	logger1.set_level(LogLevel.Level.WARN)
	assert_int(logger1.log_level).is_equal(LogLevel.Level.WARN)
	assert_int(logger2.log_level).is_equal(LogLevel.Level.ERROR)

func test_multiple_loggers_share_output():
	manager.set_file_logging_enabled(true, test_file_path)
	
	var logger1 = manager.get_logger("Logger1", LogLevel.Level.INFO)
	var logger2 = manager.get_logger("Logger2", LogLevel.Level.INFO)
	
	logger1.info("Message from Logger1")
	logger2.info("Message from Logger2")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Message from Logger1")
	assert_str(content).contains("Message from Logger2")

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
	
	assert_str(content).contains("Test message 1")
	assert_str(content).contains("Test message 2")

# Test main logger accessibility
func test_main_logger_separate_from_named():
	var main = manager.get_main_logger()
	var named_main = manager.get_logger("Main")
	
	print(main)
	print(named_main)
	
	assert_object(main).is_not_same(named_main)
	assert_str(main.name).is_equal("Main")
	assert_str(named_main.name).is_equal("Main")

func test_main_logger_global_level_sync():
	var main = manager.get_main_logger()
	
	manager.set_global_level(LogLevel.Level.FATAL)
	assert_int(main.log_level).is_equal(LogLevel.Level.FATAL)

# Test edge cases
func test_logger_name_edge_cases():
	# Test empty name
	var empty_logger = manager.get_logger("")
	assert_str(empty_logger.name).is_equal("")
	
	# Test name with spaces
	var space_logger = manager.get_logger("Logger With Spaces")
	assert_str(space_logger.name).is_equal("Logger With Spaces")
	
	# Test special characters
	var special_logger = manager.get_logger("Logger@#$%")
	assert_str(special_logger.name).is_equal("Logger@#$%")

func test_global_level_extreme_values():
	# Test all possible log levels
	for level in LogLevel.Level.values():
		manager.set_global_level(level)
		assert_int(manager.get_global_level()).is_equal(level)

# Test memory management and cleanup
func test_logger_cleanup():
	# Create many loggers
	for i in range(100):
		manager.get_logger("Logger" + str(i))
	
	assert_int(manager.list_loggers().size()).is_equal(100)
	
	# Remove half of them
	for i in range(50):
		manager.remove_logger("Logger" + str(i))
	
	assert_int(manager.list_loggers().size()).is_equal(50)

# Test concurrent-like scenarios
func test_rapid_logger_creation():
	var logger_names: Array[String] = []
	
	# Rapidly create and access loggers
	for i in range(10):
		var logger_name = "RapidLogger" + str(i)
		logger_names.append(logger_name)
		var logger = manager.get_logger(logger_name)
		logger.info("Message from " + logger_name)
	
	assert_int(manager.list_loggers().size()).is_equal(10)
	
	# Verify all names are present
	var listed_loggers = manager.list_loggers()
	for logger_name in logger_names:
		assert_array(listed_loggers).contains([logger_name])

func test_logger_level_inheritance():
	# Test that new loggers inherit current global level
	manager.set_global_level(LogLevel.Level.WARN)
	var logger1 = manager.get_logger("InheritLogger1")
	
	manager.set_global_level(LogLevel.Level.ERROR)
	var logger2 = manager.get_logger("InheritLogger2")
	
	assert_int(logger1.log_level).is_equal(LogLevel.Level.WARN)
	assert_int(logger2.log_level).is_equal(LogLevel.Level.ERROR)
