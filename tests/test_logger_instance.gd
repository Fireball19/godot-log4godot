# test_logger_instance.gd
# Unit tests for LoggerInstance class
extends GutTest

var logger_instance: LoggerInstance
var mock_output: MockLogOutput
var test_file_path: String = "user://test_logger_instance.log"

class MockLogOutput extends LogOutput:
	var logged_messages: Array[Dictionary] = []
	
	func output_log(logger_name: String, level: LogLevel.Level, message: String) -> void:
		logged_messages.append({
			"logger_name": logger_name,
			"level": level,
			"message": message
		})
	
	func get_last_message() -> Dictionary:
		if logged_messages.size() > 0:
			return logged_messages[-1]
		return {}
	
	func clear_messages() -> void:
		logged_messages.clear()

func mock_global_level_provider() -> LogLevel.Level:
	return LogLevel.Level.TRACE

func before_each():
	mock_output = MockLogOutput.new()
	logger_instance = LoggerInstance.new("TestLogger", LogLevel.Level.INFO, mock_output, mock_global_level_provider)

func after_each():
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	logger_instance = null
	mock_output = null

# Test initialization
func test_initialization():
	assert_eq(logger_instance.name, "TestLogger", "Should set logger name")
	assert_eq(logger_instance.log_level, LogLevel.Level.INFO, "Should set initial log level")
	assert_eq(logger_instance.output, mock_output, "Should set output reference")
	assert_not_null(logger_instance.global_level_provider, "Should set global level provider")

# Test level setting and getting
func test_set_get_level():
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_eq(logger_instance.get_level(), LogLevel.Level.ERROR, "Should update log level")
	
	logger_instance.set_level(LogLevel.Level.TRACE)
	assert_eq(logger_instance.get_level(), LogLevel.Level.TRACE, "Should update to TRACE level")

# Test level checking functions
func test_is_trace_enabled():
	logger_instance.set_level(LogLevel.Level.TRACE)
	assert_true(logger_instance.is_trace_enabled(), "TRACE should be enabled when level is TRACE")
	
	logger_instance.set_level(LogLevel.Level.DEBUG)
	assert_false(logger_instance.is_trace_enabled(), "TRACE should be disabled when level is DEBUG")

func test_is_debug_enabled():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	assert_true(logger_instance.is_debug_enabled(), "DEBUG should be enabled when level is DEBUG")
	
	logger_instance.set_level(LogLevel.Level.INFO)
	assert_false(logger_instance.is_debug_enabled(), "DEBUG should be disabled when level is INFO")

func test_is_info_enabled():
	logger_instance.set_level(LogLevel.Level.INFO)
	assert_true(logger_instance.is_info_enabled(), "INFO should be enabled when level is INFO")
	
	logger_instance.set_level(LogLevel.Level.WARN)
	assert_false(logger_instance.is_info_enabled(), "INFO should be disabled when level is WARN")

func test_is_warn_enabled():
	logger_instance.set_level(LogLevel.Level.WARN)
	assert_true(logger_instance.is_warn_enabled(), "WARN should be enabled when level is WARN")
	
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_false(logger_instance.is_warn_enabled(), "WARN should be disabled when level is ERROR")

func test_is_error_enabled():
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_true(logger_instance.is_error_enabled(), "ERROR should be enabled when level is ERROR")
	
	logger_instance.set_level(LogLevel.Level.FATAL)
	assert_false(logger_instance.is_error_enabled(), "ERROR should be disabled when level is FATAL")

func test_is_fatal_enabled():
	logger_instance.set_level(LogLevel.Level.FATAL)
	assert_true(logger_instance.is_fatal_enabled(), "FATAL should be enabled when level is FATAL")
	
	# FATAL is highest level, so it's always enabled when set

func test_is_level_enabled_generic():
	logger_instance.set_level(LogLevel.Level.WARN)
	
	assert_false(logger_instance.is_level_enabled(LogLevel.Level.TRACE), "TRACE should be disabled")
	assert_false(logger_instance.is_level_enabled(LogLevel.Level.DEBUG), "DEBUG should be disabled")
	assert_false(logger_instance.is_level_enabled(LogLevel.Level.INFO), "INFO should be disabled")
	assert_true(logger_instance.is_level_enabled(LogLevel.Level.WARN), "WARN should be enabled")
	assert_true(logger_instance.is_level_enabled(LogLevel.Level.ERROR), "ERROR should be enabled")
	assert_true(logger_instance.is_level_enabled(LogLevel.Level.FATAL), "FATAL should be enabled")

# Test global level provider influence
func test_global_level_override():
	# Create logger instance with global level provider returning ERROR
	var error_global_provider = func() -> LogLevel.Level: return LogLevel.Level.ERROR
	var logger_with_global = LoggerInstance.new("TestLogger", LogLevel.Level.DEBUG, mock_output, error_global_provider)
	
	# Even though logger level is DEBUG, global level is ERROR, so DEBUG should be disabled
	assert_false(logger_with_global.is_debug_enabled(), "DEBUG should be disabled due to global level")
	assert_true(logger_with_global.is_error_enabled(), "ERROR should be enabled")

# Test logging functions
func test_trace_logging():
	logger_instance.set_level(LogLevel.Level.TRACE)
	logger_instance.trace("Trace message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("logger_name"), "TestLogger", "Should log with correct logger name")
	assert_eq(last_msg.get("level"), LogLevel.Level.TRACE, "Should log with TRACE level")
	assert_eq(last_msg.get("message"), "Trace message", "Should log correct message")

func test_debug_logging():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	logger_instance.debug("Debug message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.DEBUG, "Should log with DEBUG level")
	assert_eq(last_msg.get("message"), "Debug message", "Should log correct message")

func test_info_logging():
	logger_instance.set_level(LogLevel.Level.INFO)
	logger_instance.info("Info message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.INFO, "Should log with INFO level")
	assert_eq(last_msg.get("message"), "Info message", "Should log correct message")

func test_warn_logging():
	logger_instance.set_level(LogLevel.Level.WARN)
	logger_instance.warn("Warn message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.WARN, "Should log with WARN level")
	assert_eq(last_msg.get("message"), "Warn message", "Should log correct message")

func test_error_logging():
	logger_instance.set_level(LogLevel.Level.ERROR)
	logger_instance.error("Error message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.ERROR, "Should log with ERROR level")
	assert_eq(last_msg.get("message"), "Error message", "Should log correct message")

func test_fatal_logging():
	logger_instance.set_level(LogLevel.Level.FATAL)
	logger_instance.fatal("Fatal message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.FATAL, "Should log with FATAL level")
	assert_eq(last_msg.get("message"), "Fatal message", "Should log correct message")

func test_generic_log_function():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	logger_instance.log(LogLevel.Level.WARN, "Generic log message")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("level"), LogLevel.Level.WARN, "Should log with specified level")
	assert_eq(last_msg.get("message"), "Generic log message", "Should log correct message")

# Test level filtering
func test_trace_filtered_out():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	mock_output.clear_messages()
	
	logger_instance.trace("This should not be logged")
	
	assert_eq(mock_output.logged_messages.size(), 0, "TRACE message should be filtered out")

func test_debug_filtered_out():
	logger_instance.set_level(LogLevel.Level.INFO)
	mock_output.clear_messages()
	
	logger_instance.debug("This should not be logged")
	
	assert_eq(mock_output.logged_messages.size(), 0, "DEBUG message should be filtered out")

func test_info_filtered_out():
	logger_instance.set_level(LogLevel.Level.WARN)
	mock_output.clear_messages()
	
	logger_instance.info("This should not be logged")
	
	assert_eq(mock_output.logged_messages.size(), 0, "INFO message should be filtered out")

func test_higher_levels_pass_through():
	logger_instance.set_level(LogLevel.Level.WARN)
	mock_output.clear_messages()
	
	logger_instance.warn("Warn message")
	logger_instance.error("Error message")
	logger_instance.fatal("Fatal message")
	
	assert_eq(mock_output.logged_messages.size(), 3, "All higher level messages should pass through")

# Test global level filtering
func test_global_level_filtering():
	# Create logger instance where global level is higher than instance level
	var high_global_provider = func() -> LogLevel.Level: return LogLevel.Level.ERROR
	var filtered_logger = LoggerInstance.new("TestLogger", LogLevel.Level.DEBUG, mock_output, high_global_provider)
	
	mock_output.clear_messages()
	filtered_logger.debug("This should be filtered by global level")
	filtered_logger.info("This should also be filtered")
	filtered_logger.error("This should pass through")
	
	assert_eq(mock_output.logged_messages.size(), 1, "Only ERROR should pass through global filter")
	assert_eq(mock_output.get_last_message().level, LogLevel.Level.ERROR, "Should be ERROR level")

# Test empty and special messages
func test_empty_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	logger_instance.info("")
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("message"), "", "Should handle empty message")
	assert_eq(last_msg.get("level"), LogLevel.Level.INFO, "Should still log with correct level")

func test_special_characters_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	var special_msg = "Special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	logger_instance.info(special_msg)
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("message"), special_msg, "Should handle special characters")

func test_unicode_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	var unicode_msg = "Unicode: 你好世界 🎮 γειά σας"
	logger_instance.info(unicode_msg)
	
	var last_msg = mock_output.get_last_message()
	assert_eq(last_msg.get("message"), unicode_msg, "Should handle unicode characters")

# Test multiple sequential messages
func test_multiple_messages():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	mock_output.clear_messages()
	
	logger_instance.debug("First message")
	logger_instance.info("Second message")
	logger_instance.warn("Third message")
	
	assert_eq(mock_output.logged_messages.size(), 3, "Should log all messages")
	assert_eq(mock_output.logged_messages[0].message, "First message", "First message should be correct")
	assert_eq(mock_output.logged_messages[1].message, "Second message", "Second message should be correct")
	assert_eq(mock_output.logged_messages[2].message, "Third message", "Third message should be correct")

# Test level consistency
func test_level_consistency():
	# Test that level checking and actual logging are consistent
	logger_instance.set_level(LogLevel.Level.WARN)
	
	if logger_instance.is_debug_enabled():
		logger_instance.debug("This should not happen")
	
	if logger_instance.is_warn_enabled():
		logger_instance.warn("This should happen")
	
	assert_eq(mock_output.logged_messages.size(), 1, "Only one message should be logged")
	assert_eq(mock_output.get_last_message().level, LogLevel.Level.WARN, "Should be WARN message")
