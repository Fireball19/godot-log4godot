# test_log_output.gd
# Unit tests for LogOutput class
extends GutTest

var output: LogOutput
var test_file_path: String = "user://test_output.log"

func before_each():
	output = LogOutput.new()
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_each():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	output = null

# Test initialization
func test_initialization():
	assert_not_null(output.formatter, "Should have formatter instance")
	assert_not_null(output.file_handler, "Should have file handler instance")
	assert_true(output.enable_colors, "Colors should be enabled by default")

# Test color configuration
func test_set_colors_enabled():
	output.set_colors_enabled(false)
	assert_false(output.enable_colors, "Should disable colors")
	
	output.set_colors_enabled(true)
	assert_true(output.enable_colors, "Should enable colors")

# Test file logging configuration
func test_set_file_logging_enabled():
	output.set_file_logging_enabled(true, test_file_path)
	
	# File should be created when enabled
	assert_true(FileAccess.file_exists(test_file_path), "Should create file when enabled")

func test_set_file_logging_disabled():
	output.set_file_logging_enabled(false, test_file_path)
	# Should not create file when disabled
	assert_false(FileAccess.file_exists(test_file_path), "Should not create file when disabled")

# Test log output functionality
func test_output_log_basic():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	# Should create file with content
	assert_true(FileAccess.file_exists(test_file_path), "Should create log file")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Test message"), "Should contain the message")
	assert_true(content.contains("INFO"), "Should contain log level")
	assert_true(content.contains("TestLogger"), "Should contain logger name")

func test_output_log_main_logger():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Main", LogLevel.Level.ERROR, "Error message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Error message"), "Should contain the message")
	assert_true(content.contains("ERROR"), "Should contain log level")
	# Main logger name should not appear in formatted message for Main logger

func test_output_log_different_levels():
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("Test", LogLevel.Level.TRACE, "Trace message")
	output.output_log("Test", LogLevel.Level.DEBUG, "Debug message")
	output.output_log("Test", LogLevel.Level.INFO, "Info message")
	output.output_log("Test", LogLevel.Level.WARN, "Warn message")
	output.output_log("Test", LogLevel.Level.ERROR, "Error message")
	output.output_log("Test", LogLevel.Level.FATAL, "Fatal message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("TRACE"), "Should contain TRACE level")
	assert_true(content.contains("DEBUG"), "Should contain DEBUG level")
	assert_true(content.contains("INFO"), "Should contain INFO level")
	assert_true(content.contains("WARN"), "Should contain WARN level")
	assert_true(content.contains("ERROR"), "Should contain ERROR level")
	assert_true(content.contains("FATAL"), "Should contain FATAL level")

# Test clear log file
func test_clear_log_file():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "Message before clear")
	
	output.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Log Cleared"), "Should contain clear message")
	assert_false(content.contains("Message before clear"), "Should not contain old messages")

# Test console output formatting (indirectly through file output)
func test_output_formatting_with_timestamps():
	output.set_timestamps_enabled(true)
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# Should contain timestamp pattern
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	assert_true(timestamp_regex.search(content) != null, "Should contain timestamp")

func test_output_formatting_without_timestamps():
	output.set_timestamps_enabled(false)
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# Should not contain timestamp pattern
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	assert_true(timestamp_regex.search(content) == null, "Should not contain timestamp")
	assert_true(content.contains("[INFO]"), "Should contain log level")
	assert_true(content.contains("TestLogger"), "Should contain logger name")

# Test edge cases
func test_output_empty_message():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("[INFO]"), "Should still contain log level for empty message")

func test_output_special_characters():
	output.set_file_logging_enabled(true, test_file_path)
	var special_message = "Special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	output.output_log("Test", LogLevel.Level.INFO, special_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Special chars"), "Should handle special characters")

func test_output_unicode():
	output.set_file_logging_enabled(true, test_file_path)
	var unicode_message = "Unicode: 你好世界 🎮 γειά σας"
	output.output_log("Test", LogLevel.Level.INFO, unicode_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Unicode"), "Should handle unicode characters")

# Test multiple loggers
func test_multiple_loggers():
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("NetworkLogger", LogLevel.Level.INFO, "Network message")
	output.output_log("AILogger", LogLevel.Level.DEBUG, "AI message")
	output.output_log("PhysicsLogger", LogLevel.Level.WARN, "Physics message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("NetworkLogger"), "Should contain NetworkLogger")
	assert_true(content.contains("AILogger"), "Should contain AILogger")
	assert_true(content.contains("PhysicsLogger"), "Should contain PhysicsLogger")
	assert_true(content.contains("Network message"), "Should contain network message")
	assert_true(content.contains("AI message"), "Should contain AI message")
	assert_true(content.contains("Physics message"), "Should contain physics message")

# Test configuration changes don't affect existing logs
func test_configuration_changes():
	output.set_file_logging_enabled(true, test_file_path)
	output.set_timestamps_enabled(true)
	
	output.output_log("Test", LogLevel.Level.INFO, "Message with timestamp")
	
	output.set_timestamps_enabled(false)
	output.output_log("Test", LogLevel.Level.INFO, "Message without timestamp")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Message with timestamp"), "Should contain first message")
	assert_true(content.contains("Message without timestamp"), "Should contain second message")

# Test that output works without file logging
func test_console_only_output():
	output.set_file_logging_enabled(false)
	# This should not crash and should output to console only
	output.output_log("Test", LogLevel.Level.INFO, "Console only message")
	
	# File should not be created
	assert_false(FileAccess.file_exists(test_file_path), "Should not create file when file logging disabled")

# Test internal component interaction
func test_formatter_integration():
	output.set_timestamps_enabled(false)
	output.set_file_logging_enabled(true, test_file_path)
	
	# The formatter should be called and format the message
	output.output_log("TestLogger", LogLevel.Level.ERROR, "Test error")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	# Should contain formatted output with all components
	assert_true(content.contains("[ERROR]"), "Should contain formatted log level")
	assert_true(content.contains("[TestLogger]"), "Should contain formatted logger name")
	assert_true(content.contains("Test error"), "Should contain message")

func test_file_handler_integration():
	# Test that file handler is properly integrated
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("Test", LogLevel.Level.INFO, "First message")
	output.output_log("Test", LogLevel.Level.INFO, "Second message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var non_empty_lines = []
	for line in lines:
		if not line.is_empty():
			non_empty_lines.append(line)
	
	# Should have session start line plus our two messages
	assert_true(non_empty_lines.size() >= 3, "Should have session start and both messages")
