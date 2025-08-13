extends Node

# Example demonstrating the theming features of Log4Godot
var costum_logger: LoggerInstance

func _ready():
	# Configure the global logger
	Logger.set_global_level(LogLevel.Level.DEBUG)
	Logger.set_colors_enabled(true)
	Logger.set_timestamps_enabled(true)
	Logger.set_file_logging_enabled(true, "user://themed_game.log")
	
	costum_logger = Logger.get_logger("COSTUM", LogLevel.Level.TRACE)
	
	# Try different themes
	await _demonstrate_themes()
	
	# Create and use a custom theme
	_demonstrate_custom_theme()

func _demonstrate_all_levels(logger: LoggerInstance):
	logger.trace("TRACE: Detailed debugging information")
	logger.debug("DEBUG: Development debugging message")
	logger.info("INFO: General information message")
	logger.warn("WARN: Warning about potential issues")
	logger.error("ERROR: An error has occurred")
	logger.fatal("FATAL: Critical system failure")

func _demonstrate_themes():
	var themes = Logger.get_available_themes()
	Logger.info("Available themes: " + str(themes))
	
	for theme_name in themes:
		Logger.set_theme_by_name(theme_name)
		Logger.info("=== Switched to " + theme_name + " theme ===")
		_demonstrate_all_levels(Logger.get_global_logger())
		_demonstrate_all_levels(costum_logger)
		await get_tree().create_timer(1.0).timeout  # Small delay for visual effect

func _demonstrate_custom_theme():
	Logger.info("=== Creating Custom Theme ===")
	
	# Create a custom "Neon" theme
	var neon_theme = LogTheme.new()
	neon_theme.theme_name = "Neon"
	neon_theme.trace_color = Color(0.5, 0.5, 1.0)      # Light blue
	neon_theme.debug_color = Color(1.0, 0.0, 1.0)      # Magenta
	neon_theme.info_color = Color(0.0, 1.0, 1.0)       # Cyan
	neon_theme.warn_color = Color(1.0, 1.0, 0.0)       # Yellow
	neon_theme.error_color = Color(1.0, 0.5, 0.0)      # Orange
	neon_theme.fatal_color = Color(1.0, 0.0, 0.5)      # Hot pink
	neon_theme.timestamp_color = Color(0.7, 0.7, 0.7)  # Light gray
	
	# Add the custom theme
	Logger.add_custom_theme("Neon", neon_theme)
	
	# Use the custom theme
	Logger.set_theme_by_name("Neon")
	Logger.info("Now using custom Neon theme!")
	_demonstrate_all_levels(Logger.get_global_logger())
	_demonstrate_all_levels(costum_logger)
