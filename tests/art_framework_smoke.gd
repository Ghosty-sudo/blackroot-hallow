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
    var errors := BlackrootArtCatalog.validate()
    _check(errors.is_empty(), "art catalog validates: %s" % ", ".join(errors))
    for actor: String in ["warden", "warden_blade", "warden_pike", "warden_cleaver", "thornling", "brute", "stalker", "briar_warden", "marrow_bell", "ember_stag", "heartwood_sentinel"]:
        _check(BlackrootArtCatalog.has_profile("actor", actor), "actor has stable art id: " + actor)
    for environment: String in ["wardens_rest", "gloamgrove", "marrowroot", "embermold", "heartwood_threshold", "heartwood_memory", "heartwood_chamber", "measured_cut"]:
        _check(BlackrootArtCatalog.has_profile("environment", environment), "environment has stable art id: " + environment)

    var presenter := BlackrootArtPresenter.new()
    root.add_child(presenter)
    var loaded := presenter.configure("actor", "warden")
    _check(loaded == BlackrootArtCatalog.production_asset_available("actor", "warden"), "presenter and catalog agree on production availability")
    _check(not presenter.configure("actor", "does_not_exist"), "missing art id fails safely")
    _check(not presenter.production_active, "missing production art leaves fallback active")
    presenter.queue_free()

    var player := BlackrootPlayer.new()
    root.add_child(player)
    player.configure({}, {}, BlackrootContentCatalog.weapons()[0])
    _check(player.get("art_presenter") is BlackrootArtPresenter, "Warden owns replaceable art presenter")
    _check(bool(player.get("production_art_active")) == BlackrootArtCatalog.production_asset_available("actor", "warden_blade"), "Warden fallback tracks loadout art availability")

    var sentinel := BlackrootEnemy.new()
    root.add_child(sentinel)
    sentinel.configure("heartwood_sentinel", 4, player)
    _check(bool(sentinel.get("is_boss")), "Heartwood Sentinel combat shell is boss-class")
    _check(int(sentinel.get("max_hp")) > 62, "Sentinel durability exceeds prior guardians")
    _check(sentinel.get("art_presenter") is BlackrootArtPresenter, "Sentinel owns replaceable art presenter")
    _check(bool(sentinel.get("production_art_active")) == BlackrootArtCatalog.production_asset_available("actor", "heartwood_sentinel"), "Sentinel safely falls back until production art lands")

    sentinel.queue_free()
    player.queue_free()
    await process_frame
    await process_frame

    if failures == 0:
        print("BLACKROOT ART FRAMEWORK SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT ART FRAMEWORK SMOKE FAILED: %d checks failed" % failures)
        quit(1)
