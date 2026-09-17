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
    var errors := BlackrootStoryRoute.validate()
    _check(errors.is_empty(), "story route validates: %s" % ", ".join(errors))
    var stages := BlackrootStoryRoute.stages()
    _check(stages.size() >= 11, "launch route contains complete critical path")
    _check(BlackrootStoryRoute.index_of("third_seal") < BlackrootStoryRoute.index_of("heartwood_entry"), "third seal opens before Heartwood entry")
    _check(BlackrootStoryRoute.index_of("heartwood_memories") < BlackrootStoryRoute.index_of("heartwood_sentinel"), "memories precede Sentinel")
    _check(BlackrootStoryRoute.index_of("heartwood_sentinel") < BlackrootStoryRoute.index_of("measured_cut"), "Sentinel precedes ending")
    _check(String(BlackrootStoryRoute.stage("heartwood_sentinel").get("actor", "")) == "heartwood_sentinel", "Sentinel stage owns stable art actor id")

    var flags := {
        BlackrootStoryCatalog.FLAG_FIRST_DESCENT: true,
        BlackrootStoryCatalog.FLAG_BRIAR_TRUTH: true,
        BlackrootStoryCatalog.FLAG_MARROW_TRUTH: true,
        BlackrootStoryCatalog.FLAG_EMBER_TRUTH: true,
        BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN: true
    }
    _check(BlackrootStoryRoute.requirements_met("heartwood_sentinel", flags), "Heartwood-open save can reach Sentinel")
    _check(not BlackrootStoryRoute.requirements_met("measured_cut", flags), "ending cannot unlock before Sentinel defeat")
    flags[BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED] = true
    _check(BlackrootStoryRoute.requirements_met("measured_cut", flags), "Sentinel defeat unlocks Measured Cut")
    flags[BlackrootStoryCatalog.FLAG_MEASURED_CUT] = true
    _check(String(BlackrootStoryRoute.next_unfinished(flags).get("id", "")) == "covenant_patrol", "completed story resolves to postgame patrol")

    if failures == 0:
        print("BLACKROOT STORY ROUTE SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT STORY ROUTE SMOKE FAILED: %d checks failed" % failures)
        quit(1)
