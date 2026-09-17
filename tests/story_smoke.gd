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
    var errors := BlackrootStoryCatalog.validate()
    _check(errors.is_empty(), "story catalog validates: %s" % ", ".join(errors))

    var flags: Dictionary = {}
    var voice := BlackrootStoryCatalog.hub_voice(flags, 0)
    _check(String(voice.get("speaker", "")) == "MARA VENN", "new game begins with Mara")

    flags[BlackrootStoryCatalog.FLAG_FIRST_DESCENT] = true
    voice = BlackrootStoryCatalog.hub_voice(flags, 0)
    _check(String(voice.get("speaker", "")) == "MARA VENN", "first descent keeps Mara as anchor")

    var expected_flags := [
        BlackrootStoryCatalog.FLAG_BRIAR_TRUTH,
        BlackrootStoryCatalog.FLAG_MARROW_TRUTH,
        BlackrootStoryCatalog.FLAG_EMBER_TRUTH
    ]
    var expected_speakers := ["OLD FEN", "TALLOW", "OLD FEN"]
    for depth: int in range(1, 4):
        var reveal := BlackrootStoryCatalog.guardian_reveal(depth)
        var flag := String(reveal.get("flag", ""))
        _check(flag == expected_flags[depth - 1], "depth %d advances intended story flag" % depth)
        flags[flag] = true
        voice = BlackrootStoryCatalog.hub_voice(flags, 0)
        _check(String(voice.get("speaker", "")) == expected_speakers[depth - 1], "depth %d changes hub voice" % depth)

    _check(BlackrootStoryCatalog.guardian_reveal(99).is_empty(), "unknown depth cannot invent a reveal")
    for mark_name: String in ["Briar Oath", "Fleet Root", "Blood Sap"]:
        var lore := BlackrootStoryCatalog.rootmark_lore(mark_name)
        _check(not lore.is_empty() and lore != "Every gift from the Hollow has teeth.", "%s has specific narrative cost" % mark_name)

    if failures == 0:
        print("BLACKROOT STORY SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY SMOKE FAILED: %d checks failed" % failures)
        quit(1)
