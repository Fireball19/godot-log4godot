# test_file_log_handler.gd
# Unit tests for FileLogHandler class using gdUnit4
extends GdUnitTestSuite

var handler: FileLogHandler
var test_file_path: String = "user://test_log.log"

func before_test():
	handler = FileLogHandler.new(test_file_path)
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	handler = null

# Test initialization
func test_initialization_default_path():
	var default_handler = FileLogHandler.new()
	assert_str(default_handler.file_path).is_equal("user://game.log")
	assert_bool(default_handler.is_enabled).is_false()

func test_initialization_custom_path():
	assert_str(handler.file_path).is_equal(test_file_path)
	assert_bool(handler.is_enabled).is_false()

# Test enable/disable functionality
func test_set_enabled_true():
	handler.set_enabled(true)
	assert_bool(handler.is_enabled).is_true()
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

func test_set_enabled_false():
	handler.set_enabled(true)  # First enable
	handler.set_enabled(false)
	assert_bool(handler.is_enabled).is_false()

func test_set_enabled_creates_file():
	handler.set_enabled(true)
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()

# Test file path setting
func test_set_file_path():
	var new_path = "user://new_test_log.log"
	handler.set_file_path(new_path)
	assert_str(handler.file_path).is_equal(new_path)
	
	# Clean up
	if FileAccess.file_exists(new_path):
		DirAccess.remove_absolute(new_path)

func test_set_file_path_when_enabled():
	var new_path = "user://new_test_log.log"
	handler.set_enabled(true)
	handler.set_file_path(new_path)
	
	assert_str(handler.file_path).is_equal(new_path)
	assert_bool(FileAccess.file_exists(new_path)).is_true()
	
	# Clean up
	if FileAccess.file_exists(new_path):
		DirAccess.remove_absolute(new_path)

# Test log writing
func test_write_log_when_disabled():
	# Should not create file or write when disabled
	handler.write_log("Test message")
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

func test_write_log_when_enabled():
	handler.set_enabled(true)
	handler.write_log("Test message")
	
	assert_bool(FileAccess.file_exists(test_file_path)).is_true()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test message")

func test_write_multiple_logs():
	handler.set_enabled(true)
	handler.write_log("First message")
	handler.write_log("Second message")
	handler.write_log("Third message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("First message")
	assert_str(content).contains("Second message")
	assert_str(content).contains("Third message")

func test_write_log_appends():
	handler.set_enabled(true)
	handler.write_log("First message")
	
	# Create new handler instance to simulate restart
	var handler2 = FileLogHandler.new(test_file_path)
	handler2.set_enabled(true)
	handler2.write_log("Second message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	var message_lines = []
	for line in lines:
		if not line.is_empty() and not line.contains("Logger Session Started"):
			message_lines.append(line)
	
	assert_int(message_lines.size()).is_greater_equal(2)

# Test log clearing
func test_clear_log_when_disabled():
	handler.clear_log_file()
	assert_bool(FileAccess.file_exists(test_file_path)).is_false()

func test_clear_log_when_enabled():
	handler.set_enabled(true)
	handler.write_log("Message before clear")
	handler.clear_log_file()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Log Cleared")
	assert_str(content).not_contains("Message before clear")

# Test session start message
func test_session_start_message():
	handler.set_enabled(true)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Logger Session Started")

func test_session_start_message_format():
	handler.set_enabled(true)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("=== Logger Session Started:")
	assert_str(content).contains("===")

# Test file handling edge cases
func test_write_log_empty_message():
	handler.set_enabled(true)
	handler.write_log("")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	# Should have session start line and empty message line
	assert_int(lines.size()).is_greater_equal(2)

func test_write_log_special_characters():
	handler.set_enabled(true)
	var special_message = "Test with special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	handler.write_log(special_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains(special_message)

func test_write_log_unicode():
	handler.set_enabled(true)
	var unicode_message = "Unicode test: 你好世界 🎮 γειά σας"
	handler.write_log(unicode_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Unicode test")

# Test concurrent access simulation
func test_multiple_writes_sequence():
	handler.set_enabled(true)
	
	for i in range(10):
		handler.write_log("Message " + str(i))
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	for i in range(10):
		assert_str(content).contains("Message " + str(i))
