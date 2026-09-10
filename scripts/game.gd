extends Node2D

const STATE_TITLE := 0
const STATE_HUB := 1
const STATE_WEAPONS := 2
const STATE_MARKS := 3
const STATE_RUN := 4
const STATE_GAMEOVER := 5
const STATE_VICTORY := 6
const STATE_SETTINGS := 7

var state: int = STATE_TITLE
var player: BlackrootPlayer
var enemies: Array[BlackrootEnemy] = []
var depth: int = 1
var wave: int = 0
var run_amber: int = 0
var selected_mark: Dictionary = {}
var selected_weapon: Dictionary = {}
var attack_flash: float = 0.0
var banner_timer: float = 0.0
var message: String = ""
var high_contrast: bool = false
var settings_return_state: int = STATE_TITLE
var shake_time: float = 0.0
var shake_strength: float = 0.0
var rng: RandomNumberGenerator = RandomNumberGenerator.new()

var root_ui: CanvasLayer
var title_label: Label
var subtitle_label: Label
var info_label: Label
var menu_box: VBoxContainer
var footer_label: Label

var marks: Array[Dictionary] = [
    {"name": "Briar Oath", "desc": "+50% damage, but enemies hurt 50% more.", "damage_mult": 1.5, "incoming_mult": 1.5},
    {"name": "Fleet Root", "desc": "+30% move speed, but -2 maximum HP.", "speed_mult": 1.3, "hp_bonus": -2},
    {"name": "Blood Sap", "desc": "+2 base damage and 25% lifesteal, but -1 maximum HP.", "damage_bonus": 2, "lifesteal": 0.25, "hp_bonus": -1}
]

var weapons: Array[Dictionary] = [
    {"id": "blade", "name": "Warden Blade", "desc": "Balanced reach, speed, and control.", "damage_mult": 1.0, "cooldown": 0.30, "reach": 13.0, "radius": 15.0, "knockback": 95.0},
    {"id": "pike", "name": "Root Pike", "desc": "Long reach and control, but lighter hits.", "damage_mult": 0.82, "cooldown": 0.34, "reach": 21.0, "radius": 13.0, "knockback": 125.0},
    {"id": "cleaver", "name": "Grave Cleaver", "desc": "Heavy damage and knockback, but slow recovery.", "damage_mult": 1.42, "cooldown": 0.52, "reach": 12.0, "radius": 17.0, "knockback": 165.0}
]

var biome_data: Array[Dictionary] = [
    {"name": "GLOAMGROVE", "floor": Color("223425"), "accent": Color("405b31")},
    {"name": "MARROWROOT", "floor": Color("352d2a"), "accent": Color("65584d")},
    {"name": "EMBERMOLD", "floor": Color("3a2a24"), "accent": Color("794737")}
]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    rng.randomize()
    _build_ui()
    high_contrast = bool(SaveManager.settings.get("high_contrast", false))
    _show_title()
    queue_redraw()

func _process(delta: float) -> void:
    if get_tree().paused:
        queue_redraw()
        return
    attack_flash = maxf(0.0, attack_flash - delta)
    banner_timer = maxf(0.0, banner_timer - delta)
    shake_time = maxf(0.0, shake_time - delta)
    if shake_time > 0.0 and bool(SaveManager.settings.get("screen_shake", true)):
        position = Vector2(rng.randf_range(-shake_strength, shake_strength), rng.randf_range(-shake_strength, shake_strength))
    else:
        position = Vector2.ZERO
    if state == STATE_RUN:
        if _attack_pressed() and is_instance_valid(player) and player.can_attack():
            _do_attack()
        if _dodge_pressed() and is_instance_valid(player):
            player.try_dodge()
        if enemies.is_empty() and is_instance_valid(player):
            _advance_encounter()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if state == STATE_RUN:
                _toggle_pause()
            elif state == STATE_SETTINGS:
                _leave_settings()
        elif event.keycode == KEY_ENTER and state == STATE_TITLE:
            _show_hub()
    if event is InputEventJoypadButton and event.pressed and event.button_index == JOY_BUTTON_START and state == STATE_RUN:
        _toggle_pause()

func _attack_pressed() -> bool:
    return Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)

func _dodge_pressed() -> bool:
    return Input.is_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_B)

func _toggle_pause() -> void:
    get_tree().paused = not get_tree().paused
    message = "PAUSED — Esc/Start to resume" if get_tree().paused else ""
    _refresh_info()

func _build_ui() -> void:
    root_ui = CanvasLayer.new()
    root_ui.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(root_ui)
    var panel: PanelContainer = PanelContainer.new()
    panel.position = Vector2(8, 7)
    panel.size = Vector2(304, 166)
    root_ui.add_child(panel)
    var margin: MarginContainer = MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 9)
    margin.add_theme_constant_override("margin_right", 9)
    margin.add_theme_constant_override("margin_top", 7)
    margin.add_theme_constant_override("margin_bottom", 7)
    panel.add_child(margin)
    var v: VBoxContainer = VBoxContainer.new()
    margin.add_child(v)
    title_label = Label.new()
    title_label.add_theme_font_size_override("font_size", 15)
    v.add_child(title_label)
    subtitle_label = Label.new()
    subtitle_label.add_theme_font_size_override("font_size", 8)
    v.add_child(subtitle_label)
    info_label = Label.new()
    info_label.add_theme_font_size_override("font_size", 8)
    info_label.custom_minimum_size = Vector2(0, 32)
    info_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    v.add_child(info_label)
    menu_box = VBoxContainer.new()
    menu_box.add_theme_constant_override("separation", 3)
    v.add_child(menu_box)
    footer_label = Label.new()
    footer_label.add_theme_font_size_override("font_size", 7)
    footer_label.text = "WASD/Arrows move • Space/LMB/A attack • Shift/B dodge • Esc/Start pause"
    v.add_child(footer_label)

func _clear_menu() -> void:
    for child: Node in menu_box.get_children():
        child.queue_free()

func _button(text: String, callback: Callable) -> void:
    var button: Button = Button.new()
    button.text = text
    button.add_theme_font_size_override("font_size", 8)
    button.custom_minimum_size = Vector2(0, 18)
    button.pressed.connect(func() -> void:
        AudioManager.play_sfx("ui")
        callback.call()
    )
    menu_box.add_child(button)

func _show_title() -> void:
    state = STATE_TITLE
    get_tree().paused = false
    _clear_world()
    _clear_menu()
    title_label.text = "BLACKROOT HOLLOW"
    subtitle_label.text = "Power always takes something back."
    info_label.text = "Descend beneath Warden's Rest. Bind cursed Rootmarks, carve through the living root network, and return stronger."
    _button("BEGIN", _show_hub)
    _button("SETTINGS", _show_settings)
    if not OS.has_feature("web"):
        _button("QUIT", func() -> void: get_tree().quit())
    footer_label.visible = true

func _show_hub() -> void:
    state = STATE_HUB
    _clear_world()
    _clear_menu()
    title_label.text = "WARDEN'S REST"
    subtitle_label.text = "The roots below the town are awake."
    var data: Dictionary = SaveManager.save_data
    info_label.text = "Root Amber: %d • Vitality +%d • Damage +%d • Best Depth %d • Wins %d" % [int(data.get("root_amber", 0)), int(data.get("max_hp_bonus", 0)), int(data.get("damage_bonus", 0)), int(data.get("best_depth", 0)), int(data.get("wins", 0))]
    _button("DESCEND INTO THE HOLLOW", _show_weapons)
    _button("GROW VITALITY — 8 Amber", _buy_hp)
    _button("HONE WEAPON — 10 Amber", _buy_damage)
    _button("SETTINGS", _show_settings)
    _button("TITLE", _show_title)

func _show_weapons() -> void:
    state = STATE_WEAPONS
    _clear_menu()
    title_label.text = "CHOOSE A WEAPON"
    subtitle_label.text = "Your reach changes the shape of every bargain."
    info_label.text = "Three combat rhythms are available in this vertical slice."
    for item: Dictionary in weapons:
        var copy: Dictionary = item.duplicate(true)
        _button("%s — %s" % [String(item.get("name", "Weapon")), String(item.get("desc", ""))], _choose_weapon.bind(copy))
    _button("BACK", _show_hub)

func _choose_weapon(chosen: Dictionary) -> void:
    selected_weapon = chosen
    _show_marks()

func _show_marks() -> void:
    state = STATE_MARKS
    _clear_menu()
    title_label.text = "CHOOSE A ROOTMARK"
    subtitle_label.text = "Every gift from the Hollow has teeth."
    info_label.text = "Weapon: %s. Pick one blessing/curse for this expedition." % String(selected_weapon.get("name", "Unknown"))
    for mark: Dictionary in marks:
        var copy: Dictionary = mark.duplicate(true)
        _button("%s — %s" % [String(mark.get("name", "Rootmark")), String(mark.get("desc", ""))], _start_run.bind(copy))
    _button("BACK", _show_weapons)

func _start_run(mark: Dictionary) -> void:
    selected_mark = mark
    state = STATE_RUN
    depth = 1
    wave = 0
    run_amber = 0
    _clear_menu()
    title_label.text = String(biome_data[0].get("name", "THE HOLLOW"))
    subtitle_label.text = "%s • Rootmark: %s" % [String(selected_weapon.get("name", "Weapon")), String(selected_mark.get("name", "Rootmark"))]
    player = BlackrootPlayer.new()
    player.process_mode = Node.PROCESS_MODE_PAUSABLE
    player.position = Vector2(160, 112)
    player.configure(SaveManager.save_data, selected_mark, selected_weapon)
    player.died.connect(_on_player_died)
    player.hp_changed.connect(func(_current: int, _maximum: int) -> void: _refresh_info())
    player.hurt.connect(_on_player_hurt)
    add_child(player)
    if not bool(SaveManager.save_data.get("tutorial_seen", false)):
        SaveManager.save_data["tutorial_seen"] = true
        SaveManager.save_progress()
        message = "MOVE • ATTACK • DODGE. Yellow/red boss tells mean GET OUT."
        banner_timer = 5.0
    _spawn_wave()
    _refresh_info()

func _spawn_wave() -> void:
    wave += 1
    var is_boss_wave: bool = wave % 4 == 0
    message = "BRIAR WARDEN — watch the charge tell" if is_boss_wave else "Depth %d — Encounter %d" % [depth, wave]
    banner_timer = 1.7
    if is_boss_wave:
        _spawn_enemy("briar_warden", Vector2(160, 55))
    else:
        var count: int = mini(2 + depth + int(wave / 2), 8)
        var kinds: Array[String] = ["thornling", "thornling", "brute", "stalker"]
        for i: int in range(count):
            var angle: float = TAU * float(i) / float(maxi(1, count))
            var spawn_pos: Vector2 = Vector2(160, 98) + Vector2(cos(angle), sin(angle)) * (55.0 + float((i * 13) % 25))
            _spawn_enemy(kinds[(i + depth + wave) % kinds.size()], spawn_pos)
    _refresh_info()

func _spawn_enemy(kind: String, spawn_pos: Vector2) -> void:
    var enemy: BlackrootEnemy = BlackrootEnemy.new()
    enemy.process_mode = Node.PROCESS_MODE_PAUSABLE
    enemy.position = spawn_pos
    enemy.configure(kind, depth, player)
    enemy.killed.connect(_on_enemy_killed)
    enemies.append(enemy)
    add_child(enemy)

func _do_attack() -> void:
    var attack: Dictionary = player.perform_attack()
    attack_flash = 0.09
    var hit_any: bool = false
    var attack_center: Vector2 = Vector2(attack.get("center", player.position))
    var attack_radius: float = float(attack.get("radius", 15.0))
    var attack_damage: int = int(attack.get("damage", 1))
    var attack_direction: Vector2 = Vector2(attack.get("direction", player.facing))
    var attack_knockback: float = float(attack.get("knockback", 90.0))
    var targets: Array[BlackrootEnemy] = enemies.duplicate()
    for enemy: BlackrootEnemy in targets:
        if not is_instance_valid(enemy):
            continue
        if enemy.position.distance_to(attack_center) <= attack_radius + enemy.radius:
            var force: Vector2 = attack_direction * attack_knockback
            var dealt: int = enemy.take_damage(attack_damage, force)
            player.heal_from_damage(dealt)
            hit_any = true
    if hit_any:
        _start_shake(0.09, 1.5)

func _on_enemy_killed(enemy: BlackrootEnemy, reward: int) -> void:
    enemies.erase(enemy)
    run_amber += reward
    _refresh_info()

func _on_player_hurt(_amount: int) -> void:
    _start_shake(0.16, 2.2)

func _start_shake(duration: float, strength: float) -> void:
    if not bool(SaveManager.settings.get("screen_shake", true)):
        return
    shake_time = maxf(shake_time, duration)
    shake_strength = maxf(shake_strength, strength)

func _advance_encounter() -> void:
    if wave % 4 == 0:
        SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) + run_amber
        SaveManager.save_data["best_depth"] = maxi(int(SaveManager.save_data.get("best_depth", 0)), depth)
        if depth >= 3:
            SaveManager.save_data["wins"] = int(SaveManager.save_data.get("wins", 0)) + 1
            SaveManager.save_progress()
            _show_victory()
            return
        depth += 1
        SaveManager.save_progress()
        wave = 0
        run_amber = 0
        if is_instance_valid(player):
            player.hp = player.max_hp
            player.hp_changed.emit(player.hp, player.max_hp)
        title_label.text = String(biome_data[depth - 1].get("name", "THE HOLLOW"))
        message = "ROOT VEIN CLEARED — DESCENDING"
        banner_timer = 2.0
    _spawn_wave()

func _on_player_died() -> void:
    SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) + int(run_amber / 2)
    SaveManager.save_data["best_depth"] = maxi(int(SaveManager.save_data.get("best_depth", 0)), depth)
    SaveManager.save_progress()
    state = STATE_GAMEOVER
    _clear_world()
    _clear_menu()
    title_label.text = "THE HOLLOW CLAIMED YOU"
    subtitle_label.text = "Half of the unbanked amber made it back to town."
    info_label.text = "Death is a setback, not a wipe. Spend what survived and choose a new weapon/Rootmark pairing."
    _button("RETURN TO WARDEN'S REST", _show_hub)
    _button("TITLE", _show_title)

func _show_victory() -> void:
    state = STATE_VICTORY
    _clear_world()
    _clear_menu()
    title_label.text = "THE HEARTWOOD BREAKS"
    subtitle_label.text = "Vertical-slice campaign clear."
    info_label.text = "The technical loop is complete. Production content, final art/audio, narrative closure, achievements, Steamworks integration, and release QA still gate 1.0."
    _button("RETURN TO WARDEN'S REST", _show_hub)
    _button("TITLE", _show_title)

func _buy_hp() -> void:
    if int(SaveManager.save_data.get("root_amber", 0)) < 8:
        info_label.text = "Not enough Root Amber."
        return
    SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) - 8
    SaveManager.save_data["max_hp_bonus"] = int(SaveManager.save_data.get("max_hp_bonus", 0)) + 1
    SaveManager.save_progress()
    _show_hub()

func _buy_damage() -> void:
    if int(SaveManager.save_data.get("root_amber", 0)) < 10:
        info_label.text = "Not enough Root Amber."
        return
    SaveManager.save_data["root_amber"] = int(SaveManager.save_data.get("root_amber", 0)) - 10
    SaveManager.save_data["damage_bonus"] = int(SaveManager.save_data.get("damage_bonus", 0)) + 1
    SaveManager.save_progress()
    _show_hub()

func _show_settings() -> void:
    if state != STATE_SETTINGS:
        settings_return_state = state
    state = STATE_SETTINGS
    _clear_menu()
    title_label.text = "SETTINGS"
    subtitle_label.text = "PC-first basics."
    info_label.text = "Settings persist immediately."
    var volume: int = int(round(float(SaveManager.settings.get("master_volume", 0.8)) * 100.0))
    _button("MASTER VOLUME: %d%%" % volume, _cycle_volume)
    _button("FULLSCREEN: %s" % ("ON" if bool(SaveManager.settings.get("fullscreen", false)) else "OFF"), _toggle_fullscreen)
    _button("SCREEN SHAKE: %s" % ("ON" if bool(SaveManager.settings.get("screen_shake", true)) else "OFF"), _toggle_shake)
    _button("HIGH CONTRAST: %s" % ("ON" if bool(SaveManager.settings.get("high_contrast", false)) else "OFF"), _toggle_contrast)
    _button("REDUCE FLASHES: %s" % ("ON" if bool(SaveManager.settings.get("reduce_flashes", false)) else "OFF"), _toggle_flashes)
    _button("BACK", _leave_settings)

func _leave_settings() -> void:
    if settings_return_state == STATE_HUB:
        _show_hub()
    else:
        _show_title()

func _cycle_volume() -> void:
    var value: float = float(SaveManager.settings.get("master_volume", 0.8)) - 0.2
    if value < 0.0:
        value = 1.0
    SaveManager.settings["master_volume"] = snappedf(value, 0.2)
    SaveManager.save_settings()
    _show_settings()

func _toggle_fullscreen() -> void:
    SaveManager.settings["fullscreen"] = not bool(SaveManager.settings.get("fullscreen", false))
    SaveManager.save_settings()
    _show_settings()

func _toggle_shake() -> void:
    SaveManager.settings["screen_shake"] = not bool(SaveManager.settings.get("screen_shake", true))
    SaveManager.save_settings()
    _show_settings()

func _toggle_contrast() -> void:
    SaveManager.settings["high_contrast"] = not bool(SaveManager.settings.get("high_contrast", false))
    high_contrast = bool(SaveManager.settings.get("high_contrast", false))
    SaveManager.save_settings()
    _show_settings()

func _toggle_flashes() -> void:
    SaveManager.settings["reduce_flashes"] = not bool(SaveManager.settings.get("reduce_flashes", false))
    SaveManager.save_settings()
    _show_settings()

func _refresh_info() -> void:
    if state != STATE_RUN or not is_instance_valid(player):
        return
    var message_suffix: String = " • " + message if message != "" else ""
    info_label.text = "HP %d/%d • Depth %d/3 • Encounter %d/4 • Run Amber %d • Enemies %d%s" % [player.hp, player.max_hp, depth, wave, run_amber, enemies.size(), message_suffix]

func _clear_world() -> void:
    get_tree().paused = false
    position = Vector2.ZERO
    if is_instance_valid(player):
        player.queue_free()
    player = null
    for enemy: BlackrootEnemy in enemies:
        if is_instance_valid(enemy):
            enemy.queue_free()
    enemies.clear()
    footer_label.visible = true

func _draw() -> void:
    var background: Color = Color("0e1714") if not high_contrast else Color.BLACK
    draw_rect(Rect2(0, 0, 320, 180), background)
    if state == STATE_RUN:
        var biome: Dictionary = biome_data[clampi(depth - 1, 0, biome_data.size() - 1)]
        var floor_color: Color = Color(biome.get("floor", Color("223425"))) if not high_contrast else Color("101010")
        var accent_color: Color = Color(biome.get("accent", Color("405b31"))) if not high_contrast else Color("3b3b3b")
        draw_rect(Rect2(10, 24, 300, 144), floor_color.darkened(0.25))
        draw_rect(Rect2(12, 26, 296, 140), floor_color)
        for x: int in range(18, 306, 24):
            draw_rect(Rect2(x, 30 + ((x * 7 + depth * 17) % 120), 2, 5), accent_color)
        if attack_flash > 0.0 and is_instance_valid(player) and not bool(SaveManager.settings.get("reduce_flashes", false)):
            var attack_center: Vector2 = player.position + player.facing.normalized() * float(selected_weapon.get("reach", 13.0))
            draw_circle(attack_center, float(selected_weapon.get("radius", 15.0)), Color(0.95, 0.82, 0.43, 0.20))
