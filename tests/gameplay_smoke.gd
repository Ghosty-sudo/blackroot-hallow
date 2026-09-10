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

    if player != null and is_instance_valid(player):
        var touch := root.get_node_or_null("TouchPlaytest")
        _check(touch != null, "touch adapter autoload exists")
        if touch != null:
            touch.set("touch_device", true)
            touch.set("move_vector", Vector2.RIGHT)
            var before_touch := player.position
            touch.call("_process", 0.10)
            _check(player.position.x > before_touch.x, "touch movement moves player")
            touch.set("move_vector", Vector2.ZERO)

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
            game.call("_do_attack")
            _check(int(enemy.get("hp")) < hp_before, "attack damages enemy in range")

        player.set("dodge_cooldown", 0.0)
        player.set("dodge_timer", 0.0)
        var dodged: bool = bool(player.call("try_dodge"))
        _check(dodged, "dodge starts")
        _check(float(player.get("dodge_timer")) > 0.0, "dodge grants active dodge window")
        _check(not bool(player.call("try_dodge")), "dodge cannot retrigger during cooldown")

    game.call("_toggle_pause")
    _check(paused, "pause toggles on")
    game.call("_toggle_pause")
    _check(not paused, "pause toggles off")

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

    if failures == 0:
        print("BLACKROOT GAMEPLAY SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT GAMEPLAY SMOKE FAILED: %d checks failed" % failures)
        quit(1)
