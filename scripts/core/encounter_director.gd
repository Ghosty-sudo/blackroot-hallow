class_name BlackrootEncounterDirector
extends RefCounted

const ENCOUNTERS_PER_DEPTH := 4

var _rng := RandomNumberGenerator.new()

func seed_for_tests(value: int) -> void:
    _rng.seed = value

func randomize() -> void:
    _rng.randomize()

func build(depth: int, encounter: int, biomes: Array[Dictionary]) -> Dictionary:
    if biomes.is_empty():
        return {"guardian": false, "enemies": []}
    var biome_index := clampi(depth - 1, 0, biomes.size() - 1)
    var biome: Dictionary = biomes[biome_index]
    var guardian := encounter == ENCOUNTERS_PER_DEPTH
    if guardian:
        return {
            "guardian": true,
            "enemies": [{"kind": String(biome.get("guardian", "thornling")), "position": Vector2(160, 55)}]
        }
    var pool: Array = biome.get("regulars", [])
    if pool.is_empty():
        return {"guardian": false, "enemies": []}
    var count := mini(2 + depth + int(encounter / 2), 8)
    var enemies: Array[Dictionary] = []
    for i: int in range(count):
        var angle := TAU * float(i) / float(maxi(1, count))
        var spawn_pos := Vector2(160, 98) + Vector2(cos(angle), sin(angle)) * (55.0 + float((i * 13) % 25))
        enemies.append({"kind": String(pool[(i + encounter) % pool.size()]), "position": spawn_pos})
    return {"guardian": false, "enemies": enemies}

func relic_choices(pool: Array[Dictionary], owned_ids: Array[String], count: int = 3) -> Array[Dictionary]:
    var available: Array[Dictionary] = []
    for relic: Dictionary in pool:
        if not String(relic.get("id", "")) in owned_ids:
            available.append(relic.duplicate(true))
    var choices: Array[Dictionary] = []
    while choices.size() < mini(count, available.size()):
        var index := _rng.randi_range(0, available.size() - 1)
        choices.append(available[index])
        available.remove_at(index)
    return choices
