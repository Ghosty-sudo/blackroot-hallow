class_name BlackrootContentCatalog
extends RefCounted

# Single source of truth for expandable gameplay content. Callers receive deep
# copies so runtime mutation can never corrupt the catalog.

const WEAPONS: Array[Dictionary] = [
    {"id":"blade","name":"Warden Blade","desc":"Balanced reach, speed, and control.","damage_mult":1.0,"cooldown":0.30,"reach":13.0,"radius":15.0,"knockback":95.0},
    {"id":"pike","name":"Root Pike","desc":"Long reach and control, but lighter hits.","damage_mult":0.82,"cooldown":0.34,"reach":21.0,"radius":13.0,"knockback":125.0},
    {"id":"cleaver","name":"Grave Cleaver","desc":"Heavy damage and knockback, but slow recovery.","damage_mult":1.42,"cooldown":0.52,"reach":12.0,"radius":17.0,"knockback":165.0}
]

const ROOTMARKS: Array[Dictionary] = [
    {"id":"briar_oath","name":"Briar Oath","desc":"+50% damage, but enemies hurt 50% more.","damage_mult":1.5,"incoming_mult":1.5},
    {"id":"fleet_root","name":"Fleet Root","desc":"+30% move speed, but -2 maximum HP.","speed_mult":1.3,"hp_bonus":-2},
    {"id":"blood_sap","name":"Blood Sap","desc":"+2 base damage and 25% lifesteal, but -1 maximum HP.","damage_bonus":2,"lifesteal":0.25,"hp_bonus":-1}
]

const RELICS: Array[Dictionary] = [
    {"id":"thorn_heart","name":"Thorn Heart","desc":"+2 maximum HP and heal 2."},
    {"id":"keen_resin","name":"Keen Resin","desc":"+20% damage."},
    {"id":"hollow_step","name":"Hollow Step","desc":"+12% move speed and 20% faster dodge recovery."},
    {"id":"sapglass_fang","name":"Sapglass Fang","desc":"+12% lifesteal."},
    {"id":"warden_knot","name":"Warden Knot","desc":"Take 15% less damage."},
    {"id":"longroot_grip","name":"Longroot Grip","desc":"+18% attack reach and a wider strike."}
]

const BIOMES: Array[Dictionary] = [
    {"id":"gloamgrove","name":"GLOAMGROVE","floor":"223425","accent":"405b31","guardian":"briar_warden","regulars":["thornling","thornling","thornling","brute"]},
    {"id":"marrowroot","name":"MARROWROOT","floor":"352d2a","accent":"65584d","guardian":"marrow_bell","regulars":["thornling","brute","brute","stalker"]},
    {"id":"embermold","name":"EMBERMOLD","floor":"3a2a24","accent":"794737","guardian":"ember_stag","regulars":["stalker","stalker","brute","thornling"]}
]

static func weapons() -> Array[Dictionary]:
    return WEAPONS.duplicate(true)

static func rootmarks() -> Array[Dictionary]:
    return ROOTMARKS.duplicate(true)

static func relics() -> Array[Dictionary]:
    return RELICS.duplicate(true)

static func biomes() -> Array[Dictionary]:
    return BIOMES.duplicate(true)

static func validate() -> PackedStringArray:
    var errors := PackedStringArray()
    _validate_unique_ids("weapon", WEAPONS, errors)
    _validate_unique_ids("rootmark", ROOTMARKS, errors)
    _validate_unique_ids("relic", RELICS, errors)
    _validate_unique_ids("biome", BIOMES, errors)
    for biome: Dictionary in BIOMES:
        if String(biome.get("guardian", "")).is_empty():
            errors.append("biome %s has no guardian" % String(biome.get("id", "?")))
        if Array(biome.get("regulars", [])).is_empty():
            errors.append("biome %s has no regular enemy pool" % String(biome.get("id", "?")))
    return errors

static func _validate_unique_ids(kind: String, entries: Array[Dictionary], errors: PackedStringArray) -> void:
    var seen: Dictionary = {}
    for entry: Dictionary in entries:
        var id := String(entry.get("id", ""))
        if id.is_empty():
            errors.append("%s entry missing id" % kind)
        elif seen.has(id):
            errors.append("duplicate %s id: %s" % [kind, id])
        else:
            seen[id] = true
