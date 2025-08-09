# test_logger_instance.gd
# Unit tests for LoggerInstance class using gdUnit4
extends GdUnitTestSuite

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

func before_test():
	mock_output = MockLogOutput.new()
	logger_instance = LoggerInstance.new("TestLogger", LogLevel.Level.INFO, mock_output, mock_global_level_provider)

func after_test():
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	logger_instance = null
	mock_output = null

# Test initialization
func test_initialization():
	assert_str(logger_instance.name).is_equal("TestLogger")
	assert_int(logger_instance.log_level).is_equal(LogLevel.Level.INFO)
	assert_object(logger_instance.output).is_equal(mock_output)
	assert_object(logger_instance.global_level_provider).is_not_null()

# Test level setting and getting
func test_set_get_level():
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_int(logger_instance.get_level()).is_equal(LogLevel.Level.ERROR)
	
	logger_instance.set_level(LogLevel.Level.TRACE)
	assert_int(logger_instance.get_level()).is_equal(LogLevel.Level.TRACE)

# Test level checking functions
func test_is_trace_enabled():
	logger_instance.set_level(LogLevel.Level.TRACE)
	assert_bool(logger_instance.is_trace_enabled()).is_true()
	
	logger_instance.set_level(LogLevel.Level.DEBUG)
	assert_bool(logger_instance.is_trace_enabled()).is_false()

func test_is_debug_enabled():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	assert_bool(logger_instance.is_debug_enabled()).is_true()
	
	logger_instance.set_level(LogLevel.Level.INFO)
	assert_bool(logger_instance.is_debug_enabled()).is_false()

func test_is_info_enabled():
	logger_instance.set_level(LogLevel.Level.INFO)
	assert_bool(logger_instance.is_info_enabled()).is_true()
	
	logger_instance.set_level(LogLevel.Level.WARN)
	assert_bool(logger_instance.is_info_enabled()).is_false()

func test_is_warn_enabled():
	logger_instance.set_level(LogLevel.Level.WARN)
	assert_bool(logger_instance.is_warn_enabled()).is_true()
	
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_bool(logger_instance.is_warn_enabled()).is_false()

func test_is_error_enabled():
	logger_instance.set_level(LogLevel.Level.ERROR)
	assert_bool(logger_instance.is_error_enabled()).is_true()
	
	logger_instance.set_level(LogLevel.Level.FATAL)
	assert_bool(logger_instance.is_error_enabled()).is_false()

func test_is_fatal_enabled():
	logger_instance.set_level(LogLevel.Level.FATAL)
	assert_bool(logger_instance.is_fatal_enabled()).is_true()
	
	# FATAL is highest level, so it's always enabled when set

func test_is_level_enabled_generic():
	logger_instance.set_level(LogLevel.Level.WARN)
	
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.TRACE)).is_false()
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.DEBUG)).is_false()
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.INFO)).is_false()
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.WARN)).is_true()
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.ERROR)).is_true()
	assert_bool(logger_instance.is_level_enabled(LogLevel.Level.FATAL)).is_true()

# Test global level provider influence
func test_global_level_override():
	# Create logger instance with global level provider returning ERROR
	var error_global_provider = func() -> LogLevel.Level: return LogLevel.Level.ERROR
	var logger_with_global = LoggerInstance.new("TestLogger", LogLevel.Level.DEBUG, mock_output, error_global_provider)
	
	# Even though logger level is DEBUG, global level is ERROR, so DEBUG should be disabled
	assert_bool(logger_with_global.is_debug_enabled()).is_false()
	assert_bool(logger_with_global.is_error_enabled()).is_true()

# Test logging functions
func test_trace_logging():
	logger_instance.set_level(LogLevel.Level.TRACE)
	logger_instance.trace("Trace message")
	
	var last_msg = mock_output.get_last_message()
	assert_str(last_msg.get("logger_name")).is_equal("TestLogger")
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.TRACE)
	assert_str(last_msg.get("message")).is_equal("Trace message")

func test_debug_logging():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	logger_instance.debug("Debug message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.DEBUG)
	assert_str(last_msg.get("message")).is_equal("Debug message")

func test_info_logging():
	logger_instance.set_level(LogLevel.Level.INFO)
	logger_instance.info("Info message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.INFO)
	assert_str(last_msg.get("message")).is_equal("Info message")

func test_warn_logging():
	logger_instance.set_level(LogLevel.Level.WARN)
	logger_instance.warn("Warn message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.WARN)
	assert_str(last_msg.get("message")).is_equal("Warn message")

func test_error_logging():
	logger_instance.set_level(LogLevel.Level.ERROR)
	logger_instance.error("Error message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.ERROR)
	assert_str(last_msg.get("message")).is_equal("Error message")

func test_fatal_logging():
	logger_instance.set_level(LogLevel.Level.FATAL)
	logger_instance.fatal("Fatal message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.FATAL)
	assert_str(last_msg.get("message")).is_equal("Fatal message")

func test_generic_log_function():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	logger_instance.log(LogLevel.Level.WARN, "Generic log message")
	
	var last_msg = mock_output.get_last_message()
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.WARN)
	assert_str(last_msg.get("message")).is_equal("Generic log message")

# Test level filtering
func test_trace_filtered_out():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	mock_output.clear_messages()
	
	logger_instance.trace("This should not be logged")
	
	assert_int(mock_output.logged_messages.size()).is_equal(0)

func test_debug_filtered_out():
	logger_instance.set_level(LogLevel.Level.INFO)
	mock_output.clear_messages()
	
	logger_instance.debug("This should not be logged")
	
	assert_int(mock_output.logged_messages.size()).is_equal(0)

func test_info_filtered_out():
	logger_instance.set_level(LogLevel.Level.WARN)
	mock_output.clear_messages()
	
	logger_instance.info("This should not be logged")
	
	assert_int(mock_output.logged_messages.size()).is_equal(0)

func test_higher_levels_pass_through():
	logger_instance.set_level(LogLevel.Level.WARN)
	mock_output.clear_messages()
	
	logger_instance.warn("Warn message")
	logger_instance.error("Error message")
	logger_instance.fatal("Fatal message")
	
	assert_int(mock_output.logged_messages.size()).is_equal(3)

# Test global level filtering
func test_global_level_filtering():
	# Create logger instance where global level is higher than instance level
	var high_global_provider = func() -> LogLevel.Level: return LogLevel.Level.ERROR
	var filtered_logger = LoggerInstance.new("TestLogger", LogLevel.Level.DEBUG, mock_output, high_global_provider)
	
	mock_output.clear_messages()
	filtered_logger.debug("This should be filtered by global level")
	filtered_logger.info("This should also be filtered")
	filtered_logger.error("This should pass through")
	
	assert_int(mock_output.logged_messages.size()).is_equal(1)
	assert_int(mock_output.get_last_message().level).is_equal(LogLevel.Level.ERROR)

# Test empty and special messages
func test_empty_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	logger_instance.info("")
	
	var last_msg = mock_output.get_last_message()
	assert_str(last_msg.get("message")).is_equal("")
	assert_int(last_msg.get("level")).is_equal(LogLevel.Level.INFO)

func test_special_characters_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	var special_msg = "Special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	logger_instance.info(special_msg)
	
	var last_msg = mock_output.get_last_message()
	assert_str(last_msg.get("message")).is_equal(special_msg)

func test_unicode_message():
	logger_instance.set_level(LogLevel.Level.INFO)
	var unicode_msg = "Unicode: 你好世界 🎮 γειά σας"
	logger_instance.info(unicode_msg)
	
	var last_msg = mock_output.get_last_message()
	assert_str(last_msg.get("message")).is_equal(unicode_msg)

# Test multiple sequential messages
func test_multiple_messages():
	logger_instance.set_level(LogLevel.Level.DEBUG)
	mock_output.clear_messages()
	
	logger_instance.debug("First message")
	logger_instance.info("Second message")
	logger_instance.warn("Third message")
	
	assert_int(mock_output.logged_messages.size()).is_equal(3)
	assert_str(mock_output.logged_messages[0].message).is_equal("First message")
	assert_str(mock_output.logged_messages[1].message).is_equal("Second message")
	assert_str(mock_output.logged_messages[2].message).is_equal("Third message")

# Test level consistency
func test_level_consistency():
	# Test that level checking and actual logging are consistent
	logger_instance.set_level(LogLevel.Level.WARN)
	
	if logger_instance.is_debug_enabled():
		logger_instance.debug("This should not happen")
	
	if logger_instance.is_warn_enabled():
		logger_instance.warn("This should happen")
	
	assert_int(mock_output.logged_messages.size()).is_equal(1)
	assert_int(mock_output.get_last_message().level).is_equal(LogLevel.Level.WARN)
