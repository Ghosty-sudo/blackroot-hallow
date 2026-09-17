class_name BlackrootRunSession
extends RefCounted

const FIRST_DEPTH := 1
const FINAL_DEPTH := 3
const ENCOUNTERS_PER_DEPTH := 4

var depth: int = FIRST_DEPTH
var encounter: int = 0
var unbanked_amber: int = 0
var banked_amber: int = 0
var kills: int = 0
var relic_ids: Array[String] = []
var weapon: Dictionary = {}
var rootmark: Dictionary = {}
var finished: bool = false

func begin(chosen_weapon: Dictionary, chosen_rootmark: Dictionary) -> void:
    depth = FIRST_DEPTH
    encounter = 0
    unbanked_amber = 0
    banked_amber = 0
    kills = 0
    relic_ids.clear()
    weapon = chosen_weapon.duplicate(true)
    rootmark = chosen_rootmark.duplicate(true)
    finished = false

func begin_encounter() -> int:
    if finished:
        return encounter
    encounter = mini(encounter + 1, ENCOUNTERS_PER_DEPTH)
    return encounter

func record_kill(reward: int) -> void:
    if finished:
        return
    kills += 1
    unbanked_amber += maxi(0, reward)

func bank_depth() -> int:
    var amount := unbanked_amber
    banked_amber += amount
    unbanked_amber = 0
    return amount

func advance_depth() -> bool:
    if depth >= FINAL_DEPTH:
        finished = true
        return false
    depth += 1
    encounter = 0
    return true

func bind_relic(id: String) -> bool:
    if id.is_empty() or id in relic_ids:
        return false
    relic_ids.append(id)
    return true

func death_recovery() -> int:
    var recovered := int(unbanked_amber / 2)
    banked_amber += recovered
    unbanked_amber = 0
    finished = true
    return recovered

func is_guardian_encounter() -> bool:
    return encounter == ENCOUNTERS_PER_DEPTH

func snapshot() -> Dictionary:
    return {
        "depth": depth,
        "encounter": encounter,
        "unbanked_amber": unbanked_amber,
        "banked_amber": banked_amber,
        "kills": kills,
        "relic_ids": relic_ids.duplicate(),
        "weapon_id": String(weapon.get("id", "")),
        "rootmark_id": String(rootmark.get("id", "")),
        "finished": finished
    }

func invariant_errors() -> PackedStringArray:
    var errors := PackedStringArray()
    if depth < FIRST_DEPTH or depth > FINAL_DEPTH:
        errors.append("depth outside supported range")
    if encounter < 0 or encounter > ENCOUNTERS_PER_DEPTH:
        errors.append("encounter outside supported range")
    if unbanked_amber < 0 or banked_amber < 0 or kills < 0:
        errors.append("run counters cannot be negative")
    var unique: Dictionary = {}
    for id: String in relic_ids:
        if unique.has(id):
            errors.append("duplicate relic in run: %s" % id)
        unique[id] = true
    return errors
