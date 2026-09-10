extends Node

const SAVE_PATH := "user://blackroot_save.json"
const SETTINGS_PATH := "user://blackroot_settings.json"

var save_data: Dictionary = {
    "version": 1,
    "root_amber": 0,
    "max_hp_bonus": 0,
    "damage_bonus": 0,
    "best_depth": 0,
    "wins": 0
}

var settings: Dictionary = {
    "master_volume": 0.8,
    "fullscreen": false,
    "screen_shake": true,
    "high_contrast": false
}

func _ready() -> void:
    load_all()

func load_all() -> void:
    save_data = _load_json(SAVE_PATH, save_data)
    settings = _load_json(SETTINGS_PATH, settings)
    apply_settings()

func save_progress() -> void:
    _write_json(SAVE_PATH, save_data)

func save_settings() -> void:
    _write_json(SETTINGS_PATH, settings)
    apply_settings()

func reset_progress() -> void:
    save_data = {
        "version": 1,
        "root_amber": 0,
        "max_hp_bonus": 0,
        "damage_bonus": 0,
        "best_depth": 0,
        "wins": 0
    }
    save_progress()

func apply_settings() -> void:
    var volume := clampf(float(settings.get("master_volume", 0.8)), 0.0, 1.0)
    var bus := AudioServer.get_bus_index("Master")
    if bus >= 0:
        AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.001)))
        AudioServer.set_bus_mute(bus, volume <= 0.001)
    var fullscreen := bool(settings.get("fullscreen", false))
    DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED)

func _load_json(path: String, fallback: Dictionary) -> Dictionary:
    if not FileAccess.file_exists(path):
        return fallback.duplicate(true)
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return fallback.duplicate(true)
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return fallback.duplicate(true)
    var merged := fallback.duplicate(true)
    for key in parsed:
        merged[key] = parsed[key]
    return merged

func _write_json(path: String, data: Dictionary) -> void:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file != null:
        file.store_string(JSON.stringify(data, "  "))
