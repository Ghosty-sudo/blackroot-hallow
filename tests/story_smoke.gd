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
    _check(BlackrootStoryCatalog.next_required_flag(flags) == BlackrootStoryCatalog.FLAG_FIRST_DESCENT, "story begins at first descent")

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
        _check(not String(reveal.get("discovery", "")).is_empty(), "depth %d has concrete discovery" % depth)
        flags[flag] = true
        voice = BlackrootStoryCatalog.hub_voice(flags, 0)
        _check(String(voice.get("speaker", "")) == expected_speakers[depth - 1], "depth %d changes hub voice" % depth)

    _check(BlackrootStoryCatalog.guardian_reveal(99).is_empty(), "unknown depth cannot invent a reveal")
    for mark_name: String in ["Briar Oath", "Fleet Root", "Blood Sap"]:
        var lore := BlackrootStoryCatalog.rootmark_lore(mark_name)
        _check(not lore.is_empty() and lore != "Every gift from the Hollow has teeth.", "%s has specific narrative cost" % mark_name)

    _check(BlackrootStoryCatalog.heartwood_entry().size() == 3, "Heartwood entry explains compatibility without prophecy")
    _check(BlackrootStoryCatalog.heartwood_memories().size() == 3, "Heartwood contains gift, measure, and extraction memories")
    var sentinel := BlackrootStoryCatalog.sentinel_lines()
    _check(String(sentinel.get("intro", "")).contains("UNARMED"), "Sentinel establishes covenant-door conflict")
    _check(String(sentinel.get("defeat", "")).contains("CHOICE"), "Sentinel defeat hands story to player choice")
    _check(BlackrootStoryCatalog.heartwood_confrontation().size() >= 5, "final confrontation gives both sides an armed extreme")
    _check(BlackrootStoryCatalog.measured_cut_lines().back().get("text", "") == "MEASURED.", "canonical ending resolves on measure")
    _check(BlackrootStoryCatalog.ending_epilogue().back().get("speaker", "") == "ROOTVOICE", "Rootvoice closes the launch story")

    flags[BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN] = true
    voice = BlackrootStoryCatalog.hub_voice(flags, 0)
    _check(String(voice.get("speaker", "")) == "MARA VENN", "Heartwood opening returns agency to the Warden")
    _check(not BlackrootStoryCatalog.story_complete(flags), "Heartwood opening is not story completion")

    flags[BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED] = true
    _check(not BlackrootStoryCatalog.story_complete(flags), "Sentinel defeat is not the ending by itself")

    flags[BlackrootStoryCatalog.FLAG_MEASURED_CUT] = true
    _check(BlackrootStoryCatalog.story_complete(flags), "Measured Cut completes every required launch beat")
    voice = BlackrootStoryCatalog.hub_voice(flags, 0)
    _check(String(voice.get("text", "")).contains("ration"), "post-ending hub acknowledges material consequences")
    _check(BlackrootStoryCatalog.postgame_voice_pool().size() >= 4, "postgame has covenant-patrol continuity")

    if failures == 0:
        print("BLACKROOT STORY SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY SMOKE FAILED: %d checks failed" % failures)
        quit(1)
