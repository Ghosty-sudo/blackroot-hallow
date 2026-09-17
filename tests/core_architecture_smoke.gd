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
    var catalog_errors := BlackrootContentCatalog.validate()
    _check(catalog_errors.is_empty(), "content catalog validates: %s" % ", ".join(catalog_errors))
    var weapons := BlackrootContentCatalog.weapons()
    var marks := BlackrootContentCatalog.rootmarks()
    var relics := BlackrootContentCatalog.relics()
    var biomes := BlackrootContentCatalog.biomes()
    _check(weapons.size() >= 3 and marks.size() >= 3 and relics.size() >= 6 and biomes.size() == 3, "catalog exposes release content")

    var session := BlackrootRunSession.new()
    session.begin(weapons[0], marks[0])
    _check(session.invariant_errors().is_empty(), "new run invariants hold")
    _check(session.begin_encounter() == 1, "run begins first encounter")
    session.record_kill(3)
    session.record_kill(2)
    session.record_kill(-50)
    _check(session.kills == 3 and session.unbanked_amber == 5, "kill rewards clamp negative amber")
    session.encounter = BlackrootRunSession.ENCOUNTERS_PER_DEPTH
    _check(session.is_guardian_encounter(), "guardian boundary is explicit")
    _check(session.bank_depth() == 5 and session.banked_amber == 5 and session.unbanked_amber == 0, "banking transfers amber once")
    _check(session.bank_depth() == 0 and session.banked_amber == 5, "repeated bank cannot duplicate amber")
    _check(session.advance_depth() and session.depth == 2 and session.encounter == 0, "depth transition resets encounter")
    _check(session.bind_relic("thorn_heart"), "first relic bind succeeds")
    _check(not session.bind_relic("thorn_heart"), "duplicate relic bind rejected")
    _check(session.invariant_errors().is_empty(), "mutated run invariants hold")

    var death_session := BlackrootRunSession.new()
    death_session.begin(weapons[1], marks[1])
    death_session.unbanked_amber = 9
    _check(death_session.death_recovery() == 4, "death recovery floors half amber")
    _check(death_session.unbanked_amber == 0 and death_session.banked_amber == 4 and death_session.finished, "death closes run cleanly")
    _check(death_session.death_recovery() == 0 and death_session.banked_amber == 4, "repeated death recovery cannot duplicate amber")

    var director := BlackrootEncounterDirector.new()
    director.seed_for_tests(1337)
    var empty_plan := director.build(1, 1, [])
    _check(Array(empty_plan.get("enemies", [])).is_empty() and not bool(empty_plan.get("guardian", false)), "empty content produces safe empty encounter")
    for depth: int in range(1, 4):
        for encounter: int in range(1, 5):
            var plan := director.build(depth, encounter, biomes)
            var enemies: Array = plan.get("enemies", [])
            _check(not enemies.is_empty(), "encounter plan %d/%d has enemies" % [depth, encounter])
            _check(bool(plan.get("guardian", false)) == (encounter == 4), "encounter plan %d/%d guardian flag correct" % [depth, encounter])
    var choices := director.relic_choices(relics, ["thorn_heart"], 3)
    var choice_ids: Dictionary = {}
    for choice: Dictionary in choices:
        choice_ids[String(choice.get("id", ""))] = true
    _check(choices.size() == 3 and choice_ids.size() == 3 and not choice_ids.has("thorn_heart"), "relic director returns unique unowned choices")

    if failures == 0:
        print("BLACKROOT CORE ARCHITECTURE SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT CORE ARCHITECTURE SMOKE FAILED: %d checks failed" % failures)
        quit(1)
