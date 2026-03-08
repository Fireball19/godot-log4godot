## Example demonstrating basic usage of the Log4Godot logging plugin.
##
## This example shows how to configure the global logger, create named loggers
## for different game systems, use various log levels, and manage loggers at runtime.
## It also demonstrates keyboard input handling to interactively test logging features.
extends Node

# Example of how to use the Advanced Logger plugin
@onready
var log4g: LoggerInstance = Log4g.get_logger(&"COSTUM", LogLevel.Level.TRACE)

func _ready() -> void:
	# Configure the global logger
	Log4g.set_global_level(LogLevel.Level.DEBUG)
	Log4g.set_colors_enabled(true)
	Log4g.set_timestamps_enabled(true)
	Log4g.set_file_logging_enabled(true, "user://my_game.log")
	
	# Using the global logger
	log4g.info("Game started successfully!")
	log4g.debug("This is a debug message")
	log4g.warn("This is a warning message")
	log4g.error("This is an error message")
	log4g.trace("This trace message won't show (below global level)")
	
	# Create named loggers for different systems
	var network_logger: LoggerInstance = Log4g.get_logger(&"Network", LogLevel.Level.INFO)
	var ai_logger: LoggerInstance = Log4g.get_logger(&"AI", LogLevel.Level.DEBUG)
	var physics_logger: LoggerInstance = Log4g.get_logger(&"Physics", LogLevel.Level.WARN)
	
	# Use named loggers
	network_logger.info("Connected to server")
	network_logger.debug("Received packet: size=1024")
	
	ai_logger.debug("Pathfinding calculation started")
	ai_logger.info("AI state changed to ATTACKING")
	
	physics_logger.warn("Physics body overlapping detected")
	physics_logger.error("Collision detection failed!")
	
	# Demonstrate different log levels with colors
	demonstrate_log_levels()
	
	# Show logger management
	demonstrate_logger_management()

func demonstrate_log_levels() -> void:
	log4g.info("=== Demonstrating all log levels ===")
	
	# This will show all levels except TRACE (which is below our global level)
	log4g.trace("TRACE: Very detailed information")
	log4g.debug("DEBUG: Detailed information for debugging")
	log4g.info("INFO: General information about program execution")
	log4g.warn("WARN: Something unexpected happened, but program continues")
	log4g.error("ERROR: A serious problem occurred")
	log4g.fatal("FATAL: A critical error that might cause program termination")

func demonstrate_logger_management() -> void:
	log4g.info("=== Logger Management Demo ===")
	
	# Create some loggers
	var ui_logger: LoggerInstance = Log4g.get_logger(&"UI")
	var sound_logger: LoggerInstance = Log4g.get_logger(&"Sound")
	var save_logger: LoggerInstance = Log4g.get_logger(&"SaveSystem")
	
	# List all loggers
	var loggers: Array[String] = Log4g.list_loggers()
	log4g.info("Active loggers: " + str(loggers))
	
	# Use the loggers
	ui_logger.info("Menu opened")
	sound_logger.debug("Playing background music")
	save_logger.info("Game saved successfully")
	
	# Change log level for specific logger
	ui_logger.set_level(LogLevel.Level.WARN)
	ui_logger.info("This won't show (below logger's level)")
	ui_logger.warn("This will show")
	
	# Remove a logger
	Log4g.remove_logger(&"Sound")
	log4g.info("Removed Sound logger. Active loggers: " + str(Log4g.list_loggers()))

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var input_event: InputEventKey = event as InputEventKey
		if input_event.pressed:
			match input_event.keycode:
				KEY_1:
					log4g.info("Key 1 pressed - Info level test")
				KEY_2:
					log4g.warn("Key 2 pressed - Warning level test")
				KEY_3:
					log4g.error("Key 3 pressed - Error level test")
				KEY_C:
					Log4g.clear_log_file()
					log4g.info("Log file cleared!")
				KEY_T:
					Log4g.set_timestamps_enabled(not Log4g.get_timestamps_enabled())
					log4g.info("Timestamps toggled: " + str(Log4g.get_timestamps_enabled()))
				KEY_L:
					# Change global log level
					var current_level: LogLevel.Level = Log4g.get_global_level()
					var new_level: int = (current_level + 1) % 6
					Log4g.set_global_level(new_level)
					print("Global log level changed to: " + Log4g.log_level_to_string(new_level))
