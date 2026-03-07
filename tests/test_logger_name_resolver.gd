# test_logger_name_resolver.gd
# Unit tests for the LoggerNameResolver class using gdUnit4
extends GdUnitTestSuite

#region Test to_pascal_case function

func test_to_pascal_case_snake_case() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("my_player_script")).is_equal("MyPlayerScript")

func test_to_pascal_case_single_word() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("player")).is_equal("Player")

func test_to_pascal_case_already_pascal() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("Player")).is_equal("Player")

func test_to_pascal_case_kebab_case() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("my-player-script")).is_equal("MyPlayerScript")

func test_to_pascal_case_mixed_separators() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("my_player-script")).is_equal("MyPlayerScript")

func test_to_pascal_case_empty_string() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("")).is_equal("")

func test_to_pascal_case_with_numbers() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("player_2d")).is_equal("Player2d")

func test_to_pascal_case_consecutive_separators() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("my__player")).is_equal("MyPlayer")

func test_to_pascal_case_leading_separator() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("_player")).is_equal("Player")

func test_to_pascal_case_trailing_separator() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("player_")).is_equal("Player")

func test_to_pascal_case_all_caps() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("PLAYER")).is_equal("PLAYER")

func test_to_pascal_case_mixed_case_snake() -> void:
	assert_str(LoggerNameResolver.to_pascal_case("my_Player_Script")).is_equal("MyPlayerScript")

#endregion

#region Test derive_logger_name function

func test_derive_logger_name_null_object() -> void:
	var logger_name: String = LoggerNameResolver.derive_logger_name(null)
	assert_str(logger_name).is_equal("Unknown")

func test_derive_logger_name_builtin_node() -> void:
	var node: Node = Node.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(node)
	assert_str(logger_name).is_equal("Node")
	node.free()

func test_derive_logger_name_builtin_node2d() -> void:
	var node: Node2D = Node2D.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(node)
	assert_str(logger_name).is_equal("Node2D")
	node.free()

func test_derive_logger_name_builtin_refcounted() -> void:
	var ref: RefCounted = RefCounted.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(ref)
	assert_str(logger_name).is_equal("RefCounted")

func test_derive_logger_name_sprite2d() -> void:
	var sprite: Sprite2D = Sprite2D.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(sprite)
	assert_str(logger_name).is_equal("Sprite2D")
	sprite.free()

func test_derive_logger_name_camera2d() -> void:
	var camera: Camera2D = Camera2D.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(camera)
	assert_str(logger_name).is_equal("Camera2D")
	camera.free()

func test_derive_logger_name_timer() -> void:
	var timer: Timer = Timer.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(timer)
	assert_str(logger_name).is_equal("Timer")
	timer.free()

func test_derive_logger_name_http_request() -> void:
	var http: HTTPRequest = HTTPRequest.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(http)
	assert_str(logger_name).is_equal("HTTPRequest")
	http.free()

func test_derive_logger_name_resource() -> void:
	var resource: Resource = Resource.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(resource)
	assert_str(logger_name).is_equal("Resource")

func test_derive_logger_name_character_body_2d() -> void:
	var body: CharacterBody2D = CharacterBody2D.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(body)
	assert_str(logger_name).is_equal("CharacterBody2D")
	body.free()

func test_derive_logger_name_rigid_body_2d() -> void:
	var body: RigidBody2D = RigidBody2D.new()
	var logger_name: String = LoggerNameResolver.derive_logger_name(body)
	assert_str(logger_name).is_equal("RigidBody2D")
	body.free()

#endregion
