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
    var original_save: Dictionary = SaveManager.save_data.duplicate(true)
    SaveManager.save_data["story_flags"] = {}
    SaveManager.save_data["wins"] = 0

    var scene := load("res://scenes/main.tscn")
    _check(scene != null, "story-aware main scene loads")
    if scene == null:
        SaveManager.save_data = original_save
        quit(1)
        return

    var game = scene.instantiate()
    root.add_child(game)
    await process_frame
    game.call("_show_hub")
    await process_frame
    var info: Label = game.get("info_label")
    _check(info != null and "MARA VENN:" in info.text, "new-game hub presents Mara")

    SaveManager.save_data["story_flags"] = {BlackrootStoryCatalog.FLAG_BRIAR_TRUTH: true}
    game.call("_show_hub")
    await process_frame
    _check("OLD FEN:" in info.text and "badge" in info.text.to_lower(), "Briar reveal changes hub conversation")

    game.call("_show_victory")
    await process_frame
    var title: Label = game.get("title_label")
    _check(title != null and title.text == "THE THIRD SEAL BREAKS", "three-guardian clear is no longer framed as final Heartwood ending")

    game.queue_free()
    await process_frame
    await process_frame
    SaveManager.save_data = original_save

    if failures == 0:
        print("BLACKROOT STORY RUNTIME SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY RUNTIME SMOKE FAILED: %d checks failed" % failures)
        quit(1)
