extends SceneTree

var failures := 0

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String) -> void:
    if condition:
        print("PASS: " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)

func _run() -> void:
    await process_frame
    var router := root.get_node_or_null("InputRouter")
    _check(router != null, "InputRouter autoload exists")
    if router != null:
        router.call("ensure_default_actions")

    var required_actions := ["move_left", "move_right", "move_up", "move_down", "attack", "dodge", "pause"]
    var counts: Dictionary = {}
    for action: String in required_actions:
        _check(InputMap.has_action(action), "input action exists: " + action)
        if not InputMap.has_action(action):
            continue
        var events := InputMap.action_get_events(action)
        counts[action] = events.size()
        _check(not events.is_empty(), "input action has bindings: " + action)
        var has_desktop := false
        var has_controller := false
        for event: InputEvent in events:
            has_desktop = has_desktop or event is InputEventKey or event is InputEventMouseButton
            has_controller = has_controller or event is InputEventJoypadButton or event is InputEventJoypadMotion
        _check(has_desktop, "input action has desktop binding: " + action)
        _check(has_controller, "input action has controller binding: " + action)

    if router != null:
        for _i: int in range(20):
            router.call("ensure_default_actions")
        for action: String in required_actions:
            _check(InputMap.action_get_events(action).size() == int(counts.get(action, -1)), "binding merge is idempotent: " + action)
        var movement: Vector2 = router.call("movement_vector")
        _check(movement.length() <= 1.001, "movement router returns normalized-safe vector")

    if failures == 0:
        print("BLACKROOT INPUT FRAMEWORK SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT INPUT FRAMEWORK SMOKE FAILED: %d checks failed" % failures)
        quit(1)
