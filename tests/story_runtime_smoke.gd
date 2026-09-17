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
    var save_manager := root.get_node_or_null("SaveManager")
    _check(save_manager != null, "SaveManager autoload available")
    if save_manager == null:
        quit(1)
        return
    var original_save: Dictionary = Dictionary(save_manager.get("save_data")).duplicate(true)
    var test_save: Dictionary = original_save.duplicate(true)
    test_save["story_flags"] = {}
    test_save["wins"] = 0
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
    await process_frame
    var info = game.get("info_label")
    _check(info is Label and "MARA VENN:" in info.text, "new-game hub presents Mara")

    test_save = Dictionary(save_manager.get("save_data")).duplicate(true)
    test_save["story_flags"] = {BlackrootStoryCatalog.FLAG_BRIAR_TRUTH: true}
    save_manager.set("save_data", test_save)
    game.call("_show_hub")
    await process_frame
    _check(info is Label and "OLD FEN:" in info.text and "badge" in info.text.to_lower(), "Briar reveal changes hub conversation")

    game.call("_show_victory")
    await process_frame
    var title = game.get("title_label")
    _check(title is Label and title.text == "THE THIRD SEAL BREAKS", "three-guardian clear is no longer framed as final Heartwood ending")

    game.queue_free()
    await process_frame
    await process_frame
    save_manager.set("save_data", original_save)

    if failures == 0:
        print("BLACKROOT STORY RUNTIME SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY RUNTIME SMOKE FAILED: %d checks failed" % failures)
        quit(1)
