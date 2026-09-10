extends SceneTree

var failures := 0
const GAME_SIZE := Vector2(320.0, 180.0)

func _initialize() -> void:
    call_deferred("_run")

func _check(condition: bool, label: String) -> void:
    if condition:
        print("PASS: " + label)
    else:
        failures += 1
        push_error("FAIL: " + label)

func _screen_from_game(game_position: Vector2) -> Vector2:
    var visible_size := root.get_visible_rect().size
    if visible_size.x <= 0.0 or visible_size.y <= 0.0 or visible_size.is_equal_approx(GAME_SIZE):
        return game_position
    var fit_scale := minf(visible_size.x / GAME_SIZE.x, visible_size.y / GAME_SIZE.y)
    var rendered_size := GAME_SIZE * fit_scale
    var offset := (visible_size - rendered_size) * 0.5
    return offset + game_position * fit_scale

func _touch_event(index: int, game_position: Vector2, pressed: bool) -> InputEventScreenTouch:
    var event := InputEventScreenTouch.new()
    event.index = index
    event.position = _screen_from_game(game_position)
    event.pressed = pressed
    return event

func _drag_event(index: int, game_position: Vector2) -> InputEventScreenDrag:
    var event := InputEventScreenDrag.new()
    event.index = index
    event.position = _screen_from_game(game_position)
    return event

func _run() -> void:
    var packed := load("res://scenes/main.tscn") as PackedScene
    _check(packed != null, "main scene loads")
    if packed == null:
        quit(1)
        return

    var game := packed.instantiate()
    root.add_child(game)
    current_scene = game
    await process_frame

    _check(int(game.get("state")) == 0, "title state boots")

    game.call("_show_hub")
    _check(int(game.get("state")) == 1, "title -> hub")

    game.call("_show_weapons")
    _check(int(game.get("state")) == 2, "hub -> weapon select")

    var weapons: Array = game.get("weapons")
    _check(weapons.size() >= 3, "three weapon choices available")
    game.call("_choose_weapon", weapons[0])
    _check(int(game.get("state")) == 3, "weapon -> Rootmark select")

    var marks: Array = game.get("marks")
    _check(marks.size() >= 3, "three Rootmark choices available")
    game.call("_start_run", marks[0])
    await process_frame

    _check(int(game.get("state")) == 4, "Rootmark starts expedition")
    var player: Node2D = game.get("player")
    var enemies: Array = game.get("enemies")
    _check(player != null and is_instance_valid(player), "player spawned")
    _check(enemies.size() >= 3, "first encounter spawned")

    var touch := root.get_node_or_null("TouchPlaytest")
    _check(touch != null, "touch adapter autoload exists")
    if player != null and is_instance_valid(player) and touch != null:
        touch.set("touch_device", true)
        if touch.get("hud") == null:
            touch.call("_build_styles")
            touch.call("_build_hud")

        # Exercise the real ScreenTouch + ScreenDrag path used by phones.
        var before_touch := player.position
        touch.call("_input", _touch_event(1, Vector2(35, 145), true))
        touch.call("_input", _drag_event(1, Vector2(67, 145)))
        touch.call("_process", 0.10)
        touch.call("_input", _touch_event(1, Vector2(67, 145), false))
        _check(player.position.x > before_touch.x, "screen-drag movement moves player")
        _check(Vector2(touch.get("move_vector")) == Vector2.ZERO, "movement releases cleanly")

        var footer: Variant = game.get("footer_label")
        if footer is Label:
            _check(not (footer as Label).visible, "mobile combat hides desktop footer")

        enemies = game.get("enemies")
        if enemies.size() > 0:
            var enemy: Node2D = enemies[0]
            player.set("facing", Vector2.RIGHT)
            enemy.position = player.position + Vector2(13, 0)
            var hp_before: int = int(enemy.get("hp"))
            player.set("attack_cooldown", 0.0)
            touch.call("_input", _touch_event(2, Vector2(286, 142), true))
            touch.call("_input", _touch_event(2, Vector2(286, 142), false))
            _check(int(enemy.get("hp")) < hp_before, "ATTACK touch damages enemy in range")
            _check(int(touch.get("attack_touch_id")) == -1, "attack touch releases cleanly")

        player.set("dodge_cooldown", 0.0)
        player.set("dodge_timer", 0.0)
        touch.call("_input", _touch_event(3, Vector2(226, 152), true))
        _check(float(player.get("dodge_timer")) > 0.0, "DODGE touch starts dodge window")
        var cooldown_after_first := float(player.get("dodge_cooldown"))
        touch.call("_input", _touch_event(3, Vector2(226, 152), true))
        _check(float(player.get("dodge_cooldown")) == cooldown_after_first, "DODGE touch cannot retrigger during cooldown")
        touch.call("_input", _touch_event(3, Vector2(226, 152), false))

        touch.call("_input", _touch_event(4, Vector2(292, 20), true))
        _check(paused, "PAUSE touch pauses")
        touch.call("_input", _touch_event(4, Vector2(292, 20), false))
        touch.call("_input", _touch_event(5, Vector2(292, 20), true))
        _check(not paused, "PAUSE touch resumes")
        touch.call("_input", _touch_event(5, Vector2(292, 20), false))

    game.call("_start_run", marks[1])
    game.set("wave", 3)
    game.call("_advance_encounter")
    await process_frame
    _check(int(game.get("wave")) == 4, "encounter progression reaches guardian wave")

    player = game.get("player")
    if player != null and is_instance_valid(player):
        game.set("run_amber", 6)
        player.call("take_damage", 999)
        await process_frame
        _check(int(game.get("state")) == 5, "lethal damage reaches game-over state")

    game.call("_show_hub")
    game.call("_show_weapons")
    game.call("_choose_weapon", weapons[2])
    game.call("_start_run", marks[2])
    game.set("depth", 3)
    game.set("wave", 4)
    game.call("_advance_encounter")
    await process_frame
    _check(int(game.get("state")) == 6, "depth-three guardian clear reaches victory")

    var exit_code := 0
    if failures == 0:
        print("BLACKROOT GAMEPLAY SMOKE PASSED")
    else:
        push_error("BLACKROOT GAMEPLAY SMOKE FAILED: %d checks failed" % failures)
        exit_code = 1

    current_scene = null
    game.queue_free()
    await process_frame
    await process_frame
    quit(exit_code)
