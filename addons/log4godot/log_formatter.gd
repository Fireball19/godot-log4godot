# LogFormatter.gd
# Handles message formatting logic
class_name LogFormatter

var enable_timestamps: bool = true
var timestamp_format: String = "[%02d:%02d:%02d.%03d]"

func set_timestamps_enabled(enabled: bool) -> void:
	enable_timestamps = enabled

func format_message(logger_name: String, level: LogLevel.Level, message: String) -> String:
	var parts: Array[String] = []
	
	# Add timestamp if enabled
	if enable_timestamps:
		parts.append(_format_timestamp())
	
	# Add log level
	parts.append("[" + LogLevel.level_to_string(level) + "]")
	
	# Add logger name if not main
	if logger_name != "Main":
		parts.append("[" + logger_name + "]")
	
	# Add the actual message
	parts.append(message)
	
	return " ".join(parts)

func _format_timestamp() -> String:
	var time = Time.get_datetime_dict_from_system()
	return timestamp_format % [time.hour, time.minute, time.second, Time.get_ticks_msec() % 1000]
