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
    for portrait: String in ["mara_venn", "old_fen", "tallow", "rootvoice"]:
        _check(BlackrootArtCatalog.has_profile("portrait", portrait), "portrait has stable art id: " + portrait)

    var presenter := BlackrootArtPresenter.new()
    root.add_child(presenter)
    var loaded := presenter.configure("actor", "warden")
    _check(loaded == BlackrootArtCatalog.production_asset_available("actor", "warden"), "presenter and catalog agree on production availability")
    _check(not presenter.configure("actor", "does_not_exist"), "missing art id fails safely")
    _check(not presenter.production_active, "missing production art leaves prototype fallback active")
    presenter.free()

    var sentinel_profile := BlackrootArtCatalog.profile("actor", "heartwood_sentinel")
    _check(String(sentinel_profile.get("frames", "")).contains("heartwood_sentinel"), "Sentinel has animation-ready production slot")
    _check(String(BlackrootArtCatalog.profile("actor", "warden_blade").get("frames", "")).contains("blade_frames"), "Warden weapon loadouts have independent animation slots")

    if failures == 0:
        print("BLACKROOT ART FRAMEWORK SMOKE PASSED")
        quit(0)
    else:
        push_error("BLACKROOT ART FRAMEWORK SMOKE FAILED: %d checks failed" % failures)
        quit(1)
