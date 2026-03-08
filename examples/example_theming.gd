## Example demonstrating the theming features of Log4Godot.
##
## This example shows how to switch between built-in themes, create custom themes
## with personalized colors for each log level, and register them for use throughout
## your application.
extends Node

# Example demonstrating the theming features of Log4Godot
@onready
var log4g: LoggerInstance = Log4g.get_logger(&"COSTUM", LogLevel.Level.TRACE)

func _ready() -> void:
	# Configure the global logger
	Log4g.set_global_level(LogLevel.Level.DEBUG)
	Log4g.set_colors_enabled(true)
	Log4g.set_timestamps_enabled(true)
	Log4g.set_file_logging_enabled(true, "user://themed_game.log")
	
	# Try different themes
	await _demonstrate_themes()
	
	# Create and use a custom theme
	_demonstrate_custom_theme()

func _demonstrate_all_levels(logger: LoggerInstance) -> void:
	logger.trace("TRACE: Detailed debugging information")
	logger.debug("DEBUG: Development debugging message")
	logger.info("INFO: General information message")
	logger.warn("WARN: Warning about potential issues")
	logger.error("ERROR: An error has occurred")
	logger.fatal("FATAL: Critical system failure")

func _demonstrate_themes() -> void:
	var themes: Array[String] = Log4g.get_available_themes()
	log4g.info("Available themes: " + str(themes))
	
	for theme_name: String in themes:
		Log4g.set_theme_by_name(theme_name)
		log4g.info("=== Switched to " + theme_name + " theme ===")
		_demonstrate_all_levels(log4g)
		await get_tree().create_timer(1.0).timeout  # Small delay for visual effect

func _demonstrate_custom_theme() -> void:
	log4g.info("=== Creating Custom Theme ===")
	
	# Create a custom "Neon" theme
	var neon_theme: LogTheme = LogTheme.new()
	neon_theme.theme_name = &"Neon"
	neon_theme.trace_color = Color(0.5, 0.5, 1.0)      # Light blue
	neon_theme.debug_color = Color(1.0, 0.0, 1.0)      # Magenta
	neon_theme.info_color = Color(0.0, 1.0, 1.0)       # Cyan
	neon_theme.warn_color = Color(1.0, 1.0, 0.0)       # Yellow
	neon_theme.error_color = Color(1.0, 0.5, 0.0)      # Orange
	neon_theme.fatal_color = Color(1.0, 0.0, 0.5)      # Hot pink
	neon_theme.timestamp_color = Color(0.7, 0.7, 0.7)  # Light gray
	
	# Add the custom theme
	Log4g.add_custom_theme(&"Neon", neon_theme)
	
	# Use the custom theme
	Log4g.set_theme_by_name(&"Neon")
	log4g.info("Now using custom Neon theme!")
	_demonstrate_all_levels(log4g)
