extends Node

const SAVE_PATH := "user://blackroot_save.json"
const SAVE_BACKUP_PATH := "user://blackroot_save.backup.json"
const SETTINGS_PATH := "user://blackroot_settings.json"
const CURRENT_SAVE_VERSION := 2

var save_data: Dictionary = _default_save()
var settings: Dictionary = _default_settings()
var last_load_notice: String = ""
var last_save_error: String = ""

func _ready() -> void:
    load_all()

func _default_save() -> Dictionary:
    return {
        "version": CURRENT_SAVE_VERSION,
        "root_amber": 0,
        "max_hp_bonus": 0,
        "damage_bonus": 0,
        "best_depth": 0,
        "wins": 0,
        "tutorial_seen": false
    }

func _default_settings() -> Dictionary:
    return {
        "master_volume": 0.8,
        "sfx_volume": 0.8,
        "fullscreen": false,
        "screen_shake": true,
        "high_contrast": false,
        "reduce_flashes": false
    }

func load_all() -> void:
    last_load_notice = ""
    last_save_error = ""
    save_data = _load_save_with_recovery()
    settings = _load_json(SETTINGS_PATH, _default_settings())
    apply_settings()

func save_progress() -> bool:
    last_save_error = ""
    if FileAccess.file_exists(SAVE_PATH):
        var old := FileAccess.open(SAVE_PATH, FileAccess.READ)
        if old != null:
            var backup := FileAccess.open(SAVE_BACKUP_PATH, FileAccess.WRITE)
            if backup != null:
                backup.store_string(old.get_as_text())
    save_data["version"] = CURRENT_SAVE_VERSION
    if not _write_json(SAVE_PATH, save_data):
        last_save_error = "Progress could not be saved."
        return false
    return true

func save_settings() -> bool:
    last_save_error = ""
    if not _write_json(SETTINGS_PATH, settings):
        last_save_error = "Settings could not be saved."
        return false
    apply_settings()
    return true

func reset_progress() -> void:
    save_data = _default_save()
    save_progress()

func apply_settings() -> void:
    _apply_bus_volume("Master", float(settings.get("master_volume", 0.8)))
    _apply_bus_volume("SFX", float(settings.get("sfx_volume", 0.8)))
    if not OS.has_feature("web"):
        var fullscreen := bool(settings.get("fullscreen", false))
        DisplayServer.window_set_mode(
            DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
            else DisplayServer.WINDOW_MODE_WINDOWED
        )

func _apply_bus_volume(bus_name: String, value: float) -> void:
    var volume := clampf(value, 0.0, 1.0)
    var bus := AudioServer.get_bus_index(bus_name)
    if bus >= 0:
        AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(volume, 0.001)))
        AudioServer.set_bus_mute(bus, volume <= 0.001)

func _load_save_with_recovery() -> Dictionary:
    var primary_exists := FileAccess.file_exists(SAVE_PATH)
    var backup_exists := FileAccess.file_exists(SAVE_BACKUP_PATH)
    var primary := _read_dictionary(SAVE_PATH)
    if not primary.is_empty():
        return _migrate_save(primary)
    var backup := _read_dictionary(SAVE_BACKUP_PATH)
    if not backup.is_empty():
        var recovered := _migrate_save(backup)
        if _write_json(SAVE_PATH, recovered):
            last_load_notice = "Recovered progress from the backup save."
        else:
            last_load_notice = "Loaded backup progress, but the recovered save could not be rewritten."
        return recovered
    if primary_exists or backup_exists:
        last_load_notice = "Save data could not be read. A fresh save was started."
    return _default_save()

func _migrate_save(source: Dictionary) -> Dictionary:
    var merged := _default_save()
    for key in source:
        if merged.has(key):
            merged[key] = source[key]
    var version := int(source.get("version", 1))
    if version < 2:
        merged["tutorial_seen"] = bool(source.get("tutorial_seen", false))
    merged["version"] = CURRENT_SAVE_VERSION
    return merged

func _read_dictionary(path: String) -> Dictionary:
    if not FileAccess.file_exists(path):
        return {}
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY:
        return {}
    return parsed

func _load_json(path: String, fallback: Dictionary) -> Dictionary:
    var parsed := _read_dictionary(path)
    if parsed.is_empty():
        return fallback.duplicate(true)
    var merged := fallback.duplicate(true)
    for key in parsed:
        if merged.has(key):
            merged[key] = parsed[key]
    return merged

func _write_json(path: String, data: Dictionary) -> bool:
    var file := FileAccess.open(path, FileAccess.WRITE)
    if file == null:
        return false
    file.store_string(JSON.stringify(data, "  "))
    return true
