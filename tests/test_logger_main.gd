# test_logger_main.gd
# Unit tests for the main Logger autoload class using gdUnit4
extends GdUnitTestSuite

var logger_node: GlobalLogger
var test_file_path: String = "user://test_main_logger.log"

func before_test() -> void:
	# Create a Logger instance for testing (simulating the autoload)
	logger_node = preload("res://addons/log4godot/logger.gd").new()
	logger_node._ready()
	
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test() -> void:
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	if logger_node:
		logger_node.free()
	logger_node = null

# Test initialization
func test_logger_initialization() -> void:
	assert_object(logger_node.manager).is_not_null()

# Test configuration methods
func test_set_get_global_level() -> void:
	logger_node.set_global_level(LogLevel.Level.ERROR)
	assert_int(logger_node.get_global_level()).is_equal(LogLevel.Level.ERROR)

func test_set_colors_enabled() -> void:
	logger_node.set_colors_enabled(false)
	assert_bool(logger_node.manager.output.enable_colors).is_false()
	
	logger_node.set_colors_enabled(true)
	assert_bool(logger_node.manager.output.enable_colors).is_true()

func test_set_file_logging_enabled() -> void:
	logger_node.set_file_logging_enabled(true, test_file_path)
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_clear_log_file() -> void:
	logger_node.set_file_logging_enabled(true, test_file_path)
	var logger: LoggerInstance = logger_node.get_logger("TestLogger")
	logger.info("Message before clear")
	logger_node.clear_log_file()
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")

# Test named logger management
func test_get_logger() -> void:
	var named_logger: LoggerInstance = logger_node.get_logger("TestLogger")
	
	assert_object(named_logger).is_not_null()
	assert_str(named_logger.name).is_equal("TestLogger")

func test_get_logger_with_level() -> void:
	var named_logger: LoggerInstance = logger_node.get_logger("TestLogger", LogLevel.Level.ERROR)
	assert_int(named_logger.log_level).is_equal(LogLevel.Level.ERROR)

func test_get_logger_default_level() -> void:
	var named_logger: LoggerInstance = logger_node.get_logger("TestLogger")
	assert_int(named_logger.log_level).is_equal(LogLevel.Level.INFO)

func test_remove_logger() -> void:
	logger_node.get_logger("ToRemove")
	var removed: bool = logger_node.remove_logger("ToRemove")
	assert_bool(removed).is_true()
	
	var not_removed: bool = logger_node.remove_logger("NonExistent")
	assert_bool(not_removed).is_false()

func test_list_loggers() -> void:
	logger_node.get_logger("Logger1")
	logger_node.get_logger("Logger2")
	
	var loggers: Array[String] = logger_node.list_loggers()
	assert_int(loggers.size()).is_equal(2)
	assert_array(loggers).contains(["Logger1"])
	assert_array(loggers).contains(["Logger2"])

# Test utility methods
func test_log_level_from_string() -> void:
	assert_int(logger_node.log_level_from_string("DEBUG")).is_equal(LogLevel.Level.DEBUG)
	assert_int(logger_node.log_level_from_string("invalid")).is_equal(LogLevel.Level.INFO)

func test_log_level_to_string() -> void:
	assert_str(logger_node.log_level_to_string(LogLevel.Level.ERROR)).is_equal("ERROR")

# Test integration scenarios
func test_named_logger_logging() -> void:
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	var named: LoggerInstance = logger_node.get_logger("Named")
	named.info("Named logger message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Named logger message")
	assert_str(content).contains("[Named]")

func test_level_filtering_with_named_logger() -> void:
	logger_node.set_global_level(LogLevel.Level.WARN)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	var logger: LoggerInstance = logger_node.get_logger("FilterTest", LogLevel.Level.DEBUG)
	
	# These should be filtered out by global level
	logger.debug("Debug message")
	logger.info("Info message")
	
	# These should pass through
	logger.warn("Warn message")
	logger.error("Error message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).not_contains("Debug message")
	assert_str(content).not_contains("Info message")
	assert_str(content).contains("Warn message")
	assert_str(content).contains("Error message")

func test_configuration_persistence() -> void:
	# Test that configuration changes persist across operations
	logger_node.set_global_level(LogLevel.Level.ERROR)
	logger_node.set_colors_enabled(false)
	logger_node.set_timestamps_enabled(true)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	# Create and use a named logger
	var named: LoggerInstance = logger_node.get_logger("Persistent")
	named.error("Test error message")
	
	# Verify configuration is still applied
	assert_int(logger_node.get_global_level()).is_equal(LogLevel.Level.ERROR)
	assert_bool(logger_node.manager.output.enable_colors).is_false()
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test error message")

func test_multiple_named_loggers() -> void:
	logger_node.set_global_level(LogLevel.Level.DEBUG)
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	var network_logger: LoggerInstance = logger_node.get_logger("Network", LogLevel.Level.DEBUG)
	var ai_logger: LoggerInstance = logger_node.get_logger("AI", LogLevel.Level.INFO)
	var physics_logger: LoggerInstance = logger_node.get_logger("Physics", LogLevel.Level.WARN)
	
	network_logger.debug("Network debug")
	ai_logger.info("AI info")
	physics_logger.warn("Physics warn")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("[Network]")
	assert_str(content).contains("[AI]")
	assert_str(content).contains("[Physics]")
	assert_str(content).contains("Network debug")
	assert_str(content).contains("AI info")
	assert_str(content).contains("Physics warn")

# Test theme management
func test_get_available_themes() -> void:
	var themes: Array[String] = logger_node.get_available_themes()
	assert_array(themes).contains(["Default"])
	assert_array(themes).contains(["Minimal"])
	assert_array(themes).contains(["Whiteout"])
	assert_array(themes).contains(["Fallout"])

func test_set_theme_by_name() -> void:
	var result: bool = logger_node.set_theme_by_name("Minimal")
	assert_bool(result).is_true()
	assert_str(logger_node.get_current_theme().theme_name).is_equal("Minimal")

func test_set_theme_by_name_invalid() -> void:
	var result: bool = logger_node.set_theme_by_name("NonExistent")
	assert_bool(result).is_false()

func test_get_theme_by_name() -> void:
	var theme: LogTheme = logger_node.get_theme_by_name("Default")
	assert_object(theme).is_not_null()
	assert_str(theme.theme_name).is_equal("Default")
