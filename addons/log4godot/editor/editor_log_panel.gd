## Editor panel for viewing and filtering Log4Godot logs.
##
## This panel integrates into the Godot editor as a bottom dock panel,
## displaying log messages from all Log4Godot loggers with filtering
## capabilities by logger name and log level.
## Messages are received via EditorDebuggerPlugin from the running game.
@tool
class_name EditorLogPanel
extends Control

## Reference to the shared log buffer.
var log_buffer: LogBuffer

## Currently selected logger filter (empty = all loggers).
var current_logger_filter: StringName = &""

## Currently selected minimum log level.
var current_level_filter: LogLevel.Level = LogLevel.Level.TRACE

## Whether auto-scroll is enabled.
var auto_scroll: bool = true

## UI Components
var toolbar: HBoxContainer
var logger_option_button: OptionButton
var level_option_button: OptionButton
var clear_button: Button
var auto_scroll_check: CheckBox
var copy_button: Button
var log_display: RichTextLabel
var entry_count_label: Label

## Theme colors cache
var _level_colors: Dictionary = {
	LogLevel.Level.TRACE: Color(0.6, 0.6, 0.6),
	LogLevel.Level.DEBUG: Color(0.5, 0.8, 1.0),
	LogLevel.Level.INFO: Color(0.8, 0.8, 0.8),
	LogLevel.Level.WARN: Color(1.0, 0.9, 0.3),
	LogLevel.Level.ERROR: Color(1.0, 0.4, 0.4),
	LogLevel.Level.FATAL: Color(1.0, 0.2, 0.2),
}

func _init() -> void:
	log_buffer = LogBuffer.new()

func _ready() -> void:
	_setup_ui()
	_connect_signals()

func _setup_ui() -> void:
	# Main vertical layout
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(vbox)
	
	# Toolbar
	toolbar = HBoxContainer.new()
	toolbar.custom_minimum_size.y = 32
	vbox.add_child(toolbar)
	
	# Logger filter label
	var logger_label := Label.new()
	logger_label.text = "Logger:"
	toolbar.add_child(logger_label)
	
	# Logger filter dropdown
	logger_option_button = OptionButton.new()
	logger_option_button.custom_minimum_size.x = 120
	logger_option_button.add_item("All Loggers", 0)
	logger_option_button.selected = 0
	logger_option_button.item_selected.connect(_on_logger_filter_changed)
	toolbar.add_child(logger_option_button)
	
	# Spacer
	var spacer1 := Control.new()
	spacer1.custom_minimum_size.x = 16
	toolbar.add_child(spacer1)
	
	# Level filter label
	var level_label := Label.new()
	level_label.text = "Level:"
	toolbar.add_child(level_label)
	
	# Level filter dropdown
	level_option_button = OptionButton.new()
	level_option_button.custom_minimum_size.x = 100
	for level: LogLevel.Level in LogLevel.Level.values():
		level_option_button.add_item(LogLevel.level_to_string(level), level)
	level_option_button.selected = 0  # TRACE = show all
	level_option_button.item_selected.connect(_on_level_filter_changed)
	toolbar.add_child(level_option_button)
	
	# Spacer
	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toolbar.add_child(spacer2)
	
	# Entry count label
	entry_count_label = Label.new()
	entry_count_label.text = "0 entries"
	toolbar.add_child(entry_count_label)
	
	# Spacer
	var spacer3 := Control.new()
	spacer3.custom_minimum_size.x = 16
	toolbar.add_child(spacer3)
	
	# Auto-scroll checkbox
	auto_scroll_check = CheckBox.new()
	auto_scroll_check.text = "Auto-scroll"
	auto_scroll_check.button_pressed = true
	auto_scroll_check.toggled.connect(_on_auto_scroll_toggled)
	toolbar.add_child(auto_scroll_check)
	
	# Copy button
	copy_button = Button.new()
	copy_button.text = "Copy"
	copy_button.pressed.connect(_on_copy_pressed)
	toolbar.add_child(copy_button)
	
	# Clear button
	clear_button = Button.new()
	clear_button.text = "Clear"
	clear_button.pressed.connect(_on_clear_pressed)
	toolbar.add_child(clear_button)
	
	# Separator
	var separator := HSeparator.new()
	vbox.add_child(separator)
	
	# Log display area
	log_display = RichTextLabel.new()
	log_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_display.bbcode_enabled = true
	log_display.scroll_following = true
	log_display.selection_enabled = true
	log_display.context_menu_enabled = true
	log_display.add_theme_font_size_override("normal_font_size", 14)
	vbox.add_child(log_display)

func _connect_signals() -> void:
	log_buffer.log_added.connect(_on_log_added)
	log_buffer.buffer_cleared.connect(_on_buffer_cleared)

## Called by the plugin when a log message is received from the running game.
func add_log_entry(timestamp: String, logger_name: StringName, level: LogLevel.Level, message: String) -> void:
	log_buffer.add_entry(timestamp, logger_name, level, message)
	_update_logger_dropdown()

func _on_log_added(entry: LogBuffer.LogEntry) -> void:
	# Check if entry passes current filters
	if _entry_passes_filter(entry):
		_append_entry_to_display(entry)
	_update_entry_count()

func _on_buffer_cleared() -> void:
	log_display.clear()
	_update_entry_count()

func _entry_passes_filter(entry: LogBuffer.LogEntry) -> bool:
	# Check logger filter
	if current_logger_filter != &"" and entry.logger_name != current_logger_filter:
		return false
	
	# Check level filter
	if entry.level < current_level_filter:
		return false
	
	return true

func _append_entry_to_display(entry: LogBuffer.LogEntry) -> void:
	var color: Color = _level_colors.get(entry.level, Color.WHITE)
	var level_str: String = LogLevel.level_to_string(entry.level)
	
	# Format: [timestamp] [LEVEL] [LoggerName] message
	var formatted: String = "[color=#%s]" % color.to_html(false)
	formatted += "[%s] [%s] [%s] %s" % [entry.timestamp, level_str, entry.logger_name, entry.message]
	formatted += "[/color]\n"
	
	log_display.append_text(formatted)

func _refresh_display() -> void:
	log_display.clear()
	var entries: Array[LogBuffer.LogEntry] = log_buffer.get_filtered_entries(current_logger_filter, current_level_filter)
	for entry: LogBuffer.LogEntry in entries:
		_append_entry_to_display(entry)
	_update_entry_count()

func _update_logger_dropdown() -> void:
	var current_selection: int = logger_option_button.selected
	var current_text: String = ""
	if current_selection >= 0:
		current_text = logger_option_button.get_item_text(current_selection)
	
	logger_option_button.clear()
	logger_option_button.add_item("All Loggers", 0)
	
	var logger_names: Array[StringName] = log_buffer.get_logger_names()
	var idx: int = 1
	var new_selection: int = 0
	
	for logger_name: StringName in logger_names:
		var count: int = log_buffer.get_entry_count_for_logger(logger_name)
		var display_text: String = "%s (%d)" % [logger_name, count]
		logger_option_button.add_item(display_text, idx)
		
		if current_text.begins_with(String(logger_name)):
			new_selection = idx
		idx += 1
	
	logger_option_button.selected = new_selection

func _update_entry_count() -> void:
	var filtered: Array[LogBuffer.LogEntry] = log_buffer.get_filtered_entries(current_logger_filter, current_level_filter)
	var total: int = log_buffer.get_entry_count()
	
	if current_logger_filter == &"" and current_level_filter == LogLevel.Level.TRACE:
		entry_count_label.text = "%d entries" % total
	else:
		entry_count_label.text = "%d / %d entries" % [filtered.size(), total]

func _on_logger_filter_changed(index: int) -> void:
	if index == 0:
		current_logger_filter = &""
	else:
		var logger_names: Array[StringName] = log_buffer.get_logger_names()
		if index - 1 < logger_names.size():
			current_logger_filter = logger_names[index - 1]
	_refresh_display()

func _on_level_filter_changed(index: int) -> void:
	current_level_filter = index as LogLevel.Level
	_refresh_display()

func _on_auto_scroll_toggled(enabled: bool) -> void:
	auto_scroll = enabled
	log_display.scroll_following = enabled

func _on_copy_pressed() -> void:
	var text: String = log_display.get_parsed_text()
	DisplayServer.clipboard_set(text)

func _on_clear_pressed() -> void:
	log_buffer.clear()
