# test_log_output.gd
# Unit tests for LogOutput class using gdUnit4
extends GdUnitTestSuite

var output: LogOutput
var test_file_path: String = "user://test_output.log"

func before_test() -> void:
	output = LogOutput.new()
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test() -> void:
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	output = null

# Test initialization
func test_initialization() -> void:
	assert_object(output.formatter).is_not_null()
	assert_object(output.file_handler).is_not_null()
	assert_bool(output.enable_colors).is_true()

# Test color configuration
func test_set_colors_enabled() -> void:
	output.set_colors_enabled(false)
	assert_bool(output.enable_colors).is_false()
	
	output.set_colors_enabled(true)
	assert_bool(output.enable_colors).is_true()

# Test file logging configuration
func test_set_file_logging_enabled() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	
	# File should be created when enabled
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_set_file_logging_disabled() -> void:
	output.set_file_logging_enabled(false, test_file_path)
	# Should not create file when disabled
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

# Test log output functionality
func test_output_log_basic() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	# Should create file with content
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test message")
	assert_str(content).contains("INFO")
	assert_str(content).contains("TestLogger")

func test_output_log_main_logger() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Main", LogLevel.Level.ERROR, "Error message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Error message")
	assert_str(content).contains("ERROR")
	# Main logger name should not appear in formatted message for Main logger

func test_output_log_different_levels() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("Test", LogLevel.Level.TRACE, "Trace message")
	output.output_log("Test", LogLevel.Level.DEBUG, "Debug message")
	output.output_log("Test", LogLevel.Level.INFO, "Info message")
	output.output_log("Test", LogLevel.Level.WARN, "Warn message")
	output.output_log("Test", LogLevel.Level.ERROR, "Error message")
	output.output_log("Test", LogLevel.Level.FATAL, "Fatal message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("TRACE")
	assert_str(content).contains("DEBUG")
	assert_str(content).contains("INFO")
	assert_str(content).contains("WARN")
	assert_str(content).contains("ERROR")
	assert_str(content).contains("FATAL")

# Test clear log file
func test_clear_log_file() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "Message before clear")
	
	output.clear_log_file()
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")
	assert_str(content).not_contains("Message before clear")

# Test console output formatting (indirectly through file output)
func test_output_formatting_with_timestamps() -> void:
	output.set_timestamps_enabled(true)
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Should contain timestamp pattern
	var timestamp_regex: RegEx = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	assert_object(timestamp_regex.search(content)).is_not_null()

func test_output_formatting_without_timestamps() -> void:
	output.set_timestamps_enabled(false)
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("TestLogger", LogLevel.Level.INFO, "Test message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Should not contain timestamp pattern
	var timestamp_regex: RegEx = RegEx.new()
	timestamp_regex.compile(r"\[\d{2}:\d{2}:\d{2}\.\d{3}\]")
	assert_object(timestamp_regex.search(content)).is_null()
	assert_str(content).contains("[INFO]")
	assert_str(content).contains("TestLogger")

# Test edge cases
func test_output_empty_message() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log("Test", LogLevel.Level.INFO, "")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("[INFO]")

func test_output_special_characters() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	var special_message: String = "Special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	output.output_log("Test", LogLevel.Level.INFO, special_message)
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Special chars")

func test_output_unicode() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	var unicode_message: String = "Unicode: 你好世界 🎮 γειά σας"
	output.output_log("Test", LogLevel.Level.INFO, unicode_message)
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Unicode")

# Test multiple loggers
func test_multiple_loggers() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("NetworkLogger", LogLevel.Level.INFO, "Network message")
	output.output_log("AILogger", LogLevel.Level.DEBUG, "AI message")
	output.output_log("PhysicsLogger", LogLevel.Level.WARN, "Physics message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("NetworkLogger")
	assert_str(content).contains("AILogger")
	assert_str(content).contains("PhysicsLogger")
	assert_str(content).contains("Network message")
	assert_str(content).contains("AI message")
	assert_str(content).contains("Physics message")

# Test configuration changes don't affect existing logs
func test_configuration_changes() -> void:
	output.set_file_logging_enabled(true, test_file_path)
	output.set_timestamps_enabled(true)
	
	output.output_log("Test", LogLevel.Level.INFO, "Message with timestamp")
	
	output.set_timestamps_enabled(false)
	output.output_log("Test", LogLevel.Level.INFO, "Message without timestamp")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Message with timestamp")
	assert_str(content).contains("Message without timestamp")

# Test that output works without file logging
func test_console_only_output() -> void:
	output.set_file_logging_enabled(false)
	# This should not crash and should output to console only
	output.output_log("Test", LogLevel.Level.INFO, "Console only message")
	
	# File should not be created
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

# Test internal component interaction
func test_formatter_integration() -> void:
	output.set_timestamps_enabled(false)
	output.set_file_logging_enabled(true, test_file_path)
	
	# The formatter should be called and format the message
	output.output_log("TestLogger", LogLevel.Level.ERROR, "Test error")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Should contain formatted output with all components
	assert_str(content).contains("[ERROR]")
	assert_str(content).contains("[TestLogger]")
	assert_str(content).contains("Test error")

func test_file_handler_integration() -> void:
	# Test that file handler is properly integrated
	output.set_file_logging_enabled(true, test_file_path)
	
	output.output_log("Test", LogLevel.Level.INFO, "First message")
	output.output_log("Test", LogLevel.Level.INFO, "Second message")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	var lines: PackedStringArray = content.split("\n")
	var non_empty_lines: Array[String] = []
	for line: String in lines:
		if not line.is_empty():
			non_empty_lines.append(line)
	
	# Should have session start line plus our two messages
	assert_int(non_empty_lines.size()).is_greater_equal(3)

# Test signal emission
func test_log_emitted_signal_exists() -> void:
	assert_bool(output.has_signal("log_emitted")).is_true()

func test_log_emitted_signal_emits() -> void:
	var signal_received: Dictionary[String, bool] = { "value": false }
	var received_timestamp: Dictionary[String, String] = { "value": "" }
	var received_logger_name: Dictionary[String, StringName] = { "value": &"" }
	var received_level: Dictionary[String, LogLevel.Level] = { "value": LogLevel.Level.TRACE }
	var received_message: Dictionary[String, String] = { "value": "" }
	
	output.log_emitted.connect(func(ts: String, ln: StringName, lv: LogLevel.Level, msg: String) -> void:
		signal_received.set("value", true)
		received_timestamp.set("value", ts)
		received_logger_name.set("value", ln)
		received_level.set("value", lv)
		received_message.set("value", msg)
	)
	
	output.output_log(&"TestLogger", LogLevel.Level.INFO, "Test message")
	
	assert_bool(signal_received.get("value")).is_true()
	# Timestamp should be in format HH:MM:SS.mmm
	var timestamp_regex: RegEx = RegEx.new()
	timestamp_regex.compile(r"\d{2}:\d{2}:\d{2}\.\d{3}")
	var timestamp: String = received_timestamp.get("value")
	assert_object(timestamp_regex.search(timestamp)).is_not_null()
	assert_str(received_logger_name.get("value")).is_equal("TestLogger")
	assert_int(received_level.get("value")).is_equal(LogLevel.Level.INFO)
	assert_str(received_message.get("value")).is_equal("Test message")

func test_log_emitted_timestamp_format() -> void:
	var received_timestamp: Dictionary[String, String] = { "value": "" }
	
	output.log_emitted.connect(func(ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		received_timestamp.set("value", ts)
	)
	
	output.output_log(&"Test", LogLevel.Level.INFO, "Message")
	
	# Timestamp should be in format HH:MM:SS.mmm
	var timestamp_regex: RegEx = RegEx.new()
	timestamp_regex.compile(r"\d{2}:\d{2}:\d{2}\.\d{3}")
	var timestamp: String = received_timestamp.get("value")
	assert_object(timestamp_regex.search(timestamp)).is_not_null()

func test_log_emitted_different_levels() -> void:
	var received_levels: Array[LogLevel.Level] = []
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, lv: LogLevel.Level, _msg: String) -> void:
		received_levels.append(lv)
	)
	
	output.output_log(&"Test", LogLevel.Level.TRACE, "Trace")
	output.output_log(&"Test", LogLevel.Level.DEBUG, "Debug")
	output.output_log(&"Test", LogLevel.Level.INFO, "Info")
	output.output_log(&"Test", LogLevel.Level.WARN, "Warn")
	output.output_log(&"Test", LogLevel.Level.ERROR, "Error")
	output.output_log(&"Test", LogLevel.Level.FATAL, "Fatal")
	
	assert_int(received_levels.size()).is_equal(6)
	assert_int(received_levels[0]).is_equal(LogLevel.Level.TRACE)
	assert_int(received_levels[1]).is_equal(LogLevel.Level.DEBUG)
	assert_int(received_levels[2]).is_equal(LogLevel.Level.INFO)
	assert_int(received_levels[3]).is_equal(LogLevel.Level.WARN)
	assert_int(received_levels[4]).is_equal(LogLevel.Level.ERROR)
	assert_int(received_levels[5]).is_equal(LogLevel.Level.FATAL)

func test_log_emitted_different_loggers() -> void:
	var received_logger_names: Array[StringName] = []
	
	output.log_emitted.connect(func(_ts: String, ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		received_logger_names.append(ln)
	)
	
	output.output_log(&"Network", LogLevel.Level.INFO, "Message 1")
	output.output_log(&"AI", LogLevel.Level.INFO, "Message 2")
	output.output_log(&"Physics", LogLevel.Level.INFO, "Message 3")
	
	assert_int(received_logger_names.size()).is_equal(3)
	assert_str(received_logger_names[0]).is_equal("Network")
	assert_str(received_logger_names[1]).is_equal("AI")
	assert_str(received_logger_names[2]).is_equal("Physics")

func test_log_emitted_multiple_subscribers() -> void:
	var subscriber1_count: Dictionary[String, int] = { "value": 0 }
	var subscriber2_count: Dictionary[String, int] = { "value": 0 }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		subscriber1_count.set("value", subscriber1_count.get("value") + 1)
	)
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		subscriber2_count.set("value", subscriber2_count.get("value") + 1)
	)
	
	output.output_log(&"Test", LogLevel.Level.INFO, "Message")
	
	assert_int(subscriber1_count.get("value")).is_equal(1)
	assert_int(subscriber2_count.get("value")).is_equal(1)

func test_log_emitted_special_characters() -> void:
	var received_message: Dictionary[String, String] = { "value": "" }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, msg: String) -> void:
		received_message.set("value", msg)
	)
	
	var special_msg: String = "Special: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	output.output_log(&"Test", LogLevel.Level.INFO, special_msg)
	
	assert_str(received_message.get("value")).is_equal(special_msg)

func test_log_emitted_unicode() -> void:
	var received_message: Dictionary[String, String] = { "value": "" }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, msg: String) -> void:
		received_message.set("value", msg)
	)
	
	var unicode_msg: String = "Unicode: 你好世界 🎮 γειά σας"
	output.output_log(&"Test", LogLevel.Level.INFO, unicode_msg)
	
	assert_str(received_message.get("value")).is_equal(unicode_msg)

func test_log_emitted_empty_message() -> void:
	var received_message: Dictionary[String, String] = { "value": "not_empty" }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, msg: String) -> void:
		received_message.set("value", msg)
	)
	
	output.output_log(&"Test", LogLevel.Level.INFO, "")
	
	assert_str(received_message.get("value")).is_equal("")

func test_signal_emits_before_console_output() -> void:
	# This test verifies signal is emitted (we can't easily verify order,
	# but we can verify both happen)
	var signal_emitted: Dictionary[String, bool]  = { "value": false }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		signal_emitted.set("value", true)
	)
	
	output.output_log(&"Test", LogLevel.Level.INFO, "Message")
	
	assert_bool(signal_emitted.get("value")).is_true()

func test_signal_emits_with_file_logging() -> void:
	var signal_emitted: Dictionary[String, bool]  = { "value": false }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		signal_emitted.set("value", true)
	)
	
	output.set_file_logging_enabled(true, test_file_path)
	output.output_log(&"Test", LogLevel.Level.INFO, "Message")
	
	assert_bool(signal_emitted.get("value")).is_true()
	# Also verify file was written
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_signal_emits_without_file_logging() -> void:
	var signal_emitted: Dictionary[String, bool]  = { "value": false }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		signal_emitted.set("value", true)
	)
	
	output.set_file_logging_enabled(false)
	output.output_log(&"Test", LogLevel.Level.INFO, "Message")
	
	assert_bool(signal_emitted.get("value")).is_true()

func test_disconnected_signal_no_error() -> void:
	var connection_count: Dictionary[String, int] = { "value": 0 }
	
	var callback: Callable = func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		connection_count.set("value", connection_count.get("value") + 1)
	
	output.log_emitted.connect(callback)
	output.output_log(&"Test", LogLevel.Level.INFO, "Message 1")
	
	output.log_emitted.disconnect(callback)
	output.output_log(&"Test", LogLevel.Level.INFO, "Message 2")
	
	# Only first message should have been counted
	assert_int(connection_count.get("value")).is_equal(1)

# Test _get_timestamp internal method
func test_get_timestamp_format() -> void:
	var timestamp: String = output._get_timestamp()
	
	# Should match HH:MM:SS.mmm format
	var timestamp_regex: RegEx = RegEx.new()
	timestamp_regex.compile(r"^\d{2}:\d{2}:\d{2}\.\d{3}$")
	assert_object(timestamp_regex.search(timestamp)).is_not_null()

func test_get_timestamp_valid_values() -> void:
	var timestamp: String = output._get_timestamp()
	var parts: PackedStringArray = timestamp.split(":")
	
	assert_int(parts.size()).is_equal(3)
	
	var hour: int = int(parts[0])
	var minute: int = int(parts[1])
	var second_ms: PackedStringArray = parts[2].split(".")
	var second: int = int(second_ms[0])
	var ms: int = int(second_ms[1])
	
	assert_int(hour).is_between(0, 23)
	assert_int(minute).is_between(0, 59)
	assert_int(second).is_between(0, 59)
	assert_int(ms).is_between(0, 999)

# Test rapid signal emission
func test_rapid_signal_emission() -> void:
	var received_count: Dictionary[String, int] = { "value": 0 }
	
	output.log_emitted.connect(func(_ts: String, _ln: StringName, _lv: LogLevel.Level, _msg: String) -> void:
		received_count.set("value", received_count.get("value") + 1)
	)
	
	for i: int in range(100):
		output.output_log(&"Test", LogLevel.Level.INFO, "Message " + str(i))
	
	assert_int(received_count.get("value")).is_equal(100)
