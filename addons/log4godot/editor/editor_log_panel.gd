## Editor panel for viewing and filtering Log4Godot logs.
##
## This panel integrates into the Godot editor as a bottom dock panel,
## displaying log messages from all Log4Godot loggers with filtering
## capabilities by logger name and log level.
## Messages are received via EditorDebuggerPlugin from the running game.
##
## Layout follows Godot's standard Output panel design:
## - Log display area on the left (maximized)
## - Control buttons on the right (vertical toolbar)
## - Search bar and filters at the bottom
@tool
class_name EditorLogPanel
extends Control

## Reference to the shared log buffer.
var log_buffer: LogBuffer

## Currently selected logger filter (empty = all loggers).
var current_logger_filter: StringName = &""

## Level toggle states - each level can be independently enabled/disabled.
var level_toggles: Dictionary = {
	LogLevel.Level.TRACE: true,
	LogLevel.Level.DEBUG: true,
	LogLevel.Level.INFO: true,
	LogLevel.Level.WARN: true,
	LogLevel.Level.ERROR: true,
	LogLevel.Level.FATAL: true,
}

## Current search/filter text.
var current_search_filter: String = ""

## Whether auto-scroll is enabled.
var auto_scroll: bool = true

## Whether to collapse duplicate messages.
var collapse_duplicates: bool = false

## UI Components - Main layout
var main_hbox: HBoxContainer
var left_vbox: VBoxContainer
var right_toolbar: VBoxContainer
var bottom_toolbar: HBoxContainer

## UI Components - Log display
var log_display: RichTextLabel

## UI Components - Right toolbar buttons
var clear_button: Button
var copy_button: Button
var collapse_button: Button
var auto_scroll_button: Button

## UI Components - Level filter toggle buttons
var level_toggle_buttons: Dictionary = {}

## UI Components - Bottom toolbar
var search_box: LineEdit
var logger_option_button: OptionButton
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

## Short labels for level toggle buttons
const LEVEL_SHORT_LABELS: Dictionary = {
	LogLevel.Level.TRACE: "TRACE",
	LogLevel.Level.DEBUG: "DEBUG",
	LogLevel.Level.INFO: "INFO",
	LogLevel.Level.WARN: "WARN",
	LogLevel.Level.ERROR: "ERROR",
	LogLevel.Level.FATAL: "FATAL",
}


func _init() -> void:
	log_buffer = LogBuffer.new()


func _ready() -> void:
	_setup_ui()
	_connect_signals()


func _setup_ui() -> void:
	# Main vertical layout: [Top Toolbar] | [Log Display + Right Toolbar] | [Bottom Search Bar]
	var main_vbox := VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(main_vbox)
	
	# Top toolbar with logger filter and entry count (spans full width)
	_setup_top_toolbar(main_vbox)
	
	# Middle section: [Log Display + Right Toolbar] as HBox
	main_hbox = HBoxContainer.new()
	main_hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main_hbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(main_hbox)
	
	# Left side: Log display area + bottom search bar
	left_vbox = VBoxContainer.new()
	left_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	left_vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_hbox.add_child(left_vbox)
	
	# Log display area
	_setup_log_display()
	
	# Bottom search bar (inside left_vbox, so it doesn't extend under right toolbar)
	_setup_bottom_toolbar()
	
	# Right side: Vertical toolbar with buttons (aligned with log display)
	_setup_right_toolbar()


func _setup_top_toolbar(parent: VBoxContainer) -> void:
	# Top toolbar: [Logger Dropdown] [Entry Count] ... [spacer]
	var top_toolbar := HBoxContainer.new()
	top_toolbar.custom_minimum_size.y = 28
	parent.add_child(top_toolbar)
	
	# Logger filter label
	var logger_label := Label.new()
	logger_label.text = "Logger:"
	top_toolbar.add_child(logger_label)
	
	# Logger filter dropdown
	logger_option_button = OptionButton.new()
	logger_option_button.custom_minimum_size.x = 140
	logger_option_button.add_item("All Loggers", 0)
	logger_option_button.selected = 0
	logger_option_button.item_selected.connect(_on_logger_filter_changed)
	top_toolbar.add_child(logger_option_button)
	
	# Spacer
	var spacer := Control.new()
	spacer.custom_minimum_size.x = 16
	top_toolbar.add_child(spacer)
	
	# Entry count label
	entry_count_label = Label.new()
	entry_count_label.text = "0 entries"
	top_toolbar.add_child(entry_count_label)
	
	# Expanding spacer to push everything left
	var spacer_expand := Control.new()
	spacer_expand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top_toolbar.add_child(spacer_expand)


func _setup_log_display() -> void:
	# Log display area - takes most of the space
	log_display = RichTextLabel.new()
	log_display.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_display.size_flags_vertical = Control.SIZE_EXPAND_FILL
	log_display.bbcode_enabled = true
	log_display.scroll_following = true
	log_display.selection_enabled = true
	log_display.context_menu_enabled = true
	log_display.add_theme_font_size_override("normal_font_size", 13)
	left_vbox.add_child(log_display)


func _setup_bottom_toolbar() -> void:
	# Bottom toolbar: [Search Box] - inside left_vbox so it aligns with log display
	bottom_toolbar = HBoxContainer.new()
	bottom_toolbar.custom_minimum_size.y = 28
	left_vbox.add_child(bottom_toolbar)
	
	# Search/filter box
	search_box = LineEdit.new()
	search_box.placeholder_text = "Filter messages..."
	search_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	search_box.clear_button_enabled = true
	search_box.text_changed.connect(_on_search_changed)
	bottom_toolbar.add_child(search_box)


func _setup_right_toolbar() -> void:
	# Right vertical toolbar - extends full height
	right_toolbar = VBoxContainer.new()
	right_toolbar.custom_minimum_size.x = 68
	main_hbox.add_child(right_toolbar)
	
	# === First group: Clear and Copy buttons (horizontal) ===
	var tools_hbox := HBoxContainer.new()
	right_toolbar.add_child(tools_hbox)
	
	# Clear button (flat style with hover/pressed feedback)
	clear_button = Button.new()
	clear_button.tooltip_text = "Clear log"
	clear_button.icon = EditorIconHelper.get_icon("Clear")
	clear_button.custom_minimum_size = Vector2(32, 28)
	clear_button.pressed.connect(_on_clear_pressed)
	_apply_flat_button_style(clear_button)
	tools_hbox.add_child(clear_button)
	
	# Copy button (flat style with hover/pressed feedback)
	copy_button = Button.new()
	copy_button.tooltip_text = "Copy selected text (or all if nothing selected)"
	copy_button.icon = EditorIconHelper.get_icon("ActionCopy")
	copy_button.custom_minimum_size = Vector2(32, 28)
	copy_button.pressed.connect(_on_copy_pressed)
	_apply_flat_button_style(copy_button)
	tools_hbox.add_child(copy_button)
	
	# === Separator between row 1 and row 2 ===
	var separator1 := HSeparator.new()
	separator1.custom_minimum_size.y = 4
	right_toolbar.add_child(separator1)
	
	# === Second group: Collapse and Auto-scroll buttons (horizontal) ===
	var toggles_hbox := HBoxContainer.new()
	right_toolbar.add_child(toggles_hbox)
	
	# Collapse duplicates toggle (flat style with toggled feedback)
	collapse_button = Button.new()
	collapse_button.tooltip_text = "Collapse duplicate messages"
	collapse_button.icon = EditorIconHelper.get_icon("CombineLines")
	collapse_button.toggle_mode = true
	collapse_button.button_pressed = false
	collapse_button.custom_minimum_size = Vector2(32, 28)
	collapse_button.toggled.connect(_on_collapse_toggled)
	_apply_flat_toggle_style(collapse_button)
	toggles_hbox.add_child(collapse_button)
	
	# Auto-scroll toggle (flat style with toggled feedback)
	auto_scroll_button = Button.new()
	auto_scroll_button.tooltip_text = "Auto-scroll to new messages"
	auto_scroll_button.icon = EditorIconHelper.get_icon("MoveDown")
	auto_scroll_button.toggle_mode = true
	auto_scroll_button.button_pressed = true
	auto_scroll_button.custom_minimum_size = Vector2(32, 28)
	auto_scroll_button.toggled.connect(_on_auto_scroll_toggled)
	_apply_flat_toggle_style(auto_scroll_button)
	toggles_hbox.add_child(auto_scroll_button)
	
	# === Separator line before level toggles ===
	var separator2 := HSeparator.new()
	separator2.custom_minimum_size.y = 8
	right_toolbar.add_child(separator2)
	
	# === Level filter toggle buttons ===
	_setup_level_toggles()
	
	# Spacer to push buttons to top
	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	right_toolbar.add_child(spacer)


func _setup_level_toggles() -> void:
	# Create a toggle button for each log level
	var levels: Array = [
		LogLevel.Level.TRACE,
		LogLevel.Level.DEBUG,
		LogLevel.Level.INFO,
		LogLevel.Level.WARN,
		LogLevel.Level.ERROR,
		LogLevel.Level.FATAL,
	]
	
	for level: LogLevel.Level in levels:
		var btn := Button.new()
		btn.text = LEVEL_SHORT_LABELS[level]
		btn.tooltip_text = "Toggle %s messages" % LogLevel.level_to_string(level)
		btn.toggle_mode = true
		btn.button_pressed = true
		btn.custom_minimum_size = Vector2(32, 24)
		
		# Apply flat style with hover/pressed/toggled feedback
		_apply_flat_toggle_style(btn)
		
		# Set button color based on level
		var color: Color = _level_colors[level]
		btn.add_theme_color_override("font_color", color)
		btn.add_theme_color_override("font_pressed_color", color)
		btn.add_theme_color_override("font_hover_color", color)
		btn.add_theme_color_override("font_hover_pressed_color", color)
		
		# Connect signal with level parameter
		btn.toggled.connect(_on_level_toggle_changed.bind(level))
		
		right_toolbar.add_child(btn)
		level_toggle_buttons[level] = btn


## Creates an empty (transparent) StyleBoxFlat.
func _create_empty_stylebox() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color.TRANSPARENT
	style.set_corner_radius_all(3)
	return style


## Creates a StyleBoxFlat with the given background color.
func _create_stylebox(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(3)
	return style


## Applies flat button styling: no background normally, but shows background on hover/pressed.
func _apply_flat_button_style(btn: Button) -> void:
	# Normal state: transparent (no background)
	btn.add_theme_stylebox_override("normal", _create_empty_stylebox())
	
	# Hover state: subtle background
	btn.add_theme_stylebox_override("hover", _create_stylebox(Color(1.0, 1.0, 1.0, 0.1)))
	
	# Pressed state: slightly more visible background
	btn.add_theme_stylebox_override("pressed", _create_stylebox(Color(1.0, 1.0, 1.0, 0.15)))
	
	# Focus state: transparent (we don't want focus rectangle)
	btn.add_theme_stylebox_override("focus", _create_empty_stylebox())


## Applies flat toggle button styling: no background when off, background when toggled on.
func _apply_flat_toggle_style(btn: Button) -> void:
	# Normal state (not toggled): transparent
	btn.add_theme_stylebox_override("normal", _create_empty_stylebox())
	
	# Hover state (not toggled): subtle background
	btn.add_theme_stylebox_override("hover", _create_stylebox(Color(1.0, 1.0, 1.0, 0.1)))
	
	# Pressed/toggled state: visible background to indicate "on"
	btn.add_theme_stylebox_override("pressed", _create_stylebox(Color(1.0, 1.0, 1.0, 0.15)))
	
	# Hover while pressed/toggled: slightly brighter
	btn.add_theme_stylebox_override("hover_pressed", _create_stylebox(Color(1.0, 1.0, 1.0, 0.20)))
	
	# Focus state: transparent
	btn.add_theme_stylebox_override("focus", _create_empty_stylebox())


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
	
	# Check level toggle (each level can be independently enabled/disabled)
	if not level_toggles.get(entry.level, true):
		return false
	
	# Check search filter
	if current_search_filter != "":
		var search_lower: String = current_search_filter.to_lower()
		var message_lower: String = entry.message.to_lower()
		var logger_lower: String = String(entry.logger_name).to_lower()
		if not (message_lower.contains(search_lower) or logger_lower.contains(search_lower)):
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
	var entries: Array[LogBuffer.LogEntry] = log_buffer.get_all_entries()
	for entry: LogBuffer.LogEntry in entries:
		if _entry_passes_filter(entry):
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
	var filtered_count: int = 0
	var entries: Array[LogBuffer.LogEntry] = log_buffer.get_all_entries()
	for entry: LogBuffer.LogEntry in entries:
		if _entry_passes_filter(entry):
			filtered_count += 1
	
	var total: int = log_buffer.get_entry_count()
	
	if filtered_count == total:
		entry_count_label.text = "%d entries" % total
	else:
		entry_count_label.text = "%d / %d" % [filtered_count, total]


func _on_logger_filter_changed(index: int) -> void:
	if index == 0:
		current_logger_filter = &""
	else:
		var logger_names: Array[StringName] = log_buffer.get_logger_names()
		if index - 1 < logger_names.size():
			current_logger_filter = logger_names[index - 1]
	_refresh_display()


func _on_level_toggle_changed(enabled: bool, level: LogLevel.Level) -> void:
	level_toggles[level] = enabled
	_refresh_display()


func _on_search_changed(new_text: String) -> void:
	current_search_filter = new_text
	_refresh_display()


func _on_auto_scroll_toggled(enabled: bool) -> void:
	auto_scroll = enabled
	log_display.scroll_following = enabled


func _on_collapse_toggled(enabled: bool) -> void:
	collapse_duplicates = enabled
	# TODO: Implement collapse duplicates feature
	_refresh_display()


func _on_copy_pressed() -> void:
	var text: String = log_display.get_selected_text()
	if text.is_empty():
		text = log_display.get_parsed_text()
	DisplayServer.clipboard_set(text)


func _on_clear_pressed() -> void:
	log_buffer.clear()
