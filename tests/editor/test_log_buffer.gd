# test_log_buffer.gd
# Unit tests for LogBuffer class using gdUnit4
extends GdUnitTestSuite

var buffer: LogBuffer

func before_test() -> void:
	buffer = LogBuffer.new()

func after_test() -> void:
	buffer = null

# Test initialization
func test_initialization() -> void:
	assert_int(buffer.get_entry_count()).is_equal(0)
	assert_array(buffer.get_logger_names()).is_empty()
	assert_array(buffer.get_all_entries()).is_empty()

# Test adding entries
func test_add_single_entry() -> void:
	buffer.add_entry("12:34:56.789", &"TestLogger", LogLevel.Level.INFO, "Test message")
	
	assert_int(buffer.get_entry_count()).is_equal(1)
	
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_int(entries.size()).is_equal(1)
	assert_str(entries[0].timestamp).is_equal("12:34:56.789")
	assert_str(entries[0].logger_name).is_equal("TestLogger")
	assert_int(entries[0].level).is_equal(LogLevel.Level.INFO)
	assert_str(entries[0].message).is_equal("Test message")

func test_add_multiple_entries() -> void:
	buffer.add_entry("12:34:56.001", &"Logger1", LogLevel.Level.DEBUG, "Debug message")
	buffer.add_entry("12:34:56.002", &"Logger2", LogLevel.Level.INFO, "Info message")
	buffer.add_entry("12:34:56.003", &"Logger1", LogLevel.Level.ERROR, "Error message")
	
	assert_int(buffer.get_entry_count()).is_equal(3)

func test_add_entry_different_levels() -> void:
	for level: LogLevel.Level in LogLevel.Level.values():
		buffer.add_entry("12:34:56.000", &"Test", level, "Message at level " + str(level))
	
	assert_int(buffer.get_entry_count()).is_equal(6)

# Test logger names tracking
func test_get_logger_names_single() -> void:
	buffer.add_entry("12:34:56.000", &"NetworkLogger", LogLevel.Level.INFO, "Message")
	
	var names: Array[StringName] = buffer.get_logger_names()
	assert_int(names.size()).is_equal(1)
	assert_str(names[0]).is_equal("NetworkLogger")

func test_get_logger_names_multiple() -> void:
	buffer.add_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message 1")
	buffer.add_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "Message 2")
	buffer.add_entry("12:34:56.003", &"Physics", LogLevel.Level.INFO, "Message 3")
	buffer.add_entry("12:34:56.004", &"Network", LogLevel.Level.INFO, "Message 4")
	
	var names: Array[StringName] = buffer.get_logger_names()
	assert_int(names.size()).is_equal(3)
	# Names should be sorted
	assert_str(names[0]).is_equal("AI")
	assert_str(names[1]).is_equal("Network")
	assert_str(names[2]).is_equal("Physics")

func test_get_logger_names_no_duplicates() -> void:
	buffer.add_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	buffer.add_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	buffer.add_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message 3")
	
	var names: Array[StringName] = buffer.get_logger_names()
	assert_int(names.size()).is_equal(1)

# Test filtering
func test_filter_by_logger_name() -> void:
	buffer.add_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Network message 1")
	buffer.add_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "AI message")
	buffer.add_entry("12:34:56.003", &"Network", LogLevel.Level.INFO, "Network message 2")
	
	var filtered: Array[LogBuffer.LogEntry] = buffer.get_filtered_entries(&"Network")
	assert_int(filtered.size()).is_equal(2)
	assert_str(filtered[0].message).is_equal("Network message 1")
	assert_str(filtered[1].message).is_equal("Network message 2")

func test_filter_by_level() -> void:
	buffer.add_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	buffer.add_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Info message")
	buffer.add_entry("12:34:56.003", &"Test", LogLevel.Level.WARN, "Warn message")
	buffer.add_entry("12:34:56.004", &"Test", LogLevel.Level.ERROR, "Error message")
	
	var filtered: Array[LogBuffer.LogEntry] = buffer.get_filtered_entries(&"", LogLevel.Level.WARN)
	assert_int(filtered.size()).is_equal(2)
	assert_str(filtered[0].message).is_equal("Warn message")
	assert_str(filtered[1].message).is_equal("Error message")

func test_filter_by_logger_and_level() -> void:
	buffer.add_entry("12:34:56.001", &"Network", LogLevel.Level.DEBUG, "Network debug")
	buffer.add_entry("12:34:56.002", &"Network", LogLevel.Level.ERROR, "Network error")
	buffer.add_entry("12:34:56.003", &"AI", LogLevel.Level.ERROR, "AI error")
	buffer.add_entry("12:34:56.004", &"Network", LogLevel.Level.INFO, "Network info")
	
	var filtered: Array[LogBuffer.LogEntry] = buffer.get_filtered_entries(&"Network", LogLevel.Level.INFO)
	assert_int(filtered.size()).is_equal(2)
	assert_str(filtered[0].message).is_equal("Network error")
	assert_str(filtered[1].message).is_equal("Network info")

func test_filter_no_matches() -> void:
	buffer.add_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message")
	
	var filtered: Array[LogBuffer.LogEntry] = buffer.get_filtered_entries(&"NonExistent")
	assert_int(filtered.size()).is_equal(0)

func test_filter_all_entries_empty_filter() -> void:
	buffer.add_entry("12:34:56.001", &"Logger1", LogLevel.Level.DEBUG, "Message 1")
	buffer.add_entry("12:34:56.002", &"Logger2", LogLevel.Level.INFO, "Message 2")
	
	var filtered: Array[LogBuffer.LogEntry] = buffer.get_filtered_entries(&"", LogLevel.Level.TRACE)
	assert_int(filtered.size()).is_equal(2)

# Test entry count per logger
func test_get_entry_count_for_logger() -> void:
	buffer.add_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message 1")
	buffer.add_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "Message 2")
	buffer.add_entry("12:34:56.003", &"Network", LogLevel.Level.INFO, "Message 3")
	buffer.add_entry("12:34:56.004", &"Network", LogLevel.Level.INFO, "Message 4")
	
	assert_int(buffer.get_entry_count_for_logger(&"Network")).is_equal(3)
	assert_int(buffer.get_entry_count_for_logger(&"AI")).is_equal(1)
	assert_int(buffer.get_entry_count_for_logger(&"NonExistent")).is_equal(0)

# Test clearing
func test_clear() -> void:
	buffer.add_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	buffer.add_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	
	assert_int(buffer.get_entry_count()).is_equal(2)
	
	buffer.clear()
	
	assert_int(buffer.get_entry_count()).is_equal(0)
	assert_array(buffer.get_all_entries()).is_empty()

# Test signals
func test_log_added_signal() -> void:
	var signal_received: Dictionary[String, bool] = { "value": false }
	var received_entry: Dictionary[String, LogBuffer.LogEntry] = { "value": null }
	
	buffer.log_added.connect(func(entry: LogBuffer.LogEntry) -> void:
		signal_received.set("value", true)
		received_entry.set("value", entry)
	)
	
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, "Test message")
	
	assert_bool(signal_received.get("value")).is_true()
	assert_object(received_entry.get("value")).is_not_null()
	assert_str(received_entry.get("value").message).is_equal("Test message")

func test_buffer_cleared_signal() -> void:
	var signal_received: Dictionary[String, bool] = { "value": false }
	
	buffer.buffer_cleared.connect(func() -> void:
		signal_received.set("value", true)
	)
	
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, "Test message")
	buffer.clear()
	
	assert_bool(signal_received.get("value")).is_true()

# Test buffer overflow
func test_max_entries_limit() -> void:
	# Add more than MAX_ENTRIES
	for i: int in range(LogBuffer.MAX_ENTRIES + 100):
		buffer.add_entry("12:34:56.%03d" % (i % 1000), &"Test", LogLevel.Level.INFO, "Message " + str(i))
	
	assert_int(buffer.get_entry_count()).is_equal(LogBuffer.MAX_ENTRIES)
	
	# First entry should be the 101st one added (index 100)
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_str(entries[0].message).is_equal("Message 100")

func test_oldest_entries_removed_on_overflow() -> void:
	# Add exactly MAX_ENTRIES
	for i: int in range(LogBuffer.MAX_ENTRIES):
		buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, "Message " + str(i))
	
	assert_int(buffer.get_entry_count()).is_equal(LogBuffer.MAX_ENTRIES)
	
	# Add one more
	buffer.add_entry("12:34:56.999", &"Test", LogLevel.Level.INFO, "New message")
	
	assert_int(buffer.get_entry_count()).is_equal(LogBuffer.MAX_ENTRIES)
	
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	# First message should now be "Message 1" (Message 0 was removed)
	assert_str(entries[0].message).is_equal("Message 1")
	# Last message should be the new one
	assert_str(entries[-1].message).is_equal("New message")

# Test LogEntry class
func test_log_entry_initialization() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.789", &"TestLogger", LogLevel.Level.WARN, "Warning!")
	
	assert_str(entry.timestamp).is_equal("12:34:56.789")
	assert_str(entry.logger_name).is_equal("TestLogger")
	assert_int(entry.level).is_equal(LogLevel.Level.WARN)
	assert_str(entry.message).is_equal("Warning!")
	assert_int(entry.raw_time).is_greater(0)

func test_log_entry_raw_time_ordering() -> void:
	var entry1 := LogBuffer.LogEntry.new("12:34:56.001", &"Test", LogLevel.Level.INFO, "First")
	await get_tree().process_frame
	var entry2 := LogBuffer.LogEntry.new("12:34:56.002", &"Test", LogLevel.Level.INFO, "Second")
	
	assert_int(entry2.raw_time).is_greater_equal(entry1.raw_time)

# Test edge cases
func test_empty_logger_name() -> void:
	buffer.add_entry("12:34:56.000", &"", LogLevel.Level.INFO, "Empty logger name")
	
	assert_int(buffer.get_entry_count()).is_equal(1)
	var names: Array[StringName] = buffer.get_logger_names()
	assert_int(names.size()).is_equal(1)
	assert_str(names[0]).is_equal("")

func test_empty_message() -> void:
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, "")
	
	assert_int(buffer.get_entry_count()).is_equal(1)
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_str(entries[0].message).is_equal("")

func test_special_characters_in_message() -> void:
	var special_msg: String = "Special: @#$%^&*()[]{}<>?/\\|`~\"\'"
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, special_msg)
	
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_str(entries[0].message).is_equal(special_msg)

func test_unicode_in_message() -> void:
	var unicode_msg: String = "Unicode: 你好世界 🎮 γειά σας"
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, unicode_msg)
	
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_str(entries[0].message).is_equal(unicode_msg)

func test_multiline_message() -> void:
	var multiline_msg: String = "Line 1\nLine 2\nLine 3"
	buffer.add_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, multiline_msg)
	
	var entries: Array[LogBuffer.LogEntry] = buffer.get_all_entries()
	assert_str(entries[0].message).is_equal(multiline_msg)
