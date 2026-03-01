# Log4Godot

<div align="left">
	
[![License badge](https://img.shields.io/github/license/Fireball19/godot-log4godot)](https://github.com/Fireball19/godot-log4godot/blob/main/LICENSE)
[![GitHub release badge](https://badgen.net/github/release/Fireball19/godot-log4godot/stable)](https://github.com/Fireball19/godot-log4godot/releases/latest)
![Godot Version badge](https://img.shields.io/badge/Godot-v4.6-%23478cbf?logo=godot-engine&logoColor=white)
[![GdUnit4 Tests badge](https://github.com/Fireball19/godot-log4godot/actions/workflows/ci-develop.yml/badge.svg?branch=develop)](https://github.com/Fireball19/godot-log4godot/actions/workflows/ci-develop.yml)

</div>

<img align="left" src="./icon.svg"/>

Log4Godot brings structured logging to your Godot 4 game development workflow. 
It provides multiple log levels, named loggers, colored output, theming support, and flexible configuration options.

<br clear="left"/>

## ✨ Features

- **6 Log Levels**: TRACE, DEBUG, INFO, WARN, ERROR, FATAL with intuitive color coding
- **Named Loggers**: Create dedicated loggers for different systems (Network, AI, Physics, UI, etc.)
- **Dual Output**: Beautiful colored console output plus optional file logging
- **Theming System**: 4 built-in themes with custom theme support for personalized styling
- **Timestamp Support**: Configurable timestamp formatting with millisecond precision
- **Hierarchical Control**: Set global log levels and override per individual logger

## 🚀 Installation

1. Download or clone this repository
2. Copy the `addons/log4godot/` folder to your project's `addons/` directory
3. Enable "Log4Godot" in Project Settings → Plugins
4. The `Log4g` autoload is automatically configured and ready to use!

## 📖 Quick Start

### Named Loggers
```gdscript
func _ready():
	# Create specialized loggers for different systems
	var network_logger = Log4g.get_logger("Network", LogLevel.Level.DEBUG)
	var ai_logger = Log4g.get_logger("AI", LogLevel.Level.INFO)
	var physics_logger = Log4g.get_logger("Physics", LogLevel.Level.WARN)
	
	# Use them throughout your codebase
	network_logger.debug("Sending packet to server: " + packet_data)
	ai_logger.info("Enemy AI state changed: PATROL → CHASE")
	physics_logger.warn("Collision detection took " + str(delta_time) + "ms")
```

### Logger Instance Methods
Each logger instance provides convenient logging methods for all levels:
```gdscript
var logger = Log4g.get_logger("MySystem")

logger.trace("Detailed trace information")
logger.debug("Debug information for development")
logger.info("General information message")
logger.warn("Warning: something might be wrong")
logger.error("Error occurred: " + error_message)
logger.fatal("Critical failure!")
```
## 🎨 Theming System

Log4Godot includes a theming system that allows you to customize the appearance of your logs with built-in themes or create your own.

### Built-in Themes

- **🎯 Default**: Balanced color scheme with distinct colors for each log level (gray, cyan, yellow, red).
- **🔇 Minimal**: Muted gray for most levels with only errors/fatal in red to reduce visual noise.
- **⚪ Whiteout**: All text in pure white for complete uniformity and high contrast displays.
- **🟢 Fallout**: Retro terminal aesthetic with all text in bright green for that classic console feel.

## 🎛️ Configuration Options

### Global Settings
```gdscript
# Set minimum log level globally (affects all loggers)
Log4g.set_global_level(LogLevel.Level.INFO)

# Toggle colored output in console
Log4g.set_colors_enabled(false)

# Control timestamp display
Log4g.set_timestamps_enabled(true)

# File logging configuration
Log4g.set_file_logging_enabled(true, "user://debug.log")
```

### Per-Logger Control
```gdscript
# Each logger can have its own level
var verbose_logger = Log4g.get_logger("Debug", LogLevel.Level.TRACE)
var quiet_logger = Log4g.get_logger("Release", LogLevel.Level.ERROR)

# Change logger level at runtime
verbose_logger.set_level(LogLevel.Level.WARN)

# Check if specific levels are enabled
if network_logger.is_debug_enabled():
	network_logger.debug("Detailed network state: " + get_network_details())
```

## 📋 Logger Management

```gdscript
# List all created loggers
var loggers = Log4g.list_loggers()

# Remove a logger when no longer needed
Log4g.remove_logger("OldSystem")

# Clear the log file
Log4g.clear_log_file()
```

## 🔧 Utility Methods

```gdscript
# Convert between log levels and strings
var level = Log4g.log_level_from_string("DEBUG")  # Returns LogLevel.Level.DEBUG
var name = Log4g.log_level_to_string(LogLevel.Level.ERROR)  # Returns "ERROR"
```
