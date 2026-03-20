# test_editor_log_panel.gd
# Unit tests for EditorLogPanel class using gdUnit4
# Tests the redesigned panel with Godot Output-style layout
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


# =============================================================================
# Initialization Tests
# =============================================================================

func test_initialization() -> void:
	assert_object(panel.log_buffer).is_not_null()
	assert_object(panel.main_hbox).is_not_null()
	assert_object(panel.left_vbox).is_not_null()
	assert_object(panel.right_toolbar).is_not_null()
	assert_object(panel.bottom_toolbar).is_not_null()


func test_log_display_initialized() -> void:
	assert_object(panel.log_display).is_not_null()
	assert_bool(panel.log_display.bbcode_enabled).is_true()
	assert_bool(panel.log_display.selection_enabled).is_true()
	assert_bool(panel.log_display.scroll_following).is_true()


func test_right_toolbar_buttons_initialized() -> void:
	assert_object(panel.clear_button).is_not_null()
	assert_object(panel.copy_button).is_not_null()
	assert_object(panel.collapse_button).is_not_null()
	assert_object(panel.auto_scroll_button).is_not_null()


func test_level_toggle_buttons_initialized() -> void:
	assert_int(panel.level_toggle_buttons.size()).is_equal(6)
	for level: LogLevel.Level in LogLevel.Level.values():
		assert_object(panel.level_toggle_buttons[level]).is_not_null()
		assert_bool(panel.level_toggle_buttons[level].toggle_mode).is_true()


func test_bottom_toolbar_components_initialized() -> void:
	assert_object(panel.search_box).is_not_null()
	assert_object(panel.logger_option_button).is_not_null()
	assert_object(panel.entry_count_label).is_not_null()


func test_default_filter_values() -> void:
	assert_str(panel.current_logger_filter).is_equal("")
	assert_str(panel.current_search_filter).is_equal("")
	assert_bool(panel.auto_scroll).is_true()
	assert_bool(panel.collapse_duplicates).is_false()


func test_all_level_toggles_enabled_by_default() -> void:
	for level: LogLevel.Level in LogLevel.Level.values():
		assert_bool(panel.level_toggles[level]).is_true()


func test_auto_scroll_button_enabled_by_default() -> void:
	assert_bool(panel.auto_scroll_button.button_pressed).is_true()


func test_collapse_button_disabled_by_default() -> void:
	assert_bool(panel.collapse_button.button_pressed).is_false()


# =============================================================================
# Layout Structure Tests
# =============================================================================

func test_main_layout_is_horizontal() -> void:
	assert_object(panel.main_hbox).is_instanceof(HBoxContainer)


func test_left_side_is_vertical() -> void:
	assert_object(panel.left_vbox).is_instanceof(VBoxContainer)
	# Left side should be a child of main_hbox
	assert_object(panel.left_vbox.get_parent()).is_equal(panel.main_hbox)


func test_right_toolbar_is_vertical() -> void:
	assert_object(panel.right_toolbar).is_instanceof(VBoxContainer)
	# Right toolbar should be a child of main_hbox (sibling of left_vbox)
	assert_object(panel.right_toolbar.get_parent()).is_equal(panel.main_hbox)


func test_right_toolbar_aligned_with_log_display() -> void:
	# Right toolbar and left_vbox should be siblings in main_hbox
	# This means right toolbar starts at same vertical position as log display
	assert_object(panel.right_toolbar.get_parent()).is_equal(panel.left_vbox.get_parent())


func test_log_display_is_in_left_vbox() -> void:
	assert_object(panel.log_display.get_parent()).is_equal(panel.left_vbox)


func test_bottom_toolbar_is_in_left_vbox() -> void:
	# Bottom toolbar (search bar) should be in left_vbox
	assert_object(panel.bottom_toolbar.get_parent()).is_equal(panel.left_vbox)


func test_search_box_is_in_bottom_toolbar() -> void:
	assert_object(panel.search_box.get_parent()).is_equal(panel.bottom_toolbar)


func test_top_toolbar_is_above_main_hbox() -> void:
	# Logger dropdown's grandparent should be the main VBox (not main_hbox)
	var top_toolbar: Node = panel.logger_option_button.get_parent()
	var main_vbox: Node = top_toolbar.get_parent()
	# main_hbox should also be a child of main_vbox
	assert_object(panel.main_hbox.get_parent()).is_equal(main_vbox)


func test_logger_dropdown_not_in_main_hbox() -> void:
	# Logger dropdown should NOT be inside main_hbox hierarchy
	var parent: Node = panel.logger_option_button.get_parent()
	assert_object(parent).is_not_equal(panel.main_hbox)
	assert_object(parent).is_not_equal(panel.left_vbox)
	assert_object(parent).is_not_equal(panel.right_toolbar)


# =============================================================================
# Adding Log Entries Tests
# =============================================================================

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


# =============================================================================
# Level Toggle Filter Tests
# =============================================================================

func test_disable_single_level_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Info message")
	
	# Disable DEBUG level
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).not_contains("Debug message")
	assert_str(display_text).contains("Info message")


func test_disable_multiple_level_filters() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.TRACE, "Trace")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.DEBUG, "Debug")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Info")
	panel.add_log_entry("12:34:56.004", &"Test", LogLevel.Level.WARN, "Warn")
	panel.add_log_entry("12:34:56.005", &"Test", LogLevel.Level.ERROR, "Error")
	
	# Disable TRACE, DEBUG, INFO - only show WARN and above
	panel.level_toggles[LogLevel.Level.TRACE] = false
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel.level_toggles[LogLevel.Level.INFO] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).not_contains("Trace")
	assert_str(display_text).not_contains("Debug")
	assert_str(display_text).not_contains("Info")
	assert_str(display_text).contains("Warn")
	assert_str(display_text).contains("Error")


func test_reenable_level_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	
	# Disable then re-enable
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	panel.level_toggles[LogLevel.Level.DEBUG] = true
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Debug message")


func test_level_toggle_callback() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	
	# Simulate button toggle
	panel._on_level_toggle_changed(false, LogLevel.Level.DEBUG)
	
	await get_tree().process_frame
	
	assert_bool(panel.level_toggles[LogLevel.Level.DEBUG]).is_false()
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).not_contains("Debug message")


# =============================================================================
# Search Filter Tests
# =============================================================================

func test_search_filter_by_message() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Hello world")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Goodbye world")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Hello again")
	
	panel.current_search_filter = "Hello"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Hello world")
	assert_str(display_text).contains("Hello again")
	assert_str(display_text).not_contains("Goodbye world")


func test_search_filter_case_insensitive() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "HELLO world")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "hello again")
	
	panel.current_search_filter = "hello"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("HELLO world")
	assert_str(display_text).contains("hello again")


func test_search_filter_by_logger_name() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Physics", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Network", LogLevel.Level.INFO, "Message 3")
	
	panel.current_search_filter = "Network"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Message 1")
	assert_str(display_text).contains("Message 3")
	assert_str(display_text).not_contains("Message 2")


func test_search_filter_callback() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Hello world")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Goodbye world")
	
	# Simulate search box text change
	panel._on_search_changed("Hello")
	
	await get_tree().process_frame
	
	assert_str(panel.current_search_filter).is_equal("Hello")
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Hello world")
	assert_str(display_text).not_contains("Goodbye world")


func test_clear_search_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Hello")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Goodbye")
	
	panel._on_search_changed("Hello")
	panel._on_search_changed("")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Hello")
	assert_str(display_text).contains("Goodbye")


# =============================================================================
# Logger Filter Tests
# =============================================================================

func test_filter_by_logger_name() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Network message")
	panel.add_log_entry("12:34:56.002", &"Physics", LogLevel.Level.INFO, "Physics message")
	
	panel.current_logger_filter = &"Network"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Network message")
	assert_str(display_text).not_contains("Physics message")


func test_logger_dropdown_updated_on_new_logger() -> void:
	panel.add_log_entry("12:34:56.001", &"NewLogger", LogLevel.Level.INFO, "Message")
	
	await get_tree().process_frame
	
	# Should have "All Loggers" + "NewLogger"
	assert_int(panel.logger_option_button.item_count).is_equal(2)


func test_logger_dropdown_shows_entry_counts() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.INFO, "Msg 1")
	panel.add_log_entry("12:34:56.002", &"Network", LogLevel.Level.INFO, "Msg 2")
	panel.add_log_entry("12:34:56.003", &"Physics", LogLevel.Level.INFO, "Msg 3")
	
	await get_tree().process_frame
	
	# Check dropdown text contains count
	var network_text: String = panel.logger_option_button.get_item_text(1)
	assert_str(network_text).contains("Network")
	assert_str(network_text).contains("(2)")


# =============================================================================
# Combined Filter Tests
# =============================================================================

func test_combined_logger_and_level_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Network", LogLevel.Level.DEBUG, "Network Debug")
	panel.add_log_entry("12:34:56.002", &"Network", LogLevel.Level.INFO, "Network Info")
	panel.add_log_entry("12:34:56.003", &"Physics", LogLevel.Level.DEBUG, "Physics Debug")
	panel.add_log_entry("12:34:56.004", &"Physics", LogLevel.Level.INFO, "Physics Info")
	
	panel.current_logger_filter = &"Network"
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Network Info")
	assert_str(display_text).not_contains("Network Debug")
	assert_str(display_text).not_contains("Physics Debug")
	assert_str(display_text).not_contains("Physics Info")


func test_combined_search_and_level_filter() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Hello Debug")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Hello Info")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.DEBUG, "Goodbye Debug")
	
	panel.current_search_filter = "Hello"
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Hello Info")
	assert_str(display_text).not_contains("Hello Debug")
	assert_str(display_text).not_contains("Goodbye Debug")


# =============================================================================
# Auto-scroll Tests
# =============================================================================

func test_auto_scroll_toggle() -> void:
	panel._on_auto_scroll_toggled(false)
	
	assert_bool(panel.auto_scroll).is_false()
	assert_bool(panel.log_display.scroll_following).is_false()
	
	panel._on_auto_scroll_toggled(true)
	
	assert_bool(panel.auto_scroll).is_true()
	assert_bool(panel.log_display.scroll_following).is_true()


# =============================================================================
# Clear and Copy Tests
# =============================================================================

func test_clear_log() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	
	panel._on_clear_pressed()
	
	await get_tree().process_frame
	
	assert_int(panel.log_buffer.get_entry_count()).is_equal(0)
	assert_str(panel.log_display.get_parsed_text()).is_empty()


func test_copy_all_when_nothing_selected() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Test message")
	
	await get_tree().process_frame
	
	# This would copy to clipboard - just verify it doesn't crash
	panel._on_copy_pressed()
	
	# Verify the text exists to copy
	var text: String = panel.log_display.get_parsed_text()
	assert_str(text).contains("Test message")


# =============================================================================
# Entry Count Display Tests
# =============================================================================

func test_entry_count_display_all() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	assert_str(panel.entry_count_label.text).is_equal("3 entries")


func test_entry_count_display_filtered() -> void:
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Info")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.WARN, "Warn")
	
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	# Should show "2 / 3" format when filtered
	assert_str(panel.entry_count_label.text).is_equal("2 / 3")


# =============================================================================
# UI Component Property Tests
# =============================================================================

func test_search_box_has_clear_button() -> void:
	assert_bool(panel.search_box.clear_button_enabled).is_true()


func test_search_box_has_placeholder() -> void:
	assert_str(panel.search_box.placeholder_text).is_not_empty()


func test_level_buttons_have_correct_text() -> void:
	assert_str(panel.level_toggle_buttons[LogLevel.Level.TRACE].text).is_equal("TRACE")
	assert_str(panel.level_toggle_buttons[LogLevel.Level.DEBUG].text).is_equal("DEBUG")
	assert_str(panel.level_toggle_buttons[LogLevel.Level.INFO].text).is_equal("INFO")
	assert_str(panel.level_toggle_buttons[LogLevel.Level.WARN].text).is_equal("WARN")
	assert_str(panel.level_toggle_buttons[LogLevel.Level.ERROR].text).is_equal("ERROR")
	assert_str(panel.level_toggle_buttons[LogLevel.Level.FATAL].text).is_equal("FATAL")


func test_tool_buttons_have_tooltips() -> void:
	assert_str(panel.clear_button.tooltip_text).is_not_empty()
	assert_str(panel.copy_button.tooltip_text).is_not_empty()
	assert_str(panel.collapse_button.tooltip_text).is_not_empty()
	assert_str(panel.auto_scroll_button.tooltip_text).is_not_empty()


func test_clear_and_copy_buttons_in_same_row() -> void:
	# Clear and Copy should share the same parent HBoxContainer
	var clear_parent: Node = panel.clear_button.get_parent()
	var copy_parent: Node = panel.copy_button.get_parent()
	assert_object(clear_parent).is_equal(copy_parent)
	assert_object(clear_parent).is_instanceof(HBoxContainer)


func test_collapse_and_autoscroll_buttons_in_same_row() -> void:
	# Collapse and Auto-scroll should share the same parent HBoxContainer
	var collapse_parent: Node = panel.collapse_button.get_parent()
	var autoscroll_parent: Node = panel.auto_scroll_button.get_parent()
	assert_object(collapse_parent).is_equal(autoscroll_parent)
	assert_object(collapse_parent).is_instanceof(HBoxContainer)


func test_button_groups_are_separate() -> void:
	# The two button groups should have different parents
	var clear_parent: Node = panel.clear_button.get_parent()
	var collapse_parent: Node = panel.collapse_button.get_parent()
	assert_object(clear_parent).is_not_equal(collapse_parent)


func test_clear_button_has_flat_styling() -> void:
	# Check that normal state has transparent background (StyleBoxFlat override)
	var style: StyleBox = panel.clear_button.get_theme_stylebox("normal")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_equal(0.0)


func test_copy_button_has_flat_styling() -> void:
	var style: StyleBox = panel.copy_button.get_theme_stylebox("normal")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_equal(0.0)


func test_collapse_button_has_flat_styling() -> void:
	var style: StyleBox = panel.collapse_button.get_theme_stylebox("normal")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_equal(0.0)


func test_auto_scroll_button_has_flat_styling() -> void:
	var style: StyleBox = panel.auto_scroll_button.get_theme_stylebox("normal")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_equal(0.0)


func test_level_toggle_buttons_have_flat_styling() -> void:
	for level: LogLevel.Level in LogLevel.Level.values():
		var style: StyleBox = panel.level_toggle_buttons[level].get_theme_stylebox("normal")
		assert_object(style).is_instanceof(StyleBoxFlat)
		assert_float((style as StyleBoxFlat).bg_color.a).is_equal(0.0)


func test_toggle_buttons_have_pressed_state_styling() -> void:
	# Pressed state should have visible background for toggle indication
	var style: StyleBox = panel.collapse_button.get_theme_stylebox("pressed")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_greater(0.0)


func test_buttons_have_hover_state_styling() -> void:
	# Hover state should have visible background
	var style: StyleBox = panel.clear_button.get_theme_stylebox("hover")
	assert_object(style).is_instanceof(StyleBoxFlat)
	assert_float((style as StyleBoxFlat).bg_color.a).is_greater(0.0)


func test_right_toolbar_has_separators() -> void:
	# Count HSeparator children in right_toolbar
	var separator_count: int = 0
	for child: Node in panel.right_toolbar.get_children():
		if child is HSeparator:
			separator_count += 1
	# Should have 2 separators: one between row1/row2, one before level toggles
	assert_int(separator_count).is_equal(2)
	
	
# =============================================================================
# Collapse Toggle Tests
# =============================================================================
 
func test_collapse_toggle_default_state() -> void:
	assert_bool(panel.collapse_duplicates).is_false()
	assert_bool(panel.collapse_button.button_pressed).is_false()
 
 
func test_collapse_toggle_enables_collapse() -> void:
	panel._on_collapse_toggled(true)
	
	assert_bool(panel.collapse_duplicates).is_true()
 
 
func test_collapse_toggle_disables_collapse() -> void:
	panel._on_collapse_toggled(true)
	panel._on_collapse_toggled(false)
	
	assert_bool(panel.collapse_duplicates).is_false()
 
 
# =============================================================================
# Collapse Key Generation Tests
# =============================================================================
 
func test_get_collapse_key_format() -> void:
	panel.add_log_entry("12:34:56.789", &"TestLogger", LogLevel.Level.INFO, "Test message")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	var key: String = panel._get_collapse_key(entries[0])
	
	assert_str(key).is_equal("TestLogger|2|Test message")  # INFO = 2
 
 
func test_get_collapse_key_different_messages() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger", LogLevel.Level.INFO, "Message A")
	panel.add_log_entry("12:34:56.002", &"Logger", LogLevel.Level.INFO, "Message B")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	var key1: String = panel._get_collapse_key(entries[0])
	var key2: String = panel._get_collapse_key(entries[1])
	
	assert_str(key1).is_not_equal(key2)
 
 
func test_get_collapse_key_same_messages() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Logger", LogLevel.Level.INFO, "Same message")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	var key1: String = panel._get_collapse_key(entries[0])
	var key2: String = panel._get_collapse_key(entries[1])
	
	assert_str(key1).is_equal(key2)
 
 
# =============================================================================
# Entry Match Tests
# =============================================================================
 
func test_entries_match_for_collapse_identical() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Logger", LogLevel.Level.INFO, "Message")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	
	assert_bool(panel._entries_match_for_collapse(entries[0], entries[1])).is_true()
 
 
func test_entries_match_for_collapse_different_message() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger", LogLevel.Level.INFO, "Message A")
	panel.add_log_entry("12:34:56.002", &"Logger", LogLevel.Level.INFO, "Message B")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	
	assert_bool(panel._entries_match_for_collapse(entries[0], entries[1])).is_false()
 
 
func test_entries_match_for_collapse_different_level() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Logger", LogLevel.Level.DEBUG, "Message")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	
	assert_bool(panel._entries_match_for_collapse(entries[0], entries[1])).is_false()
 
 
func test_entries_match_for_collapse_different_logger() -> void:
	panel.add_log_entry("12:34:56.001", &"Logger1", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Logger2", LogLevel.Level.INFO, "Message")
	
	var entries: Array[LogBuffer.LogEntry] = panel.log_buffer.get_all_entries()
	
	assert_bool(panel._entries_match_for_collapse(entries[0], entries[1])).is_false()
 
 
# =============================================================================
# Collapse Display Tests
# =============================================================================
 
func test_collapse_shows_count_for_duplicates() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should show count indicator
	assert_str(display_text).contains("(x3)")
	# Should only show one instance of the message
	assert_int(display_text.count("Same message")).is_equal(1)
 
 
func test_collapse_no_count_for_single_message() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Single message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should not show count indicator for single message
	assert_str(display_text).not_contains("(x")
	assert_str(display_text).contains("Single message")
 
 
func test_collapse_groups_consecutive_duplicates() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message A")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message A")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message B")
	panel.add_log_entry("12:34:56.004", &"Test", LogLevel.Level.INFO, "Message B")
	panel.add_log_entry("12:34:56.005", &"Test", LogLevel.Level.INFO, "Message B")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	assert_str(display_text).contains("Message A")
	assert_str(display_text).contains("(x2)")
	assert_str(display_text).contains("Message B")
	assert_str(display_text).contains("(x3)")
 
 
func test_collapse_does_not_group_non_consecutive_duplicates() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message A")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message B")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message A")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# "Message A" should appear twice (not collapsed since not consecutive)
	assert_int(display_text.count("Message A")).is_equal(2)
	assert_str(display_text).not_contains("(x2)")
 
 
func test_collapse_disabled_shows_all_entries() -> void:
	panel._on_collapse_toggled(false)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should show all three instances
	assert_int(display_text.count("Same message")).is_equal(3)
	assert_str(display_text).not_contains("(x")
 
 
# =============================================================================
# Collapse with Filters Tests
# =============================================================================
 
func test_collapse_respects_level_filter() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.DEBUG, "Debug message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.DEBUG, "Debug message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Info message")
	panel.add_log_entry("12:34:56.004", &"Test", LogLevel.Level.INFO, "Info message")
	
	# Disable DEBUG level
	panel.level_toggles[LogLevel.Level.DEBUG] = false
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should only show INFO messages collapsed
	assert_str(display_text).not_contains("Debug message")
	assert_str(display_text).contains("Info message")
	assert_str(display_text).contains("(x2)")
 
 
func test_collapse_respects_logger_filter() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Logger1", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Logger1", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.003", &"Logger2", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.004", &"Logger2", LogLevel.Level.INFO, "Message")
	
	# Filter to Logger1 only
	panel.current_logger_filter = &"Logger1"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should only show Logger1 messages collapsed
	assert_str(display_text).contains("Logger1")
	assert_str(display_text).contains("(x2)")
	assert_str(display_text).not_contains("Logger2")
 
 
func test_collapse_respects_search_filter() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Hello world")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Hello world")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Goodbye world")
	panel.add_log_entry("12:34:56.004", &"Test", LogLevel.Level.INFO, "Goodbye world")
	
	# Search for "Hello"
	panel.current_search_filter = "Hello"
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should only show "Hello world" messages collapsed
	assert_str(display_text).contains("Hello world")
	assert_str(display_text).contains("(x2)")
	assert_str(display_text).not_contains("Goodbye")
 
 
# =============================================================================
# Entry Count with Collapse Tests
# =============================================================================
 
func test_entry_count_shows_collapsed_count() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	# Format should be "collapsed (actual) / total" when different
	# With 3 identical messages collapsed to 1, should show "1 (3) / 3"
	assert_str(panel.entry_count_label.text).is_equal("1 (3) / 3")
 
 
func test_entry_count_no_special_format_when_all_unique() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	# All unique, no collapsing happened
	assert_str(panel.entry_count_label.text).is_equal("3 entries")
 
 
func test_entry_count_collapse_disabled() -> void:
	panel._on_collapse_toggled(false)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	# Collapse disabled, should show normal count
	assert_str(panel.entry_count_label.text).is_equal("3 entries")
 
 
# =============================================================================
# Real-time Collapse Update Tests
# =============================================================================
 
func test_realtime_collapse_increments_count() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Repeating message")
	await get_tree().process_frame
	
	var display_text1: String = panel.log_display.get_parsed_text()
	assert_str(display_text1).not_contains("(x")
	
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Repeating message")
	await get_tree().process_frame
	
	var display_text2: String = panel.log_display.get_parsed_text()
	assert_str(display_text2).contains("(x2)")
 
 
func test_realtime_new_unique_message_starts_new_group() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "First message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "First message")
	
	await get_tree().process_frame
	
	var display_text1: String = panel.log_display.get_parsed_text()
	assert_str(display_text1).contains("(x2)")
	assert_int(display_text1.count("First message")).is_equal(1)
	
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Second message")
	
	await get_tree().process_frame
	
	var display_text2: String = panel.log_display.get_parsed_text()
	assert_str(display_text2).contains("Second message")
	assert_int(display_text2.count("First message")).is_equal(1)
	assert_int(display_text2.count("Second message")).is_equal(1)
 
 
# =============================================================================
# Toggle Collapse On/Off Tests
# =============================================================================
 
func test_toggle_collapse_on_collapses_existing_entries() -> void:
	# Start with collapse disabled
	panel._on_collapse_toggled(false)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	var display_before: String = panel.log_display.get_parsed_text()
	assert_int(display_before.count("Same message")).is_equal(3)
	
	# Enable collapse
	panel._on_collapse_toggled(true)
	
	await get_tree().process_frame
	
	var display_after: String = panel.log_display.get_parsed_text()
	assert_int(display_after.count("Same message")).is_equal(1)
	assert_str(display_after).contains("(x3)")
 
 
func test_toggle_collapse_off_expands_entries() -> void:
	# Start with collapse enabled
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Same message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Same message")
	
	await get_tree().process_frame
	
	var display_before: String = panel.log_display.get_parsed_text()
	assert_int(display_before.count("Same message")).is_equal(1)
	assert_str(display_before).contains("(x3)")
	
	# Disable collapse
	panel._on_collapse_toggled(false)
	
	await get_tree().process_frame
	
	var display_after: String = panel.log_display.get_parsed_text()
	assert_int(display_after.count("Same message")).is_equal(3)
	assert_str(display_after).not_contains("(x3)")
 
 
# =============================================================================
# Clear with Collapse Tests
# =============================================================================
 
func test_clear_resets_collapse_tracking() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message")
	
	await get_tree().process_frame
	
	assert_object(panel._last_displayed_entry).is_not_null()
	assert_int(panel._last_entry_count).is_equal(2)
	
	panel._on_clear_pressed()
	
	await get_tree().process_frame
	
	assert_object(panel._last_displayed_entry).is_null()
	assert_int(panel._last_entry_count).is_equal(0)
 
 
# =============================================================================
# Edge Cases
# =============================================================================
 
func test_collapse_empty_buffer() -> void:
	panel._on_collapse_toggled(true)
	panel._refresh_display()
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).is_empty()
 
 
func test_collapse_single_entry() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Only entry")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Only entry")
	assert_str(display_text).not_contains("(x")
 
 
func test_collapse_all_different_messages() -> void:
	panel._on_collapse_toggled(true)
	
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message 1")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.INFO, "Message 2")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.INFO, "Message 3")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	assert_str(display_text).contains("Message 1")
	assert_str(display_text).contains("Message 2")
	assert_str(display_text).contains("Message 3")
	assert_str(display_text).not_contains("(x")
 
 
func test_collapse_mixed_levels_same_message() -> void:
	panel._on_collapse_toggled(true)
	
	# Same message but different levels should NOT be collapsed
	panel.add_log_entry("12:34:56.001", &"Test", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Test", LogLevel.Level.WARN, "Message")
	panel.add_log_entry("12:34:56.003", &"Test", LogLevel.Level.ERROR, "Message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should show all three (different levels = different groups)
	assert_int(display_text.count("Message")).is_equal(3)
	assert_str(display_text).not_contains("(x")
 
 
func test_collapse_mixed_loggers_same_message() -> void:
	panel._on_collapse_toggled(true)
	
	# Same message but different loggers should NOT be collapsed
	panel.add_log_entry("12:34:56.001", &"Logger1", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.002", &"Logger2", LogLevel.Level.INFO, "Message")
	panel.add_log_entry("12:34:56.003", &"Logger3", LogLevel.Level.INFO, "Message")
	
	await get_tree().process_frame
	
	var display_text: String = panel.log_display.get_parsed_text()
	
	# Should show all three (different loggers = different groups)
	assert_int(display_text.count("Message")).is_equal(3)
	assert_str(display_text).not_contains("(x")
 
