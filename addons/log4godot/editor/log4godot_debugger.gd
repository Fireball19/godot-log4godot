## EditorDebuggerPlugin for receiving Log4Godot messages from the running game.
##
## This class uses Godot's built-in debugger protocol to receive log messages
## from the running game. It's the proper way to communicate between the
## editor and the running game, using the same mechanism as Godot's Output panel.
@tool
class_name Log4GodotDebugger
extends EditorDebuggerPlugin

## Signal emitted when a log message is received from the game.
signal log_received(timestamp: String, logger_name: StringName, level: int, message: String)

## Signal emitted when a session starts (game starts running).
signal session_started()

## Signal emitted when a session stops (game stops running).
signal session_stopped()

## The message prefix used for Log4Godot messages.
const MESSAGE_PREFIX: String = "log4godot"

## Called when a debugger session starts.
func _setup_session(session_id: int) -> void:
	# Get the session and connect to its signals
	var session: EditorDebuggerSession = get_session(session_id)
	
	# Connect to session signals
	session.started.connect(_on_session_started)
	session.stopped.connect(_on_session_stopped)

## Called to check if this plugin has a capture for the given prefix.
func _has_capture(capture: String) -> bool:
	return capture == MESSAGE_PREFIX

## Called when a message with our prefix is received from the game.
func _capture(message: String, data: Array, session_id: int) -> bool:
	if message == "log4godot:log_entry":
		if data.size() >= 4:
			var timestamp: String = str(data[0])
			var logger_name: StringName = StringName(str(data[1]))
			var level: int = int(data[2])
			var log_message: String = str(data[3])
			
			log_received.emit(timestamp, logger_name, level, log_message)
		return true
	
	return false

func _on_session_started() -> void:
	session_started.emit()

func _on_session_stopped() -> void:
	session_stopped.emit()
