# test_get_logger_for.gd
# Unit tests for the get_logger_for feature using gdUnit4
extends GdUnitTestSuite

var logger_node: GlobalLogger
var test_file_path: String = "user://test_get_logger_for.log"

func before_test() -> void:
	logger_node = preload("res://addons/log4godot/logger.gd").new()
	logger_node._ready()
	
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)

func after_test() -> void:
	if FileAccess.file_exists(test_file_path):
		DirAccess.remove_absolute(test_file_path)
	
	if logger_node:
		logger_node.free()
	logger_node = null

#region Test get_logger_for function

func test_get_logger_for_returns_logger_instance() -> void:
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node)
	
	assert_object(logger).is_not_null()
	assert_object(logger).is_instanceof(LoggerInstance)
	node.free()

func test_get_logger_for_builtin_class_name() -> void:
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node)
	
	assert_str(logger.name).is_equal("Node")
	node.free()

func test_get_logger_for_with_custom_level() -> void:
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node, LogLevel.Level.ERROR)
	
	assert_int(logger.log_level).is_equal(LogLevel.Level.ERROR)
	node.free()

func test_get_logger_for_default_level() -> void:
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node)
	
	assert_int(logger.log_level).is_equal(LogLevel.Level.INFO)
	node.free()

func test_get_logger_for_same_class_returns_same_logger() -> void:
	var node1: Node = Node.new()
	var node2: Node = Node.new()
	
	var logger1: LoggerInstance = logger_node.get_logger_for(node1)
	var logger2: LoggerInstance = logger_node.get_logger_for(node2)
	
	# Both should return the same logger instance since they derive the same name
	assert_object(logger1).is_equal(logger2)
	
	node1.free()
	node2.free()

func test_get_logger_for_different_classes_returns_different_loggers() -> void:
	var node: Node = Node.new()
	var node2d: Node2D = Node2D.new()
	
	var logger1: LoggerInstance = logger_node.get_logger_for(node)
	var logger2: LoggerInstance = logger_node.get_logger_for(node2d)
	
	assert_str(logger1.name).is_not_equal(logger2.name)
	
	node.free()
	node2d.free()

func test_get_logger_for_registers_in_logger_list() -> void:
	var node: Node = Node.new()
	logger_node.get_logger_for(node)
	
	var loggers: Array[String] = logger_node.list_loggers()
	assert_array(loggers).contains(["Node"])
	
	node.free()

func test_get_logger_for_can_log_messages() -> void:
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node)
	logger.info("Test message from get_logger_for")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	assert_str(content).contains("Test message from get_logger_for")
	assert_str(content).contains("[Node]")
	
	node.free()

#endregion

#region Test with various Godot built-in types

func test_get_logger_for_sprite2d() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	var logger: LoggerInstance = logger_node.get_logger_for(sprite)
	
	assert_str(logger.name).is_equal("Sprite2D")
	sprite.free()

func test_get_logger_for_camera2d() -> void:
	var camera: Camera2D = Camera2D.new()
	var logger: LoggerInstance = logger_node.get_logger_for(camera)
	
	assert_str(logger.name).is_equal("Camera2D")
	camera.free()

func test_get_logger_for_timer() -> void:
	var timer: Timer = Timer.new()
	var logger: LoggerInstance = logger_node.get_logger_for(timer)
	
	assert_str(logger.name).is_equal("Timer")
	timer.free()

func test_get_logger_for_http_request() -> void:
	var http: HTTPRequest = HTTPRequest.new()
	var logger: LoggerInstance = logger_node.get_logger_for(http)
	
	assert_str(logger.name).is_equal("HTTPRequest")
	http.free()

#endregion

#region Test integration with existing logger functionality

func test_get_logger_for_respects_global_level() -> void:
	logger_node.set_global_level(LogLevel.Level.ERROR)
	
	var node: Node = Node.new()
	var logger: LoggerInstance = logger_node.get_logger_for(node, LogLevel.Level.DEBUG)
	
	# Should respect global level
	assert_bool(logger.is_debug_enabled()).is_false()
	assert_bool(logger.is_error_enabled()).is_true()
	
	node.free()

func test_get_logger_for_uses_shared_output() -> void:
	logger_node.set_file_logging_enabled(true, test_file_path)
	
	var node: Node = Node.new()
	var sprite: Sprite2D = Sprite2D.new()
	
	var logger1: LoggerInstance = logger_node.get_logger_for(node)
	var logger2: LoggerInstance = logger_node.get_logger_for(sprite)
	
	logger1.info("Message from Node logger")
	logger2.info("Message from Sprite2D logger")
	
	var file: FileAccess = FileAccess.open(test_file_path, FileAccess.READ)
	var content: String = file.get_as_text()
	file.close()
	
	# Both messages should be in the same log file
	assert_str(content).contains("Message from Node logger")
	assert_str(content).contains("Message from Sprite2D logger")
	assert_str(content).contains("[Node]")
	assert_str(content).contains("[Sprite2D]")
	
	node.free()
	sprite.free()

func test_get_logger_for_can_be_removed() -> void:
	var node: Node = Node.new()
	logger_node.get_logger_for(node)
	
	assert_array(logger_node.list_loggers()).contains(["Node"])
	
	var removed: bool = logger_node.remove_logger("Node")
	assert_bool(removed).is_true()
	assert_array(logger_node.list_loggers()).not_contains(["Node"])
	
	node.free()

func test_get_logger_for_mixed_with_get_logger() -> void:
	var node: Node = Node.new()
	
	# Create logger using get_logger_for
	var logger1: LoggerInstance = logger_node.get_logger_for(node)
	
	# Get the same logger using get_logger with derived name
	var logger2: LoggerInstance = logger_node.get_logger("Node")
	
	# Should be the same instance
	assert_object(logger1).is_equal(logger2)
	
	node.free()

#endregion

#region Test edge cases

func test_get_logger_for_multiple_calls_same_object() -> void:
	var node: Node = Node.new()
	
	var logger1: LoggerInstance = logger_node.get_logger_for(node)
	var logger2: LoggerInstance = logger_node.get_logger_for(node)
	var logger3: LoggerInstance = logger_node.get_logger_for(node)
	
	# All should return the same logger instance
	assert_object(logger1).is_equal(logger2)
	assert_object(logger2).is_equal(logger3)
	
	node.free()

func test_get_logger_for_level_only_applies_on_creation() -> void:
	var node1: Node = Node.new()
	var node2: Node = Node.new()
	
	# First call creates logger with ERROR level
	var logger1: LoggerInstance = logger_node.get_logger_for(node1, LogLevel.Level.ERROR)
	
	# Second call should return existing logger, not create new one with different level
	var logger2: LoggerInstance = logger_node.get_logger_for(node2, LogLevel.Level.DEBUG)
	
	# Both should be same instance with original ERROR level
	assert_object(logger1).is_equal(logger2)
	assert_int(logger2.log_level).is_equal(LogLevel.Level.ERROR)
	
	node1.free()
	node2.free()

func test_get_logger_for_refcounted_object() -> void:
	var ref: RefCounted = RefCounted.new()
	var logger: LoggerInstance = logger_node.get_logger_for(ref)
	
	assert_str(logger.name).is_equal("RefCounted")

func test_get_logger_for_resource() -> void:
	var resource: Resource = Resource.new()
	var logger: LoggerInstance = logger_node.get_logger_for(resource)
	
	assert_str(logger.name).is_equal("Resource")

#endregion
