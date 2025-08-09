# test_integration.gd
# Integration tests for the complete log4godot system using gdUnit4
extends GdUnitTestSuite

var test_file_path: String = "user://test_integration.log"

func before_test():
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	# Reset Logger to default state
	Logger.set_global_level(LogLevel.Level.INFO)
	Logger.set_colors_enabled(true)
	Logger.set_timestamps_enabled(true)
	Logger.set_file_logging_enabled(false)
	
	# Remove any existing named loggers
	var existing_loggers = Logger.list_loggers()
	for logger_name in existing_loggers:
		Logger.remove_logger(logger_name)

func after_test():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	# Clean up any created loggers
	var existing_loggers = Logger.list_loggers()
	for logger_name in existing_loggers:
		Logger.remove_logger(logger_name)

# Test complete logging workflow
func test_complete_logging_workflow():
	# Configure the system
	Logger.set_global_level(LogLevel.Level.DEBUG)
	Logger.set_file_logging_enabled(true, test_file_path)
	Logger.set_timestamps_enabled(false)  # Easier to test without timestamps
	
	# Use main logger
	Logger.info("System initialized")
	Logger.debug("Debug information")
	
	# Create named loggers
	var network_logger = Logger.get_logger("Network", LogLevel.Level.INFO)
	var ai_logger = Logger.get_logger("AI", LogLevel.Level.DEBUG)
	
	# Use named loggers
	network_logger.info("Connection established")
	network_logger.debug("This should not appear (INFO level)")
	ai_logger.debug("AI processing started")
	ai_logger.warn("AI warning message")
	
	# Verify file contents
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# Check main logger messages
	assert_str(content).contains("System initialized")
	assert_str(content).contains("Debug information")
	
	# Check named logger messages
	assert_str(content).contains("[Network] Connection established")
	assert_str(content).not_contains("This should not appear")
	assert_str(content).contains("[AI] AI processing started")
	assert_str(content).contains("[AI] AI warning message")

# Test level hierarchy and filtering
func test_level_hierarchy():
	Logger.set_file_logging_enabled(true, test_file_path)
	Logger.set_timestamps_enabled(false)
	
	# Test different global levels
	var levels_to_test = [
		LogLevel.Level.TRACE,
		LogLevel.Level.DEBUG, 
		LogLevel.Level.INFO,
		LogLevel.Level.WARN,
		LogLevel.Level.ERROR,
		LogLevel.Level.FATAL
	]
	
	for global_level in levels_to_test:
		Logger.set_global_level(global_level)
		Logger.clear_log_file()
		
		# Create logger with lower level than global
		var test_logger = Logger.get_logger("Test", LogLevel.Level.TRACE)
		
		# Try all logging levels
		test_logger.trace("TRACE message")
		test_logger.debug("DEBUG message") 
		test_logger.info("INFO message")
		test_logger.warn("WARN message")
		test_logger.error("ERROR message")
		test_logger.fatal("FATAL message")
		
		var file = FileAccess.open(test_file_path, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		
		# Only messages at or above global level should appear
		for level in LogLevel.Level.values():
			var message = LogLevel.level_to_string(level) + " message"
			var global_level_name = LogLevel.level_to_string(global_level)
			var level_name = LogLevel.level_to_string(level)
			
			if level >= global_level:
				assert_str(content).contains(message).override_failure_message(
					"Level %s should appear when global is %s" % [level_name, global_level_name])
			else:
				assert_str(content).not_contains(message).override_failure_message(
					"Level %s should be filtered when global is %s" % [level_name, global_level_name])

# Test multiple logger interaction
func test_multiple_logger_interaction():
	Logger.set_file_logging_enabled(true, test_file_path)
	Logger.set_timestamps_enabled(false)
	Logger.set_global_level(LogLevel.Level.DEBUG)
	
	# Create multiple loggers with different levels
	var loggers = {
		"System": Logger.get_logger("System", LogLevel.Level.INFO),
		"Network": Logger.get_logger("Network", LogLevel.Level.DEBUG),
		"Database": Logger.get_logger("Database", LogLevel.Level.WARN),
		"UI": Logger.get_logger("UI", LogLevel.Level.ERROR)
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
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
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
func test_runtime_configuration_changes():
	Logger.set_file_logging_enabled(true, test_file_path)
	Logger.set_timestamps_enabled(false)
	
	var test_logger = Logger.get_logger("ConfigTest", LogLevel.Level.DEBUG)
	
	# Initial configuration
	Logger.set_global_level(LogLevel.Level.INFO)
	test_logger.debug("Debug message 1 (should be filtered)")
	test_logger.info("Info message 1")
	
	# Change global level
	Logger.set_global_level(LogLevel.Level.DEBUG)
	test_logger.debug("Debug message 2 (should appear)")
	test_logger.info("Info message 2")
	
	# Change logger's own level
	test_logger.set_level(LogLevel.Level.WARN)
	test_logger.debug("Debug message 3 (should be filtered)")
	test_logger.info("Info message 3 (should be filtered)")
	test_logger.warn("Warn message 1")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).not_contains("Debug message 1")
	assert_str(content).contains("Info message 1")
	assert_str(content).contains("Debug message 2")
	assert_str(content).contains("Info message 2")
	assert_str(content).not_contains("Debug message 3")
	assert_str(content).not_contains("Info message 3")
	assert_str(content).contains("Warn message 1")

# Test file operations
func test_file_operations():
	Logger.set_file_logging_enabled(true, test_file_path)
	Logger.set_timestamps_enabled(false)
	
	# Write some messages
	Logger.info("Initial message")
	Logger.warn("Warning message")
	
	var file1 = FileAccess.open(test_file_path, FileAccess.READ)
	var content1 = file1.get_as_text()
	file1.close()
	
	assert_str(content1).contains("Initial message")
	assert_str(content1).contains("Warning message")
	
	# Clear the log
	Logger.clear_log_file()
	Logger.error("Message after clear")
	
	var file2 = FileAccess.open(test_file_path, FileAccess.READ)
	var content2 = file2.get_as_text()
	file2.close()
	
	assert_str(content2).contains("Log Cleared")
	assert_str(content2).contains("Message after clear")
	assert_str(content2).not_contains("Initial message")
	assert_str(content2).not_contains("Warning message")
