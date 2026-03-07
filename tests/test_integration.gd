# test_integration.gd
# Integration tests for the complete log4godot system using gdUnit4
extends GdUnitTestSuite

var test_file_path: String = "user://test_integration.log"

@onready
var logger: LoggerInstance = Log4g.get_logger_for(self, LogLevel.Level.DEBUG)

func before_test() -> void:
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	# Reset Logger to default state
	Log4g.set_global_level(LogLevel.Level.INFO)
	Log4g.set_colors_enabled(true)
	Log4g.set_timestamps_enabled(true)
	Log4g.set_file_logging_enabled(false)
	
	# Remove any existing named loggers
	var existing_loggers: Array[String] = Log4g.list_loggers()
	for logger_name: String in existing_loggers:
		Log4g.remove_logger(logger_name)

func after_test() -> void:
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	# Clean up any created loggers
	var existing_loggers: Array[String] = Log4g.list_loggers()
	for logger_name: String in existing_loggers:
		Log4g.remove_logger(logger_name)

# Test complete logging workflow
func test_complete_logging_workflow() -> void:
	# Configure the system
	Log4g.set_global_level(LogLevel.Level.DEBUG)
	Log4g.set_file_logging_enabled(true, test_file_path)
	Log4g.set_timestamps_enabled(false)  # Easier to test without timestamps
	
	# Use main logger
	logger.info("System initialized")
	logger.debug("Debug information")
	
	# Create named loggers
	var network_logger: LoggerInstance = Log4g.get_logger("Network", LogLevel.Level.INFO)
	var ai_logger: LoggerInstance = Log4g.get_logger("AI", LogLevel.Level.DEBUG)
	
	# Use named loggers
	network_logger.info("Connection established")
	network_logger.debug("This should not appear (INFO level)")
	ai_logger.debug("AI processing started")
	ai_logger.warn("AI warning message")
	
	# Verify file contents
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Check main logger messages
	assert_str(content).contains("[TestIntegration] System initialized")
	assert_str(content).contains("[TestIntegration] Debug information")
	
	# Check named logger messages
	assert_str(content).contains("[Network] Connection established")
	assert_str(content).not_contains("This should not appear")
	assert_str(content).contains("[AI] AI processing started")
	assert_str(content).contains("[AI] AI warning message")

# Test level hierarchy and filtering
func test_level_hierarchy() -> void:
	Log4g.set_file_logging_enabled(true, test_file_path)
	Log4g.set_timestamps_enabled(false)
	
	# Test different global levels
	var levels_to_test: Array[LogLevel.Level] = [
		LogLevel.Level.TRACE,
		LogLevel.Level.DEBUG, 
		LogLevel.Level.INFO,
		LogLevel.Level.WARN,
		LogLevel.Level.ERROR,
		LogLevel.Level.FATAL
	]
	
	for global_level: LogLevel.Level in levels_to_test:
		Log4g.set_global_level(global_level)
		Log4g.clear_log_file()
		
		# Create logger with lower level than global
		var test_logger: LoggerInstance = Log4g.get_logger("Test", LogLevel.Level.TRACE)
		
		# Try all logging levels
		test_logger.trace("TRACE message")
		test_logger.debug("DEBUG message") 
		test_logger.info("INFO message")
		test_logger.warn("WARN message")
		test_logger.error("ERROR message")
		test_logger.fatal("FATAL message")
		
		var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
		var content: String = file.get_as_text()
		file.close()
		
		# Only messages at or above global level should appear
		for level: LogLevel.Level in LogLevel.Level.values():
			var message: String = LogLevel.level_to_string(level) + " message"
			var global_level_name: String = LogLevel.level_to_string(global_level)
			var level_name: String = LogLevel.level_to_string(level)
			
			if level >= global_level:
				assert_str(content).contains(message).override_failure_message(
					"Level %s should appear when global is %s" % [level_name, global_level_name])
			else:
				assert_str(content).not_contains(message).override_failure_message(
					"Level %s should be filtered when global is %s" % [level_name, global_level_name])

# Test multiple logger interaction
func test_multiple_logger_interaction() -> void:
	Log4g.set_file_logging_enabled(true, test_file_path)
	Log4g.set_timestamps_enabled(false)
	Log4g.set_global_level(LogLevel.Level.DEBUG)
	
	# Create multiple loggers with different levels
	var loggers: Dictionary[String, LoggerInstance] = {
		"System": Log4g.get_logger("System", LogLevel.Level.INFO),
		"Network": Log4g.get_logger("Network", LogLevel.Level.DEBUG),
		"Database": Log4g.get_logger("Database", LogLevel.Level.WARN),
		"UI": Log4g.get_logger("UI", LogLevel.Level.ERROR)
	}
	
	# Each logger logs at different levels
	loggers.System.debug("System debug (filtered)")
	loggers.System.info("System info")
	loggers.System.error("System error")
	
	loggers.Network.debug("Network debug")
	loggers.Network.info("Network info")
	loggers.Network.warn("Network warn")
	
	loggers.Database.debug("Database debug (filtered)")
	loggers.Database.info("Database info (filtered)")
	loggers.Database.warn("Database warn")
	loggers.Database.error("Database error")
	
	loggers.UI.warn("UI warn (filtered)")
	loggers.UI.error("UI error")
	loggers.UI.fatal("UI fatal")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Verify filtering based on logger levels
	assert_str(content).not_contains("System debug (filtered)")
	assert_str(content).contains("[System] System info")
	assert_str(content).contains("[System] System error")
	
	assert_str(content).contains("[Network] Network debug")
	assert_str(content).contains("[Network] Network info")
	assert_str(content).contains("[Network] Network warn")
	
	assert_str(content).not_contains("Database debug (filtered)")
	assert_str(content).not_contains("Database info (filtered)")
	assert_str(content).contains("[Database] Database warn")
	assert_str(content).contains("[Database] Database error")
	
	assert_str(content).not_contains("UI warn (filtered)")
	assert_str(content).contains("[UI] UI error")
	assert_str(content).contains("[UI] UI fatal")

# Test configuration changes during runtime
func test_runtime_configuration_changes() -> void:
	Log4g.set_file_logging_enabled(true, test_file_path)
	Log4g.set_timestamps_enabled(false)
	
	var test_logger: LoggerInstance = Log4g.get_logger("ConfigTest", LogLevel.Level.DEBUG)
	
	# Initial configuration
	Log4g.set_global_level(LogLevel.Level.INFO)
	test_logger.debug("Debug message 1 (should be filtered)")
	test_logger.info("Info message 1")
	
	# Change global level
	Log4g.set_global_level(LogLevel.Level.DEBUG)
	test_logger.debug("Debug message 2 (should appear)")
	test_logger.info("Info message 2")
	
	# Change logger's own level
	test_logger.set_level(LogLevel.Level.WARN)
	test_logger.debug("Debug message 3 (should be filtered)")
	test_logger.info("Info message 3 (should be filtered)")
	test_logger.warn("Warn message 1")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).not_contains("Debug message 1")
	assert_str(content).contains("Info message 1")
	assert_str(content).contains("Debug message 2")
	assert_str(content).contains("Info message 2")
	assert_str(content).not_contains("Debug message 3")
	assert_str(content).not_contains("Info message 3")
	assert_str(content).contains("Warn message 1")

# Test file operations
func test_file_operations() -> void:
	Log4g.set_file_logging_enabled(true, test_file_path)
	Log4g.set_timestamps_enabled(false)
	
	# Write some messages
	logger.info("Initial message")
	logger.warn("Warning message")
	
	var file1: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content1: String = file1.get_as_text()
	file1.close()
	
	assert_str(content1).contains("Initial message")
	assert_str(content1).contains("Warning message")
	
	# Clear the log
	Log4g.clear_log_file()
	logger.error("Message after clear")
	
	var file2: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content2: String = file2.get_as_text()
	file2.close()
	
	assert_str(content2).contains("Log Cleared")
	assert_str(content2).contains("Message after clear")
	assert_str(content2).not_contains("Initial message")
	assert_str(content2).not_contains("Warning message")
