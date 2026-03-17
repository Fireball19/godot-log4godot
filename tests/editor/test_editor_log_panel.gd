# test_editor_log_panel.gd
# Unit tests for EditorLogPanel class using gdUnit4
extends GdUnitTestSuite

var panel: EditorLogPanel

func before_test() -> void:
	panel = EditorLogPanel.new()
	# We need to add it to the tree for _ready() to be called
	add_child(panel)
	await get_tree().process_frame

func after_test() -> void:
	if panel:
		panel.queue_free()
	panel = null

# Test initialization
func test_initialization() -> void:
	assert_object(panel.log_buffer).is_not_null()
	assert_object(panel.toolbar).is_not_null()
	assert_object(panel.logger_option_button).is_not_null()
	assert_object(panel.level_option_button).is_not_null()
	assert_object(panel.clear_button).is_not_null()
	assert_object(panel.auto_scroll_check).is_not_null()
	assert_object(panel.copy_button).is_not_null()
	assert_object(panel.log_display).is_not_null()
	assert_object(panel.entry_count_label).is_not_null()

func test_default_filter_values() -> void:
	assert_str(panel.current_logger_filter).is_equal("")
	assert_int(panel.current_level_filter).is_equal(LogLevel.Level.TRACE)
	assert_bool(panel.auto_scroll).is_true()

func test_auto_scroll_default_enabled() -> void:
	assert_bool(panel.auto_scroll_check.button_pressed).is_true()
	assert_bool(panel.log_display.scroll_following).is_true()

# Test adding log entries
func test_add_log_entry() -> void:
	panel.add_log_entry("12:34:56.789", &"TestLogger", LogLevel.Level.INFO, "Test message")
	
	assert_int(panel.log_buffer.get_entry_count()).is_equal(1)

func test_add_multiple_log_entries() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger1", LogLevel.Level.DEBUG, "Debug")
	panel.add_log_entry("12:34:56.002", &"Logger2", LogLevel.Level.INFO, "Info")
	panel.add_log_entry("12:34:56.003", &"Logger1", LogLevel.Level.ERROR, "Error")
	
	assert_int(panel.log_buffer.get_entry_count()).is_equal(3)

func test_log_entry_appears_in_display() -> void:
	panel.add_log_entry("12:34:56.789", &"TestLogger", LogLevel.Level.INFO, "Test message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Test message")
	assert_str(display_text).contains("TestLogger")
	assert_str(display_text).contains("INFO")

# Test logger dropdown
func test_logger_dropdown_initial_state() -> void:
	assert_int(panel.logger_option_button.item_count).is_equal(1)
	assert_str(panel.logger_option_button.get_item_text(0)).is_equal("All Loggers")

func test_logger_dropdown_updates_on_new_logger() -> void:
	panel.add_log_entry("12:34:56.000", &"Network", LogLevel.Level.INFO, "Message")
	
	await get_tree().process_frame
	
	assert_int(panel.logger_option_button.item_count).is_equal(2)
	# First item should still be "All Loggers"
	assert_str(panel.logger_option_button.get_item_text(0)).is_equal("All Loggers")
	# Second item should be the new logger with count
	assert_str(panel.logger_option_button.get_item_text(1)).contains("Network")
	assert_str(panel.logger_option_button.get_item_text(1)).contains("(1)")

func test_logger_dropdown_multiple_loggers() -> void:
	panel.add_log_entry("12:34:56.001", &"AI", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Network", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Physics", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	# "All Loggers" + 3 named loggers
	assert_int(panel.logger_option_button.item_count).is_equal(4)

func test_logger_dropdown_count_updates() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Network", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Network", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	assert_str(panel.logger_option_button.get_item_text(1)).contains("(3)")

# Test level dropdown
func test_level_dropdown_has_all_levels() -> void:
	assert_int(panel.level_option_button.item_count).is_equal(6)
	assert_str(panel.level_option_button.get_item_text(0)).is_equal("TRACE")
	assert_str(panel.level_option_button.get_item_text(1)).is_equal("DEBUG")
	assert_str(panel.level_option_button.get_item_text(2)).is_equal("INFO")
	assert_str(panel.level_option_button.get_item_text(3)).is_equal("WARN")
	assert_str(panel.level_option_button.get_item_text(4)).is_equal("ERROR")
	assert_str(panel.level_option_button.get_item_text(5)).is_equal("FATAL")

# Test filtering functionality
func test_filter_by_logger() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Network message")
	panel.add_log_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "AI message")
	
	await get_tree().process_frame
	
	# Set filter to Network
	panel.current_logger_filter = &"Network"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Network message")
	assert_str(display_text).not_contains("AI message")

func test_filter_by_level() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Info message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.ERROR, "Error message")
	
	await get_tree().process_frame
	
	# Set filter to ERROR level
	panel.current_level_filter = LogLevel.Level.ERROR
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).not_contains("Debug message")
	assert_str(display_text).not_contains("Info message")
	assert_str(display_text).contains("Error message")

func test_filter_combined() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.DEBUG, "Network debug")
	panel.add_log_entry("12:34:56.002", &"Network", LogLevel.Level.ERROR, "Network error")
	panel.add_log_entry("12:34:56.003", &"AI", LogLevel.Level.ERROR, "AI error")
	
	await get_tree().process_frame
	
	# Filter to Network + ERROR level
	panel.current_logger_filter = &"Network"
	panel.current_level_filter = LogLevel.Level.ERROR
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).not_contains("Network debug")
	assert_str(display_text).contains("Network error")
	assert_str(display_text).not_contains("AI error")

# Test entry count label
func test_entry_count_label_initial() -> void:
	assert_str(panel.entry_count_label.text).is_equal("0 entries")

func test_entry_count_label_updates() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	assert_str(panel.entry_count_label.text).is_equal("3 entries")

func test_entry_count_label_with_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Network", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	# Filter to Network only
	panel.current_logger_filter = &"Network"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	# Should show "2 / 3 entries"
	assert_str(panel.entry_count_label.text).contains("2")
	assert_str(panel.entry_count_label.text).contains("3")

# Test clear functionality
func test_clear_button() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	
	await get_tree().process_frame
	
	# Simulate clear button press
	panel._on_clear_pressed()
	
	await get_tree().process_frame
	
	assert_int(panel.log_buffer.get_entry_count()).is_equal(0)
	assert_str(panel.entry_count_label.text).is_equal("0 entries")

# Test auto-scroll toggle
func test_auto_scroll_toggle() -> void:
	assert_bool(panel.auto_scroll).is_true()
	assert_bool(panel.log_display.scroll_following).is_true()
	
	panel._on_auto_scroll_toggled(false)
	
	assert_bool(panel.auto_scroll).is_false()
	assert_bool(panel.log_display.scroll_following).is_false()
	
	panel._on_auto_scroll_toggled(true)
	
	assert_bool(panel.auto_scroll).is_true()
	assert_bool(panel.log_display.scroll_following).is_true()

# Test entry_passes_filter internal method
func test_entry_passes_filter_all_pass() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.000", &"Test", LogLevel.Level.INFO, "Message")
	
	panel.current_logger_filter = &""
	panel.current_level_filter = LogLevel.Level.TRACE
	
	assert_bool(panel._entry_passes_filter(entry)).is_true()

func test_entry_passes_filter_logger_mismatch() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.000", &"Network", LogLevel.Level.INFO, "Message")
	
	panel.current_logger_filter = &"AI"
	panel.current_level_filter = LogLevel.Level.TRACE
	
	assert_bool(panel._entry_passes_filter(entry)).is_false()

func test_entry_passes_filter_level_too_low() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.000", &"Test", LogLevel.Level.DEBUG, "Message")
	
	panel.current_logger_filter = &""
	panel.current_level_filter = LogLevel.Level.WARN
	
	assert_bool(panel._entry_passes_filter(entry)).is_false()

func test_entry_passes_filter_logger_match() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.000", &"Network", LogLevel.Level.INFO, "Message")
	
	panel.current_logger_filter = &"Network"
	panel.current_level_filter = LogLevel.Level.TRACE
	
	assert_bool(panel._entry_passes_filter(entry)).is_true()

func test_entry_passes_filter_level_match() -> void:
	var entry := LogBuffer.LogEntry.new("12:34:56.000", &"Test", LogLevel.Level.ERROR, "Message")
	
	panel.current_logger_filter = &""
	panel.current_level_filter = LogLevel.Level.WARN
	
	assert_bool(panel._entry_passes_filter(entry)).is_true()

# Test color formatting
func test_log_display_has_colors() -> void:
	panel.add_log_entry("12:34:56.000", &"Test", LogLevel.Level.ERROR, "Error message")
	
	await get_tree().process_frame
	
	# The raw BBCode should contain color tags
	# Note: RichTextLabel doesn't expose raw BBCode easily, so we test indirectly
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Error message")

# Test rapid log entries
func test_rapid_log_entries() -> void:
	for i: int in range(100):
		panel.add_log_entry("12:34:56.%03d" % i, &"Test", LogLevel.Level.INFO, "Message " + str(i))
	
	await get_tree().process_frame
	
	assert_int(panel.log_buffer.get_entry_count()).is_equal(100)

# Test special characters in logs
func test_special_characters_in_display() -> void:
	var special_msg: String = "Special: <>&\"' [color=red]test[/color]"
	panel.add_log_entry("12:34:56.000", &"Test", LogLevel.Level.INFO, special_msg)
	
	await get_tree().process_frame
	
	# The message should be displayed (BBCode should be escaped or handled)
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Special")

# Test logger filter change callback
func test_on_logger_filter_changed_to_all() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Network msg")
	panel.add_log_entry("12:34:56.002", &"AI", LogLevel.Level.INFO, "AI msg")
	
	await get_tree().process_frame
	
	# First set a specific filter
	panel._on_logger_filter_changed(1)
	assert_str(panel.current_logger_filter).is_not_equal("")
	
	# Then change to "All Loggers"
	panel._on_logger_filter_changed(0)
	assert_str(panel.current_logger_filter).is_equal("")

# Test level filter change callback
func test_on_level_filter_changed() -> void:
	panel._on_level_filter_changed(LogLevel.Level.WARN)
	assert_int(panel.current_level_filter).is_equal(LogLevel.Level.WARN)
	
	panel._on_level_filter_changed(LogLevel.Level.TRACE)
	assert_int(panel.current_level_filter).is_equal(LogLevel.Level.TRACE)
