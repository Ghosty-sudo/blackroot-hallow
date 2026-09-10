extends Node2D

const PlayerScene := preload("res://scripts/player.gd")
const EnemyScene := preload("res://scripts/enemy.gd")

const STATE_TITLE := 0
const STATE_HUB := 1
const STATE_MARKS := 2
const STATE_RUN := 3
const STATE_GAMEOVER := 4
const STATE_VICTORY := 5
const STATE_SETTINGS := 6

var state := STATE_TITLE
var player: BlackrootPlayer
var enemies: Array[BlackrootEnemy] = []
var depth := 1
var wave := 0
var run_amber := 0
var selected_mark: Dictionary = {}
var attack_flash := 0.0
var banner_timer := 0.0
var message := ""
var root_ui: CanvasLayer
var title_label: Label
var subtitle_label: Label
var info_label: Label
var menu_box: VBoxContainer
var footer_label: Label
var high_contrast := false
var settings_return_state := STATE_TITLE

var marks := [
    {
        "name": "Briar Oath",
        "desc": "+50% damage, but enemies hurt 50% more.",
        "damage_mult": 1.5,
        "incoming_mult": 1.5
    },
    {
        "name": "Fleet Root",
        "desc": "+30% move speed, but -2 maximum HP.",
        "speed_mult": 1.3,
        "hp_bonus": -2
    },
    {
        "name": "Blood Sap",
        "desc": "+2 base damage and 25% lifesteal, but -1 maximum HP.",
        "damage_bonus": 2,
        "lifesteal": 0.25,
        "hp_bonus": -1
    }
]

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
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
    if state == STATE_RUN:
        if _attack_pressed() and is_instance_valid(player) and player.can_attack():
            _do_attack()
        if enemies.is_empty() and is_instance_valid(player):
            _advance_encounter()
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventKey and event.pressed and not event.echo:
        if event.keycode == KEY_ESCAPE:
            if state == STATE_RUN:
                get_tree().paused = not get_tree().paused
                message = "PAUSED — Esc to resume" if get_tree().paused else ""
                _refresh_info()
            elif state == STATE_SETTINGS:
                _leave_settings()
        elif event.keycode == KEY_ENTER and state == STATE_TITLE:
            _show_hub()
    if event is InputEventJoypadButton and event.pressed:
        if event.button_index == JOY_BUTTON_START and state == STATE_RUN:
            get_tree().paused = not get_tree().paused

func _attack_pressed() -> bool:
    return Input.is_key_pressed(KEY_SPACE) or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_A)

func _build_ui() -> void:
    root_ui = CanvasLayer.new()
    root_ui.process_mode = Node.PROCESS_MODE_ALWAYS
    add_child(root_ui)
    var panel := PanelContainer.new()
    panel.position = Vector2(8, 7)
    panel.size = Vector2(304, 166)
    root_ui.add_child(panel)
    var margin := MarginContainer.new()
    margin.add_theme_constant_override("margin_left", 9)
    margin.add_theme_constant_override("margin_right", 9)
    margin.add_theme_constant_override("margin_top", 7)
    margin.add_theme_constant_override("margin_bottom", 7)
    panel.add_child(margin)
    var v := VBoxContainer.new()
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
    footer_label.text = "WASD/Arrows move  •  Space/LMB/A attack  •  Esc/Start pause"
    v.add_child(footer_label)

func _clear_menu() -> void:
    for c in menu_box.get_children():
        c.queue_free()

func _button(text: String, callback: Callable) -> void:
    var b := Button.new()
    b.text = text
    b.add_theme_font_size_override("font_size", 8)
    b.custom_minimum_size = Vector2(0, 18)
    b.pressed.connect(callback)
    menu_box.add_child(b)

func _show_title() -> void:
    state = STATE_TITLE
    get_tree().paused = false
    _clear_world()
    _clear_menu()
    title_label.text = "BLACKROOT HOLLOW"
    subtitle_label.text = "A compact pixel action-RPG about power that always takes something back."
    info_label.text = "Descend beneath a dying frontier town. Bind cursed Rootmarks, hunt the Heartwood, and bring back enough amber to grow stronger between expeditions."
    _button("BEGIN", _show_hub)
    _button("SETTINGS", _show_settings)
    _button("QUIT", func(): get_tree().quit())
    footer_label.visible = true

func _show_hub() -> void:
    state = STATE_HUB
    _clear_world()
    _clear_menu()
    title_label.text = "WARDEN'S REST"
    subtitle_label.text = "The roots below the town are awake."
    var d := SaveManager.save_data
    info_label.text = "Root Amber: %d   •   Vitality +%d   •   Damage +%d   •   Best Depth %d   •   Wins %d" % [int(d.root_amber), int(d.max_hp_bonus), int(d.damage_bonus), int(d.best_depth), int(d.wins)]
    _button("DESCEND INTO THE HOLLOW", _show_marks)
    _button("GROW VITALITY — 8 Amber", _buy_hp)
    _button("HONE WEAPON — 10 Amber", _buy_damage)
    _button("SETTINGS", _show_settings)
    _button("TITLE", _show_title)

func _show_marks() -> void:
    state = STATE_MARKS
    _clear_menu()
    title_label.text = "CHOOSE A ROOTMARK"
    subtitle_label.text = "Every gift from the Hollow has teeth."
    info_label.text = "Pick one blessing/curse for this expedition. Rootmarks reset when the run ends."
    for mark in marks:
        var copy := mark.duplicate(true)
        _button("%s — %s" % [mark.name, mark.desc], _start_run.bind(copy))
    _button("BACK", _show_hub)

func _start_run(mark: Dictionary) -> void:
    selected_mark = mark
    state = STATE_RUN
    depth = 1
    wave = 0
    run_amber = 0
    _clear_menu()
    title_label.text = "THE BLACKROOT"
    subtitle_label.text = "Rootmark: %s" % selected_mark.name
    footer_label.visible = true
    player = BlackrootPlayer.new()
    player.process_mode = Node.PROCESS_MODE_PAUSABLE
    player.position = Vector2(160, 112)
    player.configure(SaveManager.save_data, selected_mark)
    player.died.connect(_on_player_died)
    player.hp_changed.connect(func(_c, _m): _refresh_info())
    add_child(player)
    _spawn_wave()
    _refresh_info()

func _spawn_wave() -> void:
    wave += 1
    var is_boss_wave := wave % 4 == 0
    message = "HEARTWOOD GUARDIAN" if is_boss_wave else "Depth %d — Encounter %d" % [depth, wave]
    banner_timer = 1.7
    if is_boss_wave:
        _spawn_enemy("heartwood", Vector2(160, 55))
    else:
        var count := mini(2 + depth + int(wave / 2), 8)
        var kinds := ["thornling", "thornling", "brute", "stalker"]
        for i in count:
            var angle := TAU * float(i) / float(maxi(1, count))
            var pos := Vector2(160, 98) + Vector2(cos(angle), sin(angle)) * (55.0 + float((i * 13) % 25))
            _spawn_enemy(kinds[(i + depth + wave) % kinds.size()], pos)
    _refresh_info()

func _spawn_enemy(kind: String, pos: Vector2) -> void:
    var e := BlackrootEnemy.new()
    e.process_mode = Node.PROCESS_MODE_PAUSABLE
    e.position = pos
    e.configure(kind, depth, player)
    e.killed.connect(_on_enemy_killed)
    enemies.append(e)
    add_child(e)

func _do_attack() -> void:
    var attack := player.perform_attack()
    attack_flash = 0.09
    for e in enemies.duplicate():
        if not is_instance_valid(e):
            continue
        if e.position.distance_to(attack.center) <= attack.radius + e.radius:
            var dealt := e.take_damage(int(attack.damage))
            player.heal_from_damage(dealt)

func _on_enemy_killed(enemy: BlackrootEnemy, reward: int) -> void:
    enemies.erase(enemy)
    run_amber += reward
    _refresh_info()

func _advance_encounter() -> void:
    if wave % 4 == 0:
        SaveManager.save_data.root_amber = int(SaveManager.save_data.root_amber) + run_amber
        SaveManager.save_data.best_depth = maxi(int(SaveManager.save_data.best_depth), depth)
        if depth >= 3:
            SaveManager.save_data.wins = int(SaveManager.save_data.wins) + 1
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
        message = "ROOT VEIN CLEARED — DESCENDING"
        banner_timer = 2.0
    _spawn_wave()

func _on_player_died() -> void:
    SaveManager.save_data.root_amber = int(SaveManager.save_data.root_amber) + int(run_amber / 2)
    SaveManager.save_data.best_depth = maxi(int(SaveManager.save_data.best_depth), depth)
    SaveManager.save_progress()
    state = STATE_GAMEOVER
    _clear_world()
    _clear_menu()
    title_label.text = "THE HOLLOW CLAIMED YOU"
    subtitle_label.text = "Half of the amber made it back to town."
    info_label.text = "Death is a setback, not a wipe. Spend what survived and descend again."
    _button("RETURN TO WARDEN'S REST", _show_hub)
    _button("TITLE", _show_title)

func _show_victory() -> void:
    state = STATE_VICTORY
    _clear_world()
    _clear_menu()
    title_label.text = "THE HEARTWOOD BREAKS"
    subtitle_label.text = "Prototype campaign clear."
    info_label.text = "You reached the current end of the vertical slice. The release target expands this into distinct biomes, enemies, weapons, bosses, quests, final narrative closure, achievements, audio, full art, and Steam packaging."
    _button("RETURN TO WARDEN'S REST", _show_hub)
    _button("TITLE", _show_title)

func _buy_hp() -> void:
    if int(SaveManager.save_data.root_amber) < 8:
        info_label.text = "Not enough Root Amber."
        return
    SaveManager.save_data.root_amber -= 8
    SaveManager.save_data.max_hp_bonus += 1
    SaveManager.save_progress()
    _show_hub()

func _buy_damage() -> void:
    if int(SaveManager.save_data.root_amber) < 10:
        info_label.text = "Not enough Root Amber."
        return
    SaveManager.save_data.root_amber -= 10
    SaveManager.save_data.damage_bonus += 1
    SaveManager.save_progress()
    _show_hub()

func _show_settings() -> void:
    if state != STATE_SETTINGS:
        settings_return_state = state
    state = STATE_SETTINGS
    _clear_menu()
    title_label.text = "SETTINGS"
    subtitle_label.text = "PC-first basics are present from the first playable."
    info_label.text = "Settings persist immediately."
    var volume := int(round(float(SaveManager.settings.master_volume) * 100.0))
    _button("MASTER VOLUME: %d%%" % volume, _cycle_volume)
    _button("FULLSCREEN: %s" % ("ON" if SaveManager.settings.fullscreen else "OFF"), _toggle_fullscreen)
    _button("SCREEN SHAKE: %s" % ("ON" if SaveManager.settings.screen_shake else "OFF"), _toggle_shake)
    _button("HIGH CONTRAST: %s" % ("ON" if SaveManager.settings.high_contrast else "OFF"), _toggle_contrast)
    _button("BACK", _leave_settings)

func _leave_settings() -> void:
    if settings_return_state == STATE_HUB:
        _show_hub()
    else:
        _show_title()

func _cycle_volume() -> void:
    var v := float(SaveManager.settings.master_volume)
    v -= 0.2
    if v < 0.0: v = 1.0
    SaveManager.settings.master_volume = snappedf(v, 0.2)
    SaveManager.save_settings()
    _show_settings()

func _toggle_fullscreen() -> void:
    SaveManager.settings.fullscreen = not bool(SaveManager.settings.fullscreen)
    SaveManager.save_settings()
    _show_settings()

func _toggle_shake() -> void:
    SaveManager.settings.screen_shake = not bool(SaveManager.settings.screen_shake)
    SaveManager.save_settings()
    _show_settings()

func _toggle_contrast() -> void:
    SaveManager.settings.high_contrast = not bool(SaveManager.settings.high_contrast)
    high_contrast = bool(SaveManager.settings.high_contrast)
    SaveManager.save_settings()
    _show_settings()

func _refresh_info() -> void:
    if state != STATE_RUN:
        return
    if not is_instance_valid(player):
        return
    info_label.text = "HP %d/%d   •   Depth %d/3   •   Encounter %d/4   •   Run Amber %d   •   Enemies %d%s" % [player.hp, player.max_hp, depth, wave, run_amber, enemies.size(), "   •   " + message if message != "" else ""]

func _clear_world() -> void:
    get_tree().paused = false
    if is_instance_valid(player):
        player.queue_free()
    player = null
    for e in enemies:
        if is_instance_valid(e): e.queue_free()
    enemies.clear()
    footer_label.visible = true

func _draw() -> void:
    var bg := Color("0e1714") if not high_contrast else Color.BLACK
    draw_rect(Rect2(0, 0, 320, 180), bg)
    if state == STATE_RUN:
        draw_rect(Rect2(10, 24, 300, 144), Color("18251d") if not high_contrast else Color("101010"))
        draw_rect(Rect2(12, 26, 296, 140), Color("243325") if not high_contrast else Color("181818"))
        for x in range(18, 306, 24):
            draw_rect(Rect2(x, 30 + ((x * 7) % 120), 2, 5), Color("3b5030"))
        if attack_flash > 0.0 and is_instance_valid(player):
            var attack_center := player.position + player.facing.normalized() * 13.0
            draw_circle(attack_center, 15.0, Color(0.95, 0.82, 0.43, 0.25))
