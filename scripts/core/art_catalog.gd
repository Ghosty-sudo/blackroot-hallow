class_name BlackrootArtCatalog
extends RefCounted

# Gameplay code asks for semantic art IDs, never filenames. Production art can
# therefore replace prototype drawing without touching combat or story logic.
# Missing assets are intentional: BlackrootArtPresenter falls back safely.

const ACTORS: Dictionary = {
    "warden": {"frames":"res://art/actors/warden/warden_frames.tres", "texture":"res://art/actors/warden/warden.png", "scale":1.0},
    "warden_blade": {"frames":"res://art/actors/warden/blade_frames.tres", "texture":"res://art/actors/warden/blade.png", "scale":1.0},
    "warden_pike": {"frames":"res://art/actors/warden/pike_frames.tres", "texture":"res://art/actors/warden/pike.png", "scale":1.0},
    "warden_cleaver": {"frames":"res://art/actors/warden/cleaver_frames.tres", "texture":"res://art/actors/warden/cleaver.png", "scale":1.0},
    "thornling": {"frames":"res://art/actors/enemies/thornling_frames.tres", "texture":"res://art/actors/enemies/thornling.png", "scale":1.0},
    "brute": {"frames":"res://art/actors/enemies/brute_frames.tres", "texture":"res://art/actors/enemies/brute.png", "scale":1.0},
    "stalker": {"frames":"res://art/actors/enemies/stalker_frames.tres", "texture":"res://art/actors/enemies/stalker.png", "scale":1.0},
    "briar_warden": {"frames":"res://art/actors/guardians/briar_warden_frames.tres", "texture":"res://art/actors/guardians/briar_warden.png", "scale":1.0},
    "marrow_bell": {"frames":"res://art/actors/guardians/marrow_bell_frames.tres", "texture":"res://art/actors/guardians/marrow_bell.png", "scale":1.0},
    "ember_stag": {"frames":"res://art/actors/guardians/ember_stag_frames.tres", "texture":"res://art/actors/guardians/ember_stag.png", "scale":1.0},
    "heartwood_sentinel": {"frames":"res://art/actors/guardians/heartwood_sentinel_frames.tres", "texture":"res://art/actors/guardians/heartwood_sentinel.png", "scale":1.0}
}

const ENVIRONMENTS: Dictionary = {
    "wardens_rest": {"texture":"res://art/environments/wardens_rest.png"},
    "gloamgrove": {"texture":"res://art/environments/gloamgrove.png"},
    "marrowroot": {"texture":"res://art/environments/marrowroot.png"},
    "embermold": {"texture":"res://art/environments/embermold.png"},
    "heartwood_threshold": {"texture":"res://art/environments/heartwood_threshold.png"},
    "heartwood_memory": {"texture":"res://art/environments/heartwood_memory.png"},
    "heartwood_chamber": {"texture":"res://art/environments/heartwood_chamber.png"},
    "measured_cut": {"texture":"res://art/environments/measured_cut.png"}
}

const PORTRAITS: Dictionary = {
    "mara_venn": {"texture":"res://art/portraits/mara_venn.png"},
    "old_fen": {"texture":"res://art/portraits/old_fen.png"},
    "tallow": {"texture":"res://art/portraits/tallow.png"},
    "rootvoice": {"texture":"res://art/portraits/rootvoice.png"}
}

const UI: Dictionary = {
    "root_amber": {"texture":"res://art/ui/root_amber.png"},
    "rootmark": {"texture":"res://art/ui/rootmark.png"},
    "relic": {"texture":"res://art/ui/relic.png"},
    "heartwood_seal": {"texture":"res://art/ui/heartwood_seal.png"}
}

static func profile(category: String, id: String) -> Dictionary:
    var table := _table(category)
    if not table.has(id):
        return {}
    return Dictionary(table[id]).duplicate(true)

static func has_profile(category: String, id: String) -> bool:
    return _table(category).has(id)

static func production_asset_available(category: String, id: String) -> bool:
    var data := profile(category, id)
    if data.is_empty():
        return false
    for key: String in ["frames", "texture"]:
        var path := String(data.get(key, ""))
        if not path.is_empty() and ResourceLoader.exists(path):
            return true
    return false

static func _table(category: String) -> Dictionary:
    match category:
        "actor": return ACTORS
        "environment": return ENVIRONMENTS
        "portrait": return PORTRAITS
        "ui": return UI
        _: return {}

static func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    for category: String in ["actor", "environment", "portrait", "ui"]:
        var table := _table(category)
        for id: String in table.keys():
            if id.strip_edges().is_empty():
                errors.append("%s art entry has empty id" % category)
                continue
            var data: Dictionary = table[id]
            var frames := String(data.get("frames", ""))
            var texture := String(data.get("texture", ""))
            if frames.is_empty() and texture.is_empty():
                errors.append("%s/%s has no asset path" % [category, id])
            for path: String in [frames, texture]:
                if not path.is_empty() and not path.begins_with("res://art/"):
                    errors.append("%s/%s escapes art root: %s" % [category, id, path])
    for required: String in ["warden", "warden_blade", "warden_pike", "warden_cleaver", "briar_warden", "marrow_bell", "ember_stag", "heartwood_sentinel"]:
        if not ACTORS.has(required):
            errors.append("missing required actor art id: %s" % required)
    for required: String in ["wardens_rest", "gloamgrove", "marrowroot", "embermold", "heartwood_chamber"]:
        if not ENVIRONMENTS.has(required):
            errors.append("missing required environment art id: %s" % required)
    return errors
