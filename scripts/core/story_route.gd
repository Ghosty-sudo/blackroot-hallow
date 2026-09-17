class_name BlackrootStoryRoute
extends RefCounted

# Canonical implementation route. Narrative text lives in BlackrootStoryCatalog;
# this graph owns ordering, unlock requirements, scene intent, and art hooks.

const STAGES: Array[Dictionary] = [
    {"id":"wardens_rest_opening", "kind":"hub", "art":"wardens_rest", "requires":[], "sets":[]},
    {"id":"gloamgrove", "kind":"combat_depth", "art":"gloamgrove", "requires":[BlackrootStoryCatalog.FLAG_FIRST_DESCENT], "sets":[BlackrootStoryCatalog.FLAG_BRIAR_TRUTH]},
    {"id":"marrowroot", "kind":"combat_depth", "art":"marrowroot", "requires":[BlackrootStoryCatalog.FLAG_BRIAR_TRUTH], "sets":[BlackrootStoryCatalog.FLAG_MARROW_TRUTH]},
    {"id":"embermold", "kind":"combat_depth", "art":"embermold", "requires":[BlackrootStoryCatalog.FLAG_MARROW_TRUTH], "sets":[BlackrootStoryCatalog.FLAG_EMBER_TRUTH]},
    {"id":"third_seal", "kind":"transition", "art":"heartwood_threshold", "requires":[BlackrootStoryCatalog.FLAG_EMBER_TRUTH], "sets":[BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN]},
    {"id":"heartwood_entry", "kind":"story_sequence", "art":"heartwood_threshold", "requires":[BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN], "sets":[]},
    {"id":"heartwood_memories", "kind":"memory_sequence", "art":"heartwood_memory", "requires":[BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN], "sets":[]},
    {"id":"heartwood_sentinel", "kind":"boss", "art":"heartwood_chamber", "actor":"heartwood_sentinel", "requires":[BlackrootStoryCatalog.FLAG_HEARTWOOD_OPEN], "sets":[BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED]},
    {"id":"heartwood_confrontation", "kind":"story_sequence", "art":"heartwood_chamber", "requires":[BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED], "sets":[]},
    {"id":"measured_cut", "kind":"ending", "art":"measured_cut", "requires":[BlackrootStoryCatalog.FLAG_SENTINEL_DEFEATED], "sets":[BlackrootStoryCatalog.FLAG_MEASURED_CUT]},
    {"id":"covenant_patrol", "kind":"postgame", "art":"wardens_rest", "requires":[BlackrootStoryCatalog.FLAG_MEASURED_CUT], "sets":[]}
]

static func stages() -> Array[Dictionary]:
    return STAGES.duplicate(true)

static func stage(id: String) -> Dictionary:
    for item: Dictionary in STAGES:
        if String(item.get("id", "")) == id:
            return item.duplicate(true)
    return {}

static func index_of(id: String) -> int:
    for index: int in range(STAGES.size()):
        if String(STAGES[index].get("id", "")) == id:
            return index
    return -1

static func next_stage(id: String) -> Dictionary:
    var index := index_of(id)
    if index < 0 or index + 1 >= STAGES.size():
        return {}
    return STAGES[index + 1].duplicate(true)

static func requirements_met(id: String, flags: Dictionary) -> bool:
    var item := stage(id)
    if item.is_empty():
        return false
    for required: String in Array(item.get("requires", [])):
        if not bool(flags.get(required, false)):
            return false
    return true

static func next_unfinished(flags: Dictionary) -> Dictionary:
    for item: Dictionary in STAGES:
        var complete := true
        var sets: Array = item.get("sets", [])
        if sets.is_empty():
            continue
        for flag: String in sets:
            if not bool(flags.get(flag, false)):
                complete = false
                break
        if not complete and requirements_met(String(item.get("id", "")), flags):
            return item.duplicate(true)
    if bool(flags.get(BlackrootStoryCatalog.FLAG_MEASURED_CUT, false)):
        return stage("covenant_patrol")
    return {}

static func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    var ids: Dictionary = {}
    for item: Dictionary in STAGES:
        var id := String(item.get("id", ""))
        if id.is_empty():
            errors.append("story route stage missing id")
        elif ids.has(id):
            errors.append("duplicate story route stage: %s" % id)
        ids[id] = true
        var kind := String(item.get("kind", ""))
        if kind.is_empty():
            errors.append("story route stage %s missing kind" % id)
        var art := String(item.get("art", ""))
        if art.is_empty() or not BlackrootArtCatalog.has_profile("environment", art):
            errors.append("story route stage %s has invalid environment art id: %s" % [id, art])
        var actor := String(item.get("actor", ""))
        if not actor.is_empty() and not BlackrootArtCatalog.has_profile("actor", actor):
            errors.append("story route stage %s has invalid actor art id: %s" % [id, actor])
    for required: String in ["third_seal", "heartwood_entry", "heartwood_memories", "heartwood_sentinel", "heartwood_confrontation", "measured_cut", "covenant_patrol"]:
        if not ids.has(required):
            errors.append("launch route missing stage: %s" % required)
    if index_of("heartwood_memories") >= index_of("heartwood_sentinel"):
        errors.append("Heartwood memories must precede Sentinel")
    if index_of("heartwood_sentinel") >= index_of("measured_cut"):
        errors.append("Sentinel must precede Measured Cut")
    return errors
