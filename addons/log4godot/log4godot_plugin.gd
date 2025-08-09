@tool
extends EditorPlugin

func _enter_tree():
	add_autoload_singleton("Logger", "res://addons/log4godot/logger.gd")

func _exit_tree():
	remove_autoload_singleton("Logger")
