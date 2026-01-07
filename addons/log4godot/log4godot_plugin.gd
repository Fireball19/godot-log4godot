@tool
extends EditorPlugin

func _enter_tree() -> void:
	add_autoload_singleton("Log4g", "res://addons/log4godot/logger.gd")

func _exit_tree() -> void:
	remove_autoload_singleton("Log4g")
