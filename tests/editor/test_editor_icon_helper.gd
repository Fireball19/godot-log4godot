# test_editor_icon_helper.gd
# Unit tests for EditorIconHelper class using gdUnit4
#
# Note: Many tests in this file require editor context to fully execute.
# When running outside the editor (Engine.is_editor_hint() == false),
# the EditorIconHelper methods return null, which is the expected behavior.
# Tests are structured to verify both editor and non-editor behavior.
extends GdUnitTestSuite

func before_test() -> void:
	# Clear any cached icons before each test
	EditorIconHelper.clear_cache()

func after_test() -> void:
	# Clean up cache after each test
	EditorIconHelper.clear_cache()


# ============================================================================
# Test: get_common_icon_names()
# This method works in any context
# ============================================================================

func test_get_common_icon_names_returns_array() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	assert_array(names).is_not_null()
	assert_array(names).is_not_empty()

func test_get_common_icon_names_contains_expected_icons() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	# Check for node type icons
	assert_bool("Node" in names).is_true()
	assert_bool("Node2D" in names).is_true()
	assert_bool("Node3D" in names).is_true()
	assert_bool("Control" in names).is_true()

func test_get_common_icon_names_contains_script_icons() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	assert_bool("Script" in names).is_true()
	assert_bool("GDScript" in names).is_true()
	assert_bool("CSharpScript" in names).is_true()

func test_get_common_icon_names_contains_action_icons() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	assert_bool("Play" in names).is_true()
	assert_bool("Pause" in names).is_true()
	assert_bool("Stop" in names).is_true()
	assert_bool("Reload" in names).is_true()

func test_get_common_icon_names_contains_status_icons() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	assert_bool("StatusSuccess" in names).is_true()
	assert_bool("StatusWarning" in names).is_true()
	assert_bool("StatusError" in names).is_true()
	assert_bool("Error" in names).is_true()
	assert_bool("Warning" in names).is_true()

func test_get_common_icon_names_contains_progress_icons() -> void:
	var names := EditorIconHelper.get_common_icon_names()
	
	for i in range(1, 9):
		var progress_name := "Progress%d" % i
		assert_bool(progress_name in names).is_true()


# ============================================================================
# Test: get_icon() - Non-editor context behavior
# When not in editor, should return null gracefully
# ============================================================================

func test_get_icon_returns_texture_or_null() -> void:
	var icon := EditorIconHelper.get_icon("Play")
	
	# In editor: returns Texture2D
	# Outside editor: returns null
	if Engine.is_editor_hint():
		assert_object(icon).is_not_null()
		assert_object(icon).is_instanceof(Texture2D)
	else:
		assert_object(icon).is_null()

func test_get_icon_with_invalid_name() -> void:
	var icon := EditorIconHelper.get_icon("ThisIconDoesNotExist12345")
	
	# Should return null for non-existent icons
	assert_object(icon).is_null()

func test_get_icon_with_empty_name() -> void:
	var icon := EditorIconHelper.get_icon("")
	
	assert_object(icon).is_null()

func test_get_icon_with_modulation_returns_texture_or_null() -> void:
	var icon := EditorIconHelper.get_icon("Error", Color.RED)
	
	if Engine.is_editor_hint():
		assert_object(icon).is_not_null()
		assert_object(icon).is_instanceof(Texture2D)
	else:
		assert_object(icon).is_null()


# ============================================================================
# Test: has_icon()
# ============================================================================

func test_has_icon_for_common_icons() -> void:
	if not Engine.is_editor_hint():
		# Outside editor, has_icon always returns false
		assert_bool(EditorIconHelper.has_icon("Play")).is_false()
		return
	
	# In editor, common icons should exist
	assert_bool(EditorIconHelper.has_icon("Play")).is_true()
	assert_bool(EditorIconHelper.has_icon("Node")).is_true()
	assert_bool(EditorIconHelper.has_icon("Error")).is_true()

func test_has_icon_for_nonexistent_icon() -> void:
	assert_bool(EditorIconHelper.has_icon("ThisIconDoesNotExist12345")).is_false()

func test_has_icon_for_empty_string() -> void:
	assert_bool(EditorIconHelper.has_icon("")).is_false()


# ============================================================================
# Test: get_flipped_icon()
# ============================================================================

func test_get_flipped_icon_returns_texture_or_null() -> void:
	var icon := EditorIconHelper.get_flipped_icon("ArrowRight")
	
	if Engine.is_editor_hint():
		assert_object(icon).is_not_null()
		assert_object(icon).is_instanceof(Texture2D)
	else:
		assert_object(icon).is_null()

func test_get_flipped_icon_with_invalid_name() -> void:
	var icon := EditorIconHelper.get_flipped_icon("ThisIconDoesNotExist12345")
	
	assert_object(icon).is_null()


# ============================================================================
# Test: get_spinner()
# ============================================================================

func test_get_spinner_returns_animated_texture_or_null() -> void:
	var spinner := EditorIconHelper.get_spinner()
	
	if Engine.is_editor_hint():
		assert_object(spinner).is_not_null()
		assert_object(spinner).is_instanceof(AnimatedTexture)
		assert_int(spinner.frames).is_equal(8)
	else:
		assert_object(spinner).is_null()


# ============================================================================
# Test: get_color_animated_icon()
# ============================================================================

func test_get_color_animated_icon_returns_animated_texture_or_null() -> void:
	var animated := EditorIconHelper.get_color_animated_icon("Error", Color.RED, Color.YELLOW)
	
	if Engine.is_editor_hint():
		assert_object(animated).is_not_null()
		assert_object(animated).is_instanceof(AnimatedTexture)
		assert_int(animated.frames).is_equal(8)
	else:
		assert_object(animated).is_null()


# ============================================================================
# Test: get_editor_color()
# ============================================================================

func test_get_editor_color_returns_default_when_not_in_editor() -> void:
	if Engine.is_editor_hint():
		# Skip this test in editor - we want to test non-editor behavior
		return
	
	var default_color := Color.MAGENTA
	var result := EditorIconHelper.get_editor_color("nonexistent/path", default_color)
	
	assert_object(result).is_equal(default_color)

func test_get_editor_color_with_invalid_path_returns_default() -> void:
	var default_color := Color.CYAN
	var result := EditorIconHelper.get_editor_color("this/path/does/not/exist/12345", default_color)
	
	# Should return default since path doesn't exist
	assert_object(result).is_equal(default_color)


# ============================================================================
# Test: get_editor_base_control()
# ============================================================================

func test_get_editor_base_control_returns_control_or_null() -> void:
	var base_control := EditorIconHelper.get_editor_base_control()
	
	if Engine.is_editor_hint():
		assert_object(base_control).is_not_null()
		assert_object(base_control).is_instanceof(Control)
	else:
		assert_object(base_control).is_null()


# ============================================================================
# Test: clear_cache()
# ============================================================================

func test_clear_cache_does_not_crash() -> void:
	# Simply verify that clear_cache can be called without error
	EditorIconHelper.clear_cache()
	
	# Call it again to ensure it handles empty cache
	EditorIconHelper.clear_cache()
	
	# If we get here without error, the test passes
	assert_bool(true).is_true()

func test_clear_cache_clears_icon_cache() -> void:
	if not Engine.is_editor_hint():
		# Skip cache behavior test outside editor
		return
	
	# Load an icon to populate cache
	var _icon1 := EditorIconHelper.get_icon("Play")
	var _icon2 := EditorIconHelper.get_icon("Error", Color.RED)
	
	# Clear cache
	EditorIconHelper.clear_cache()
	
	# Icons should still be retrievable (re-fetched from editor)
	var icon_after_clear := EditorIconHelper.get_icon("Play")
	assert_object(icon_after_clear).is_not_null()


# ============================================================================
# Test: Caching behavior
# ============================================================================

func test_icon_caching_returns_same_instance() -> void:
	if not Engine.is_editor_hint():
		return
	
	var icon1 := EditorIconHelper.get_icon("Node")
	var icon2 := EditorIconHelper.get_icon("Node")
	
	# Same icon name should return cached instance
	assert_object(icon1).is_same(icon2)

func test_modulated_icon_caching() -> void:
	if not Engine.is_editor_hint():
		return
	
	var icon1 := EditorIconHelper.get_icon("Error", Color.RED)
	var icon2 := EditorIconHelper.get_icon("Error", Color.RED)
	
	# Same icon + color should return cached instance
	assert_object(icon1).is_same(icon2)

func test_different_colors_return_different_icons() -> void:
	if not Engine.is_editor_hint():
		return
	
	var icon_red := EditorIconHelper.get_icon("Error", Color.RED)
	var icon_blue := EditorIconHelper.get_icon("Error", Color.BLUE)
	
	# Different colors should return different textures
	assert_object(icon_red).is_not_same(icon_blue)


# ============================================================================
# Test: Edge cases and robustness
# ============================================================================

func test_get_icon_handles_special_characters_in_name() -> void:
	# Icon names with special characters should not crash
	var icon := EditorIconHelper.get_icon("Node/With/Slashes")
	assert_object(icon).is_null()  # Invalid name, but should not crash

func test_multiple_rapid_calls_do_not_crash() -> void:
	# Stress test: rapid successive calls
	for i in range(100):
		var _icon := EditorIconHelper.get_icon("Play")
	
	# If we get here, the test passes
	assert_bool(true).is_true()

func test_get_icon_with_black_color_returns_unmodulated() -> void:
	if not Engine.is_editor_hint():
		return
	
	# Color.BLACK is the default/no-modulation sentinel
	var icon_default := EditorIconHelper.get_icon("Play")
	var icon_black := EditorIconHelper.get_icon("Play", Color.BLACK)
	
	# Both should return the same unmodulated icon
	assert_object(icon_default).is_same(icon_black)
