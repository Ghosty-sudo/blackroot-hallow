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

func _advance_story(game, count: int) -> void:
    for _i: int in range(count):
        game.call("_advance_story_step")

func _run() -> void:
    await process_frame
    var save_manager := root.get_node_or_null("SaveManager")
    _check(save_manager != null, "SaveManager autoload available")
    if save_manager == null:
        quit(1)
        return
    var original_save: Dictionary = Dictionary(save_manager.get("save_data")).duplicate(true)
    var test_save: Dictionary = original_save.duplicate(true)
    test_save["story_flags"] = {}
    test_save["wins"] = 0
    test_save["tutorial_seen"] = true
    save_manager.set("save_data", test_save)

    var scene := load("res://scenes/main.tscn")
    _check(scene != null, "story-aware main scene loads")
    if scene == null:
        save_manager.set("save_data", original_save)
        quit(1)
        return
    var game = scene.instantiate()
    root.add_child(game)
    await process_frame
    game.call("_show_hub")
    var info = game.get("info_label")
    _check(info is Label and "MARA VENN:" in info.text, "new-game hub presents Mara")

    game.set("selected_weapon", BlackrootContentCatalog.weapons()[0])
    game.call("_start_run", BlackrootContentCatalog.rootmarks()[0])
    for enemy in Array(game.get("enemies")).duplicate():
        if is_instance_valid(enemy):
            enemy.call("take_damage", 9999, Vector2.ZERO)
    game.set("run_amber", 0)
    game.set("run_kills", 0)
    game.set("depth", 3)
    game.set("wave", 4)
    game.set("run_amber", 12)
    game.call("_advance_encounter")
    _check(int(game.get("state")) == 9, "third guardian enters story state instead of ending run")
    _check(bool(save_manager.story_flags().get(BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN, false)), "third seal persists Heartwood-open flag")
    _check(String(game.get("title_label").text) == "THE THIRD SEAL BREAKS", "third seal gets explicit transition scene")

    _advance_story(game, 8)
    _check(int(game.get("state")) == 4, "Heartwood memories transition back into playable combat")
    _check(bool(game.get("sentinel_active")), "Heartwood Sentinel encounter becomes active")
    _check(int(game.get("depth")) == 4, "Heartwood uses explicit final-act depth")
    var enemies: Array = game.get("enemies")
    _check(enemies.size() == 1 and String(enemies[0].get("archetype")) == "heartwood_sentinel", "final-act combat spawns Heartwood Sentinel")

    game.queue_free()
    await process_frame
    await process_frame
    save_manager.set("save_data", original_save)
    paused = false

    if failures == 0:
        print("BLACKROOT STORY RUNTIME SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY RUNTIME SMOKE FAILED: %d checks failed" % failures)
        quit(1)