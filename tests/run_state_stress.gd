extends SceneTree

const CYCLES := 40
var failures := 0
var game: Node

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
    var scene := load("res://scenes/main.tscn")
    _check(scene != null, "main scene loads")
    if scene == null:
        quit(1)
        return
    game = scene.instantiate()
    root.add_child(game)
    await process_frame

    var weapons: Array = game.get("weapons")
    var marks: Array = game.get("marks")
    _check(not weapons.is_empty(), "weapons available for stress")
    _check(not marks.is_empty(), "rootmarks available for stress")
    if weapons.is_empty() or marks.is_empty():
        quit(1)
        return

    for cycle: int in range(CYCLES):
        game.set("selected_weapon", weapons[cycle % weapons.size()].duplicate(true))
        game.call("_start_run", marks[cycle % marks.size()].duplicate(true))
        await process_frame
        _check(game.get("state") == "run", "cycle %d enters run" % cycle)
        _check(is_instance_valid(game.get("player")), "cycle %d owns live player" % cycle)
        _check(int(game.get("depth")) == 1 and int(game.get("wave")) == 1, "cycle %d starts clean depth/wave" % cycle)

        # Exercise pause/resume state without depending on human input.
        game.call("_show_pause")
        await process_frame
        _check(get_tree().paused, "cycle %d pauses" % cycle)
        game.call("_resume_run")
        await process_frame
        _check(not get_tree().paused and game.get("state") == "run", "cycle %d resumes" % cycle)

        # Force a guardian transition and verify the relic boundary is stable.
        game.set("depth", 1)
        game.set("wave", 4)
        game.set("run_amber", 5)
        game.call("_advance_encounter")
        await process_frame
        _check(int(game.get("depth")) == 2, "cycle %d advances depth" % cycle)
        _check(game.get("state") == "relics", "cycle %d reaches relic choice" % cycle)
        var options: Array = game.get("relic_options")
        _check(not options.is_empty(), "cycle %d has relic options" % cycle)
        if not options.is_empty():
            game.call("_choose_relic", options[0].duplicate(true))
            await process_frame
            _check(game.get("state") == "run", "cycle %d returns from relic choice" % cycle)
            _check(int(game.get("wave")) == 1, "cycle %d starts next depth at encounter one" % cycle)

        # Abandon to hub; queued nodes must be gone before the next cycle.
        game.call("_show_hub")
        await process_frame
        await process_frame
        _check(game.get("player") == null, "cycle %d clears player" % cycle)
        var enemies: Array = game.get("enemies")
        _check(enemies.is_empty(), "cycle %d clears enemy registry" % cycle)
        _check(not get_tree().paused, "cycle %d leaves tree unpaused" % cycle)

    # Exercise final-clear and same-loadout replay repeatedly.
    for cycle: int in range(10):
        game.set("selected_weapon", weapons[cycle % weapons.size()].duplicate(true))
        game.call("_start_run", marks[cycle % marks.size()].duplicate(true))
        await process_frame
        game.set("depth", 3)
        game.set("wave", 4)
        game.set("run_amber", 3)
        game.call("_advance_encounter")
        await process_frame
        _check(game.get("state") == "victory", "clear cycle %d reaches victory" % cycle)
        game.call("_retry_same_loadout")
        await process_frame
        _check(game.get("state") == "run", "clear cycle %d replay starts" % cycle)
        _check(int(game.get("depth")) == 1 and int(game.get("wave")) == 1, "clear cycle %d replay resets progression" % cycle)
        game.call("_show_hub")
        await process_frame
        await process_frame

    if failures == 0:
        print("BLACKROOT RUN STATE STRESS PASSED — %d standard cycles + 10 clear/replay cycles" % CYCLES)
        quit(0)
    else:
        push_error("BLACKROOT RUN STATE STRESS FAILED: %d checks failed" % failures)
        quit(1)
