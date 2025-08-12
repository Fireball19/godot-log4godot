# Log4Godot

[![GdUnit4 Tests](https://github.com/Fireball19/godot-log4godot/actions/workflows/gdunit4-tests.yml/badge.svg?branch=develop)](https://github.com/Fireball19/godot-log4godot/actions/workflows/gdunit4-tests.yml)

A powerful, feature-rich logging system for Godot 4 that brings structured logging to your game development workflow. 
Inspired by enterprise logging frameworks, Log4Godot provides multiple log levels, named loggers, colored output, theming support, and flexible configuration options.

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
4. The `Logger` autoload is automatically configured and ready to use!

## 📖 Quick Start

### Basic Logging
```gdscript
func _ready():
	# Simple logging with the global logger
	Logger.info("Game initialized successfully")
	Logger.warn("Audio settings not found, using defaults")
	Logger.error("Failed to connect to server")
	Logger.debug("Player position: " + str(player.position))
```

### Named Loggers
```gdscript
# Create specialized loggers for different systems
var network_logger = Logger.get_logger("Network", LogLevel.Level.DEBUG)
var ai_logger = Logger.get_logger("AI", LogLevel.Level.INFO)
var physics_logger = Logger.get_logger("Physics", LogLevel.Level.WARN)

# Use them throughout your codebase
network_logger.debug("Sending packet to server: " + packet_data)
ai_logger.info("Enemy AI state changed: PATROL → CHASE")
physics_logger.warn("Collision detection took " + str(delta_time) + "ms")
```
## 🎨 Theming System

Log4Godot includes a theming system that allows you to customize the appearance of your logs with built-in themes or create your own.

## 🎛️ Configuration Options

### Global Settings
```gdscript
# Set minimum log level globally (affects all loggers)
Logger.set_global_level(LogLevel.Level.INFO)

# Toggle colored output in console
Logger.set_colors_enabled(false)

# Control timestamp display
Logger.set_timestamps_enabled(true)

# File logging configuration
Logger.set_file_logging_enabled(true, "user://debug.log")
```

### Per-Logger Control
```gdscript
# Each logger can have its own level
var verbose_logger = Logger.get_logger("Debug", LogLevel.Level.TRACE)
var quiet_logger = Logger.get_logger("Release", LogLevel.Level.ERROR)

# Change logger level at runtime
verbose_logger.set_level(LogLevel.Level.WARN)

# Check if specific levels are enabled
if network_logger.is_debug_enabled():
	network_logger.debug("Detailed network state: " + get_network_details())
```
