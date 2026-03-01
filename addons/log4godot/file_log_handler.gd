## Manages file-specific logging operations.
##
## This class handles all file I/O operations for the logging system,
## including creating log files, writing log entries, and clearing logs.
## It ensures proper file handling and automatic session headers.
class_name FileLogHandler

## The path to the log file where messages will be written.
## Defaults to "user://game.log" in the user data directory.
var file_path: String

## Whether file logging is currently enabled.
## When disabled, [method write_log] calls are ignored.
var is_enabled: bool = false

## Initializes the file handler with the specified log file path.
## [br][br]
## [param path]: The file path for the log file. Defaults to "user://game.log".
func _init(path: String = "user://game.log") -> void:
	set_file_path(path)

## Enables or disables file logging.
## When enabled, creates the log file if it doesn't exist.
## [br][br]
## [param enabled]: If [code]true[/code], enables file logging and ensures the log file exists.
func set_enabled(enabled: bool) -> void:
	is_enabled = enabled
	if enabled:
		_ensure_log_file()

## Sets the path for the log file.
## If logging is currently enabled, ensures the new file exists.
## [br][br]
## [param path]: The new file path for log output (e.g., "user://debug.log").
func set_file_path(path: String) -> void:
	file_path = path
	if is_enabled:
		_ensure_log_file()

## Writes a log message to the file.
## Does nothing if file logging is disabled.
## [br][br]
## [param message]: The pre-formatted log message to write.
## Each message is written on a new line.
func write_log(message: String) -> void:
	if not is_enabled:
		return
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ_WRITE)
	if file:
		file.seek_end()
		file.store_line(message)
		file.close()

## Clears the log file and writes a "Log Cleared" header with timestamp.
## Does nothing if file logging is disabled.
func clear_log_file() -> void:
	if not is_enabled:
		return
		
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE_READ)
	if file:
		file.store_line("=== Log Cleared: " + Time.get_datetime_string_from_system() + " ===")
		file.close()

## Creates the log file if it doesn't exist, with a session start header.
## Called internally when file logging is enabled or the file path changes.
func _ensure_log_file() -> void:
	if FileAccess.file_exists(file_path):
		return
	
	var file: FileAccess = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_line("=== Logger Session Started: " + Time.get_datetime_string_from_system() + " ===")
		file.close()
