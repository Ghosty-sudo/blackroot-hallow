extends SceneTree

const STATE_HUB := 1
const STATE_RUN := 4
const STATE_VICTORY := 6
const STATE_RELICS := 8
const CYCLES := 50

var failures := 0
var game: Node
var save_manager: Node
var original_save: Dictionary = {}

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
    save_manager = root.get_node_or_null("SaveManager")
    _check(save_manager != null, "SaveManager autoload exists")
    if save_manager == null:
        _finish()
        return
    original_save = Dictionary(save_manager.get("save_data")).duplicate(true)
    var test_save: Dictionary = Dictionary(save_manager.get("save_data")).duplicate(true)
    test_save["tutorial_seen"] = true
    save_manager.set("save_data", test_save)

    var scene := load("res://scenes/main.tscn")
    _check(scene != null, "main scene loads")
    if scene == null:
        _finish()
        return
    game = scene.instantiate()
    root.add_child(game)
    await process_frame

    var weapons: Array = game.get("weapons")
    var marks: Array = game.get("marks")
    _check(not weapons.is_empty(), "weapons available for stress")
    _check(not marks.is_empty(), "rootmarks available for stress")
    if weapons.is_empty() or marks.is_empty():
        _finish()
        return

    for cycle: int in range(CYCLES):
        game.set("selected_weapon", weapons[cycle % weapons.size()].duplicate(true))
        game.call("_start_run", marks[cycle % marks.size()].duplicate(true))
        await process_frame
        _check(int(game.get("state")) == STATE_RUN, "cycle %d enters run" % cycle)
        _check(is_instance_valid(game.get("player")), "cycle %d owns live player" % cycle)
        _check(int(game.get("depth")) == 1 and int(game.get("wave")) == 1, "cycle %d starts clean depth/wave" % cycle)

        game.call("_toggle_pause")
        await process_frame
        _check(paused, "cycle %d pauses" % cycle)
        game.call("_resume_run")
        await process_frame
        _check(not paused and int(game.get("state")) == STATE_RUN, "cycle %d resumes" % cycle)

        game.set("depth", 1)
        game.set("wave", 4)
        game.set("run_amber", 5)
        game.call("_advance_encounter")
        await process_frame
        _check(int(game.get("depth")) == 2, "cycle %d advances depth" % cycle)
        _check(int(game.get("state")) == STATE_RELICS, "cycle %d reaches relic choice" % cycle)
        var options: Array = game.get("relic_options")
        _check(options.size() == 3, "cycle %d has three relic options" % cycle)
        if not options.is_empty():
            game.call("_choose_relic", options[0].duplicate(true))
            await process_frame
            _check(int(game.get("state")) == STATE_RUN, "cycle %d returns from relic choice" % cycle)
            _check(int(game.get("wave")) == 1, "cycle %d starts next depth at encounter one" % cycle)

        game.call("_show_hub")
        await process_frame
        await process_frame
        _check(int(game.get("state")) == STATE_HUB, "cycle %d returns to hub" % cycle)
        _check(game.get("player") == null, "cycle %d clears player" % cycle)
        var enemies: Array = game.get("enemies")
        _check(enemies.is_empty(), "cycle %d clears enemy registry" % cycle)
        _check(not paused, "cycle %d leaves tree unpaused" % cycle)

    var live_save: Dictionary = Dictionary(save_manager.get("save_data"))
    var wins_before := int(live_save.get("wins", 0))
    for cycle: int in range(15):
        game.set("selected_weapon", weapons[cycle % weapons.size()].duplicate(true))
        game.call("_start_run", marks[cycle % marks.size()].duplicate(true))
        await process_frame
        game.set("depth", 3)
        game.set("wave", 4)
        game.set("run_amber", 3)
        game.call("_advance_encounter")
        await process_frame
        _check(int(game.get("state")) == STATE_VICTORY, "clear cycle %d reaches victory" % cycle)
        live_save = Dictionary(save_manager.get("save_data"))
        _check(int(live_save.get("wins", 0)) == wins_before + cycle + 1, "clear cycle %d increments wins exactly once" % cycle)
        game.call("_retry_same_loadout")
        await process_frame
        _check(int(game.get("state")) == STATE_RUN, "clear cycle %d replay starts" % cycle)
        _check(int(game.get("depth")) == 1 and int(game.get("wave")) == 1, "clear cycle %d replay resets progression" % cycle)
        _check(int(game.get("run_amber")) == 0 and int(game.get("run_kills")) == 0, "clear cycle %d resets run counters" % cycle)
        game.call("_show_hub")
        await process_frame
        await process_frame

    _finish()

func _finish() -> void:
    paused = false
    if is_instance_valid(save_manager) and not original_save.is_empty():
        save_manager.set("save_data", original_save.duplicate(true))
    if is_instance_valid(game):
        game.queue_free()
        await process_frame
        await process_frame
    if failures == 0:
        print("BLACKROOT RUN STATE STRESS PASSED — %d standard cycles + 15 clear/replay cycles" % CYCLES)
        quit(0)
    else:
        push_error("BLACKROOT RUN STATE STRESS FAILED: %d checks failed" % failures)
        quit(1)
