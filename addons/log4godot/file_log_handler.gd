# FileLogHandler.gd
# Manages file-specific logging operations
class_name FileLogHandler

var file_path: String
var is_enabled: bool = false

func _init(path: String = "user://game.log"):
	file_path = path

func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	if enabled:
		_ensure_log_file()

func set_file_path(path: String) -> void:
	file_path = path
	if is_enabled:
		_ensure_log_file()

func write_log(message: String) -> void:
	if not is_enabled:
		return
		
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.seek_end()
		file.store_line(message)
		file.close()

func clear_log() -> void:
	if not is_enabled:
		return
		
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("=== Log Cleared: " + Time.get_datetime_string_from_system() + " ===")
		file.close()

func _ensure_log_file() -> void:
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("=== Logger Session Started: " + Time.get_datetime_string_from_system() + " ===")
		file.close()
