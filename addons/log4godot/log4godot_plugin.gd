## Log4Godot Plugin Entry Point
## Handles plugin initialization and autoload singleton registration.
##
## This script is the EditorPlugin entry point for Log4Godot.
## It automatically registers the Log4g autoload singleton when the plugin is enabled.
@tool
extends EditorPlugin

## Called when the plugin is enabled in the Project Settings.
## Registers the Log4g autoload singleton for global access to the logging system.
func _enter_tree() -> void:
	add_autoload_singleton("Log4g", "res://addons/log4godot/logger.gd")

## Called when the plugin is disabled in the Project Settings.
## Removes the Log4g autoload singleton.
func _exit_tree() -> void:
	remove_autoload_singleton("Log4g")
