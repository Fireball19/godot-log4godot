# test_log_formatter.gd
# Unit tests for LogFormatter class using gdUnit4
extends GdUnitTestSuite

var formatter: LogFormatter

func before_test():
	formatter = LogFormatter.new()

func after_test():
	formatter = null

# Test timestamp functionality
func test_timestamps_enabled_by_default():
	assert_bool(formatter.enable_timestamps).is_true()

func test_set_timestamps_enabled():
	formatter.set_timestamps_enabled(false)
	assert_bool(formatter.enable_timestamps).is_false()
	
	formatter.set_timestamps_enabled(true)
	assert_bool(formatter.enable_timestamps).is_true()

# Test message formatting without timestamps
func test_format_message_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "Test message")
	var expected = "[INFO] [TestLogger] Test message"
	assert_str(result).is_equal(expected)

func test_format_message_main_logger_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Main", LogLevel.Level.ERROR, "Error message")
	var expected = "[ERROR] Error message"
	assert_str(result).is_equal(expected)

func test_format_message_different_levels_without_timestamps():
	formatter.set_timestamps_enabled(false)
	
	var trace_result = formatter.format_message("Test", LogLevel.Level.TRACE, "Trace msg")
	assert_str(trace_result).contains("[TRACE]")
	
	var debug_result = formatter.format_message("Test", LogLevel.Level.DEBUG, "Debug msg")
	assert_str(debug_result).contains("[DEBUG]")
	
	var warn_result = formatter.format_message("Test", LogLevel.Level.WARN, "Warn msg")
	assert_str(warn_result).contains("[WARN]")
	
	var error_result = formatter.format_message("Test", LogLevel.Level.ERROR, "Error msg")
	assert_str(error_result).contains("[ERROR]")
	
	var fatal_result = formatter.format_message("Test", LogLevel.Level.FATAL, "Fatal msg")
	assert_str(fatal_result).contains("[FATAL]")

# Test message formatting with timestamps
func test_format_message_with_timestamps():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "Test message")
	
	# Should contain timestamp pattern [HH:MM:SS.mmm]
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	
	assert_object(timestamp_regex.search(result)).is_not_null()
	assert_str(result).contains("[INFO]")
	assert_str(result).contains("[TestLogger]")
	assert_str(result).contains("Test message")

func test_format_message_with_timestamps_main_logger():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("Main", LogLevel.Level.WARN, "Warning message")
	
	var timestamp_regex = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	
	assert_object(timestamp_regex.search(result)).is_not_null()
	assert_str(result).contains("[WARN]")
	assert_str(result).not_contains("[Main]")
	assert_str(result).contains("Warning message")

# Test timestamp format
func test_timestamp_format():
	var expected_format = "[%02d:%02d:%02d.%03d]"
	assert_str(formatter.timestamp_format).is_equal(expected_format)

# Test empty and special messages
func test_format_empty_message():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.INFO, "")
	var expected = "[INFO] [TestLogger] "
	assert_str(result).is_equal(expected)

func test_format_message_with_spaces():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Test Logger", LogLevel.Level.INFO, "Message with spaces")
	var expected = "[INFO] [Test Logger] Message with spaces"
	assert_str(result).is_equal(expected)

func test_format_message_with_special_characters():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("Test&Logger", LogLevel.Level.INFO, "Message with @#$%")
	var expected = "[INFO] [Test&Logger] Message with @#$%"
	assert_str(result).is_equal(expected)

# Test message parts assembly
func test_message_parts_order():
	formatter.set_timestamps_enabled(false)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.DEBUG, "Test message")
	var parts = result.split(" ")
	
	assert_str(parts[0]).is_equal("[DEBUG]")
	assert_str(parts[1]).is_equal("[TestLogger]")
	assert_str(parts[2]).is_equal("Test")

func test_message_parts_order_with_timestamp():
	formatter.set_timestamps_enabled(true)
	
	var result = formatter.format_message("TestLogger", LogLevel.Level.DEBUG, "Test message")
	var parts = result.split(" ")
	
	# First part should be timestamp
	assert_bool(parts[0].begins_with("[") and parts[0].ends_with("]")).is_true()
	assert_str(parts[1]).is_equal("[DEBUG]")
	assert_str(parts[2]).is_equal("[TestLogger]")

# Test consistency across multiple calls
func test_formatting_consistency():
	formatter.set_timestamps_enabled(false)
	
	var result1 = formatter.format_message("Test", LogLevel.Level.INFO, "Same message")
	var result2 = formatter.format_message("Test", LogLevel.Level.INFO, "Same message")
	
	assert_str(result1).is_equal(result2)

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
	
	assert_object(pattern.search(timestamp)).is_not_null()
