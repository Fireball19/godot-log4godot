# test_log_output.gd
# Unit tests for LogOutput class using gdUnit4
extends GdUnitTestSuite

var output: LogOutput
var test_file_path: String = "user://test_output.log"

func before_test():
	output = LogOutput.new()
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	output = null

# Test initialization
func test_initialization():
	assert_object(output.formatter).is_not_null()
	assert_object(output.file_handler).is_not_null()
	assert_bool(output.enable_colors).is_true()

# Test color configuration
func test_set_colors_enabled():
	output.set_colors_enabled(false)
	assert_bool(output.enable_colors).is_false()
	
	output.set_colors_enabled(true)
	assert_bool(output.enable_colors).is_true()

# Test file logging configuration
func test_set_file_logging_enabled():
	output.set_file_logging_enabled(true, test_file_path)
	
	# File should be created when enabled
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_set_file_logging_disabled():
	output.set_file_logging_enabled(false, test_file_path)
	# Should not create file when disabled
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

# Test log output functionality
func test_output_log_basic():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	# Should create file with content
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test message")
	assert_str(content).contains("INFO")
	assert_str(content).contains("TestLogger")

func test_output_log_main_logger():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Main", LogLevel.Level.ERROR, "Error message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Error message")
	assert_str(content).contains("ERROR")
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
	
	assert_str(content).contains("TRACE")
	assert_str(content).contains("DEBUG")
	assert_str(content).contains("INFO")
	assert_str(content).contains("WARN")
	assert_str(content).contains("ERROR")
	assert_str(content).contains("FATAL")

# Test clear log file
func test_clear_log_file():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "Message before clear")
	
	output.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")
	assert_str(content).not_contains("Message before clear")

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
	assert_object(timestamp_regex.search(content)).is_not_null()

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
	assert_object(timestamp_regex.search(content)).is_null()
	assert_str(content).contains("[INFO]")
	assert_str(content).contains("TestLogger")

# Test edge cases
func test_output_empty_message():
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("[INFO]")

func test_output_special_characters():
	output.set_file_logging_enabled(true, test_file_path)
	var special_message = "Special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	output.output_log("Test", LogLevel.Level.INFO, special_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Special chars")

func test_output_unicode():
	output.set_file_logging_enabled(true, test_file_path)
	var unicode_message = "Unicode: 你好世界 🎮 γειά σας"
	output.output_log("Test", LogLevel.Level.INFO, unicode_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Unicode")

# Test multiple loggers
func test_multiple_loggers():
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("NetworkLogger", LogLevel.Level.INFO, "Network message")
	output.output_log("AILogger", LogLevel.Level.DEBUG, "AI message")
	output.output_log("PhysicsLogger", LogLevel.Level.WARN, "Physics message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("NetworkLogger")
	assert_str(content).contains("AILogger")
	assert_str(content).contains("PhysicsLogger")
	assert_str(content).contains("Network message")
	assert_str(content).contains("AI message")
	assert_str(content).contains("Physics message")

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
	
	assert_str(content).contains("Message with timestamp")
	assert_str(content).contains("Message without timestamp")

# Test that output works without file logging
func test_console_only_output():
	output.set_file_logging_enabled(false)
	# This should not crash and should output to console only
	output.output_log("Test", LogLevel.Level.INFO, "Console only message")
	
	# File should not be created
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

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
	assert_str(content).contains("[ERROR]")
	assert_str(content).contains("[TestLogger]")
	assert_str(content).contains("Test error")

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
	assert_int(non_empty_lines.size()).is_greater_equal(3)
