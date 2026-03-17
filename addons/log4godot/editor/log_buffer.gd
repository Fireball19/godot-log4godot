## Stores log entries in memory for the editor panel.
##
## This class maintains a circular buffer of log entries that can be
## filtered by logger name and log level. It emits signals when new
## entries are added, allowing the UI to update in real-time.
@tool
class_name LogBuffer
extends RefCounted

## Emitted when a new log entry is added to the buffer.
signal log_added(entry: LogEntry)

## Emitted when the buffer is cleared.
signal buffer_cleared()

## Maximum number of entries to store in the buffer.
const MAX_ENTRIES: int = 1000

## Internal storage for log entries.
var _entries: Array[LogEntry] = []

## Set of unique logger names that have been seen.
var _logger_names: Dictionary = {}

## Represents a single log entry with all metadata.
class LogEntry extends RefCounted:
	var timestamp: String
	var logger_name: StringName
	var level: LogLevel.Level
	var message: String
	var raw_time: int  # For sorting/comparison
	
	func _init(p_timestamp: String, p_logger_name: StringName, p_level: LogLevel.Level, p_message: String) -> void:
		timestamp = p_timestamp
		logger_name = p_logger_name
		level = p_level
		message = p_message
		raw_time = Time.get_ticks_msec()

## Adds a new log entry to the buffer.
## If the buffer exceeds MAX_ENTRIES, the oldest entry is removed.
func add_entry(timestamp: String, logger_name: StringName, level: LogLevel.Level, message: String) -> void:
	var entry := LogEntry.new(timestamp, logger_name, level, message)
	_entries.append(entry)
	_logger_names[logger_name] = true
	
	# Remove oldest entries if buffer is full
	while _entries.size() > MAX_ENTRIES:
		_entries.pop_front()
	
	log_added.emit(entry)

## Clears all entries from the buffer.
func clear() -> void:
	_entries.clear()
	buffer_cleared.emit()

## Returns all entries in the buffer.
func get_all_entries() -> Array[LogEntry]:
	return _entries

## Returns entries filtered by logger name and minimum level.
## [br][br]
## [param logger_filter]: Logger name to filter by, or empty string for all loggers.
## [param min_level]: Minimum log level to include.
func get_filtered_entries(logger_filter: StringName = &"", min_level: LogLevel.Level = LogLevel.Level.TRACE) -> Array[LogEntry]:
	var filtered: Array[LogEntry] = []
	
	for entry: LogEntry in _entries:
		# Check logger filter
		if logger_filter != &"" and entry.logger_name != logger_filter:
			continue
		
		# Check level filter
		if entry.level < min_level:
			continue
		
		filtered.append(entry)
	
	return filtered

## Returns a list of all unique logger names that have been seen.
func get_logger_names() -> Array[StringName]:
	var names: Array[StringName] = []
	for key: StringName in _logger_names.keys():
		names.append(key)
	# Sort using custom comparison to handle StringName properly
	names.sort_custom(func(a: StringName, b: StringName) -> bool: return String(a) < String(b))
	return names

## Returns the number of entries in the buffer.
func get_entry_count() -> int:
	return _entries.size()

## Returns the number of entries for a specific logger.
func get_entry_count_for_logger(logger_name: StringName) -> int:
	var count: int = 0
	for entry: LogEntry in _entries:
		if entry.logger_name == logger_name:
			count += 1
	return count
