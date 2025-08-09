# test_file_log_handler.gd
# Unit tests for FileLogHandler class
extends GutTest

var handler: FileLogHandler
var test_file_path: String = "user://test_log.log"

func before_each():
	handler = FileLogHandler.new(test_file_path)
	# Clean up any existing test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_each():
	# Clean up test file
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	handler = null

# Test initialization
func test_initialization_default_path():
	var default_handler = FileLogHandler.new()
	assert_eq(default_handler.file_path, "user://game.log", "Should use default path")
	assert_false(default_handler.is_enabled, "Should be disabled by default")

func test_initialization_custom_path():
	assert_eq(handler.file_path, test_file_path, "Should use custom path")
	assert_false(handler.is_enabled, "Should be disabled by default")

# Test enable/disable functionality
func test_set_enabled_true():
	handler.set_enabled(true)
	assert_true(handler.is_enabled, "Should be enabled")
	assert_true(FileAccess.file_exists(test_file_path), "Should create log file when enabled")

func test_set_enabled_false():
	handler.set_enabled(true)  # First enable
	handler.set_enabled(false)
	assert_false(handler.is_enabled, "Should be disabled")

func test_set_enabled_creates_file():
	handler.set_enabled(true)
	assert_true(FileAccess.file_exists(test_file_path), "Should create file when enabled")

# Test file path setting
func test_set_file_path():
	var new_path = "user://new_test_log.log"
	handler.set_file_path(new_path)
	assert_eq(handler.file_path, new_path, "Should update file path")
	
	# Clean up
	if FileAccess.file_exists(new_path):
		DirAccess.remove_absolute(new_path)

func test_set_file_path_when_enabled():
	var new_path = "user://new_test_log.log"
	handler.set_enabled(true)
	handler.set_file_path(new_path)
	
	assert_eq(handler.file_path, new_path, "Should update file path")
	assert_true(FileAccess.file_exists(new_path), "Should create new file when enabled")
	
	# Clean up
	if FileAccess.file_exists(new_path):
		DirAccess.remove_absolute(new_path)

# Test log writing
func test_write_log_when_disabled():
	# Should not create file or write when disabled
	handler.write_log("Test message")
	assert_false(FileAccess.file_exists(test_file_path), "Should not create file when disabled")

func test_write_log_when_enabled():
	handler.set_enabled(true)
	handler.write_log("Test message")
	
	assert_true(FileAccess.file_exists(test_file_path), "File should exist")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Test message"), "Should contain the logged message")

func test_write_multiple_logs():
	handler.set_enabled(true)
	handler.write_log("First message")
	handler.write_log("Second message")
	handler.write_log("Third message")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("First message"), "Should contain first message")
	assert_true(content.contains("Second message"), "Should contain second message")
	assert_true(content.contains("Third message"), "Should contain third message")

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
	
	assert_true(message_lines.size() >= 2, "Should have at least 2 message lines")

# Test log clearing
func test_clear_log_when_disabled():
	handler.clear_log()
	assert_false(FileAccess.file_exists(test_file_path), "Should not create file when disabled")

func test_clear_log_when_enabled():
	handler.set_enabled(true)
	handler.write_log("Message before clear")
	handler.clear_log()
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Log Cleared"), "Should contain clear message")
	assert_false(content.contains("Message before clear"), "Should not contain previous messages")

# Test session start message
func test_session_start_message():
	handler.set_enabled(true)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Logger Session Started"), "Should contain session start message")

func test_session_start_message_format():
	handler.set_enabled(true)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("=== Logger Session Started:"), "Should contain formatted session start")
	assert_true(content.contains("==="), "Should contain session markers")

# Test file handling edge cases
func test_write_log_empty_message():
	handler.set_enabled(true)
	handler.write_log("")
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	var lines = content.split("\n")
	# Should have session start line and empty message line
	assert_true(lines.size() >= 2, "Should have at least session start and empty message")

func test_write_log_special_characters():
	handler.set_enabled(true)
	var special_message = "Test with special chars: @#$%^&*()[]{}|\\:;\"'<>?,./`~"
	handler.write_log(special_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains(special_message), "Should handle special characters")

func test_write_log_unicode():
	handler.set_enabled(true)
	var unicode_message = "Unicode test: 你好世界 🎮 γειά σας"
	handler.write_log(unicode_message)
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	assert_true(content.contains("Unicode test"), "Should handle unicode characters")

# Test concurrent access simulation
func test_multiple_writes_sequence():
	handler.set_enabled(true)
	
	for i in range(10):
		handler.write_log("Message " + str(i))
	
	var file = FileAccess.open(test_file_path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()
	
	for i in range(10):
		assert_true(content.contains("Message " + str(i)), "Should contain message " + str(i))
