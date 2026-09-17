extends Node

const ACTION_MOVE_LEFT := "move_left"
const ACTION_MOVE_RIGHT := "move_right"
const ACTION_MOVE_UP := "move_up"
const ACTION_MOVE_DOWN := "move_down"
const ACTION_ATTACK := "attack"
const ACTION_DODGE := "dodge"
const ACTION_PAUSE := "pause"

func _ready() -> void:
    ensure_default_actions()

func ensure_default_actions() -> void:
    _ensure_action(ACTION_MOVE_LEFT, [_key(KEY_A), _key(KEY_LEFT)], [_joy_axis(JOY_AXIS_LEFT_X, -1.0)])
    _ensure_action(ACTION_MOVE_RIGHT, [_key(KEY_D), _key(KEY_RIGHT)], [_joy_axis(JOY_AXIS_LEFT_X, 1.0)])
    _ensure_action(ACTION_MOVE_UP, [_key(KEY_W), _key(KEY_UP)], [_joy_axis(JOY_AXIS_LEFT_Y, -1.0)])
    _ensure_action(ACTION_MOVE_DOWN, [_key(KEY_S), _key(KEY_DOWN)], [_joy_axis(JOY_AXIS_LEFT_Y, 1.0)])
    _ensure_action(ACTION_ATTACK, [_key(KEY_SPACE), _mouse(MOUSE_BUTTON_LEFT)], [_joy_button(JOY_BUTTON_A)])
    _ensure_action(ACTION_DODGE, [_key(KEY_SHIFT)], [_joy_button(JOY_BUTTON_B)])
    _ensure_action(ACTION_PAUSE, [_key(KEY_ESCAPE)], [_joy_button(JOY_BUTTON_START)])

func movement_vector() -> Vector2:
    return Input.get_vector(ACTION_MOVE_LEFT, ACTION_MOVE_RIGHT, ACTION_MOVE_UP, ACTION_MOVE_DOWN, 0.20)

func attack_down() -> bool:
    return Input.is_action_pressed(ACTION_ATTACK)

func dodge_down() -> bool:
    return Input.is_action_pressed(ACTION_DODGE)

func pause_just_pressed() -> bool:
    return Input.is_action_just_pressed(ACTION_PAUSE)

func _ensure_action(action: StringName, keyboard_events: Array, controller_events: Array) -> void:
    if not InputMap.has_action(action):
        InputMap.add_action(action)
    if InputMap.action_get_events(action).is_empty():
        for event: InputEvent in keyboard_events:
            InputMap.action_add_event(action, event)
        for event: InputEvent in controller_events:
            InputMap.action_add_event(action, event)

func _key(code: Key) -> InputEventKey:
    var event := InputEventKey.new()
    event.physical_keycode = code
    return event

func _mouse(button: MouseButton) -> InputEventMouseButton:
    var event := InputEventMouseButton.new()
    event.button_index = button
    return event

func _joy_button(button: JoyButton) -> InputEventJoypadButton:
    var event := InputEventJoypadButton.new()
    event.button_index = button
    return event

func _joy_axis(axis: JoyAxis, axis_value: float) -> InputEventJoypadMotion:
    var event := InputEventJoypadMotion.new()
    event.axis = axis
    event.axis_value = axis_value
    return event
