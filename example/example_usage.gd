extends Node

# Example of how to use the Advanced Logger plugin

func _ready():
	# Configure the global logger
	Logger.set_global_level(Logger.LogLevel.DEBUG)
	Logger.set_colors_enabled(true)
	Logger.set_timestamps_enabled(true)
	Logger.set_file_logging_enabled(true, "user://my_game.log")
	
	# Using the global logger
	Logger.info("Game started successfully!")
	Logger.debug("This is a debug message")
	Logger.warn("This is a warning message")
	Logger.error("This is an error message")
	Logger.trace("This trace message won't show (below global level)")
	
	# Create named loggers for different systems
	var network_logger = Logger.get_logger("Network", Logger.LogLevel.INFO)
	var ai_logger = Logger.get_logger("AI", Logger.LogLevel.DEBUG)
	var physics_logger = Logger.get_logger("Physics", Logger.LogLevel.WARN)
	
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

func demonstrate_log_levels():
	Logger.info("=== Demonstrating all log levels ===")
	
	# This will show all levels except TRACE (which is below our global level)
	Logger.trace("TRACE: Very detailed information")
	Logger.debug("DEBUG: Detailed information for debugging")
	Logger.info("INFO: General information about program execution")
	Logger.warn("WARN: Something unexpected happened, but program continues")
	Logger.error("ERROR: A serious problem occurred")
	Logger.fatal("FATAL: A critical error that might cause program termination")

func demonstrate_logger_management():
	Logger.info("=== Logger Management Demo ===")
	
	# Create some loggers
	var ui_logger = Logger.get_logger("UI")
	var sound_logger = Logger.get_logger("Sound")
	var save_logger = Logger.get_logger("SaveSystem")
	
	# List all loggers
	var loggers = Logger.list_loggers()
	Logger.info("Active loggers: " + str(loggers))
	
	# Use the loggers
	ui_logger.info("Menu opened")
	sound_logger.debug("Playing background music")
	save_logger.info("Game saved successfully")
	
	# Change log level for specific logger
	ui_logger.set_level(Logger.LogLevel.WARN)
	ui_logger.info("This won't show (below logger's level)")
	ui_logger.warn("This will show")
	
	# Remove a logger
	Logger.remove_logger("Sound")
	Logger.info("Removed Sound logger. Active loggers: " + str(Logger.list_loggers()))

func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				Logger.info("Key 1 pressed - Info level test")
			KEY_2:
				Logger.warn("Key 2 pressed - Warning level test")
			KEY_3:
				Logger.error("Key 3 pressed - Error level test")
			KEY_C:
				Logger.clear_log_file()
				Logger.info("Log file cleared!")
			KEY_T:
				Logger.set_timestamps_enabled(not Logger.enable_timestamps)
				Logger.info("Timestamps toggled: " + str(Logger.enable_timestamps))
			KEY_L:
				# Change global log level
				var current_level = Logger.get_global_level()
				var new_level = (current_level + 1) % 6
				Logger.set_global_level(new_level)
				Logger.info("Global log level changed to: " + Logger.log_level_to_string(new_level))
