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
    for action: String in required_actions:
        _check(InputMap.has_action(action), "input action exists: " + action)
        if InputMap.has_action(action):
            _check(not InputMap.action_get_events(action).is_empty(), "input action has bindings: " + action)

    if router != null:
        var movement: Vector2 = router.call("movement_vector")
        _check(movement.length() <= 1.001, "movement router returns normalized-safe vector")

    if failures == 0:
        print("BLACKROOT INPUT FRAMEWORK SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT INPUT FRAMEWORK SMOKE FAILED: %d checks failed" % failures)
        quit(1)
