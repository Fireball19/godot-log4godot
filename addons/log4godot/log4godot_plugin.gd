## Log4Godot Plugin Entry Point
## Handles plugin initialization, autoload singleton registration, and editor panel.
##
## This script is the EditorPlugin entry point for Log4Godot.
## It automatically registers the Log4g autoload singleton when the plugin is enabled
## and adds a bottom panel dock for viewing and filtering log messages.
## Uses Godot's EngineDebugger protocol to receive logs from running game instances.
@tool
extends EditorPlugin

## The editor log panel instance.
var log_panel: EditorLogPanel

## The debugger plugin for receiving messages from the running game.
var debugger_plugin: Log4GodotDebugger

## Called when the plugin is enabled in the Project Settings.
## Registers the Log4g autoload singleton and creates the editor panel.
func _enter_tree() -> void:
	add_autoload_singleton("Log4g", "res://addons/log4godot/logger.gd")
	
	# Create and register the debugger plugin
	_create_debugger_plugin()
	
	# Create and add the editor log panel
	_create_editor_panel()

## Called when the plugin is disabled in the Project Settings.
## Removes the Log4g autoload singleton and the editor panel.
func _exit_tree() -> void:
	_remove_editor_panel()
	_remove_debugger_plugin()
	remove_autoload_singleton("Log4g")

## Creates and registers the debugger plugin for receiving log messages.
func _create_debugger_plugin() -> void:
	debugger_plugin = Log4GodotDebugger.new()
	debugger_plugin.log_received.connect(_on_log_received)
	debugger_plugin.session_started.connect(_on_session_started)
	add_debugger_plugin(debugger_plugin)

## Removes the debugger plugin.
func _remove_debugger_plugin() -> void:
	if debugger_plugin:
		remove_debugger_plugin(debugger_plugin)
		debugger_plugin = null

## Creates the editor log panel and adds it as a bottom panel.
func _create_editor_panel() -> void:
	log_panel = EditorLogPanel.new()
	log_panel.name = "Log4GodotPanel"
	add_control_to_bottom_panel(log_panel, "Log4Godot")

## Removes the editor log panel from the editor.
func _remove_editor_panel() -> void:
	if log_panel:
		remove_control_from_bottom_panel(log_panel)
		log_panel.queue_free()
		log_panel = null

## Called when a log message is received from the running game.
func _on_log_received(timestamp: String, logger_name: StringName, level: int, message: String) -> void:
	if log_panel:
		log_panel.add_log_entry(timestamp, logger_name, level as LogLevel.Level, message)

## Called when a debugger session starts (game starts running).
func _on_session_started() -> void:
	log_panel.log_buffer.clear()
