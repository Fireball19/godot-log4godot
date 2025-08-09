# test_log_formatter.gd
# Unit tests for LogFormatter class
extends GutTest

var formatter: LogFormatter

func before_each():
	formatter = LogFormatter.new()

func after_each():
	formatter = null

# Test timestamp functionality
func test_timestamps_enabled_by_default():
	assert_true(formatter.enable_timestamps, "Timestamps should be enabled by default")

func test_set_timestamps_enabled():
	formatter.set_timestamps_enabled(false)
	assert_false(formatter.enable_timestamps, "Should disable timestamps")
	
	formatter.set_timestamps_enabled(true)
	assert_true(formatter.enable_timestamps, "Should enable timestamps")

# Test message formatting without timestamps
func test_format_message_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "Test message")
	var expected = "[INFO] [TestLogger] Test message"
	assert_eq(result, expected, "Should format message without timestamp")

func test_format_message_main_logger_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Main", LogLevel.Level.ERROR, "Error message")
	var expected = "[ERROR] Error message"
	assert_eq(result, expected, "Should format Main logger message without logger name")

func test_format_message_different_levels_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var trace_result = formatter.format_message("Test", LogLevel.Level.TRACE, "Trace msg")
	assert_true(trace_result.contains("[TRACE]"), "Should contain TRACE level")
	
	var debug_result = formatter.format_message("Test", LogLevel.Level.DEBUG, "Debug msg")
	assert_true(debug_result.contains("[DEBUG]"), "Should contain DEBUG level")
	
	var warn_result = formatter.format_message("Test", LogLevel.Level.WARN, "Warn msg")
	assert_true(warn_result.contains("[WARN]"), "Should contain WARN level")
	
	var error_result = formatter.format_message("Test", LogLevel.Level.ERROR, "Error msg")
	assert_true(error_result.contains("[ERROR]"), "Should contain ERROR level")
	
	var fatal_result = formatter.format_message("Test", LogLevel.Level.FATAL, "Fatal msg")
	assert_true(fatal_result.contains("[FATAL]"), "Should contain FATAL level")

# Test message formatting with timestamps
func test_format_message_with_timestamps():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "Test message")
	
	# Should contain timestamp pattern [HH:MM:SS.mmm]
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	
	assert_true(timestamp_regex.search(result) != null, "Should contain timestamp format")
	assert_true(result.contains("[INFO]"), "Should contain log level")
	assert_true(result.contains("[TestLogger]"), "Should contain logger name")
	assert_true(result.contains("Test message"), "Should contain the message")

func test_format_message_with_timestamps_main_logger():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("Main", LogLevel.Level.WARN, "Warning message")
	
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	
	assert_true(timestamp_regex.search(result) != null, "Should contain timestamp format")
	assert_true(result.contains("[WARN]"), "Should contain log level")
	assert_false(result.contains("[Main]"), "Should not contain Main logger name")
	assert_true(result.contains("Warning message"), "Should contain the message")

# Test timestamp format
func test_timestamp_format():
	var expected_format = "[%02d:%02d:%02d.%03d]"
	assert_eq(formatter.timestamp_format, expected_format, "Should have correct timestamp format")

# Test empty and special messages
func test_format_empty_message():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "")
	var expected = "[INFO] [TestLogger] "
	assert_eq(result, expected, "Should handle empty message")

func test_format_message_with_spaces():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Test Logger", LogLevel.Level.INFO, "Message with spaces")
	var expected = "[INFO] [Test Logger] Message with spaces"
	assert_eq(result, expected, "Should handle logger names and messages with spaces")

func test_format_message_with_special_characters():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Test&Logger", LogLevel.Level.INFO, "Message with @#$%")
	var expected = "[INFO] [Test&Logger] Message with @#$%"
	assert_eq(result, expected, "Should handle special characters")

# Test message parts assembly
func test_message_parts_order():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.DEBUG, "Test message")
	var parts = result.split(" ")
	
	assert_eq(parts[0], "[DEBUG]", "First part should be log level")
	assert_eq(parts[1], "[TestLogger]", "Second part should be logger name")
	assert_eq(parts[2], "Test", "Third part should start with message")

func test_message_parts_order_with_timestamp():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.DEBUG, "Test message")
	var parts = result.split(" ")
	
	# First part should be timestamp
	assert_true(parts[0].begins_with("[") and parts[0].ends_with("]"), "First part should be timestamp in brackets")
	assert_eq(parts[1], "[DEBUG]", "Second part should be log level")
	assert_eq(parts[2], "[TestLogger]", "Third part should be logger name")

# Test consistency across multiple calls
func test_formatting_consistency():
	formatter.set_timestamps_enabled(false)
	
	var result1 = formatter.format_message("Test", LogLevel.Level.INFO, "Same message")
	var result2 = formatter.format_message("Test", LogLevel.Level.INFO, "Same message")
	
	assert_eq(result1, result2, "Same inputs should produce same outputs")

# Test private timestamp formatting method indirectly
func test_timestamp_format_indirectly():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("Test", LogLevel.Level.INFO, "Message")
	
	# Extract timestamp part
	var timestamp_start = result.find("[")
	var timestamp_end = result.find("]")
	var timestamp = result.substr(timestamp_start, timestamp_end - timestamp_start + 1)
	
	# Should match pattern [HH:MM:SS.mmm]
	var pattern = RegEx.new()
	pattern.compile(r"^\[\d{2}:\d{2}:\d{2}\.\d{3}\]$")
	
	assert_true(pattern.search(timestamp) != null, "Timestamp should match expected format")
