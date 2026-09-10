extends CanvasLayer

# Browser/mobile playtest adapter. Blackroot Hollow remains a Steam/PC-first game.
# Phone testing is deliberately landscape-first so the combat field stays readable.

const GAME_SIZE := Vector2(320.0, 180.0)

# Hit areas stay generous; visuals are intentionally smaller so they do not bury the playfield.
const MOVE_ZONE := Rect2(6.0, 112.0, 104.0, 62.0)
const MOVE_VISUAL := Rect2(16.0, 132.0, 62.0, 32.0)
const ATTACK_ZONE := Rect2(250.0, 112.0, 66.0, 60.0)
const ATTACK_VISUAL := Rect2(270.0, 132.0, 38.0, 28.0)
const DODGE_ZONE := Rect2(194.0, 128.0, 62.0, 46.0)
const DODGE_VISUAL := Rect2(216.0, 143.0, 36.0, 22.0)
const PAUSE_ZONE := Rect2(268.0, 6.0, 48.0, 28.0)
const PAUSE_VISUAL := Rect2(280.0, 10.0, 32.0, 16.0)
const MOVE_RADIUS := 30.0

var touch_device := false
var move_touch_id := -1
var attack_touch_id := -1
var move_origin := Vector2.ZERO
var move_vector := Vector2.ZERO

var hud: Control
var move_label: Label
var attack_label: Label
var dodge_label: Label
var pause_label: Label
var last_layout_state := -1
var gameplay_panel_style: StyleBoxFlat

func _ready() -> void:
    layer = 50
    process_mode = Node.PROCESS_MODE_ALWAYS
    touch_device = _detect_touch_device()
    if touch_device:
        _build_styles()
        _build_hud()
        hud.visible = false
    set_process(touch_device)
    set_process_input(touch_device)

func _notification(what: int) -> void:
    if what == NOTIFICATION_APPLICATION_FOCUS_OUT:
        _reset_touches()

func _detect_touch_device() -> bool:
    return DisplayServer.is_touchscreen_available() or OS.has_feature("web_android") or OS.has_feature("web_ios")

func _process(delta: float) -> void:
    var game: Node = get_tree().current_scene
    var gameplay_active := _is_gameplay_active(game)
    var combat_active := gameplay_active and not get_tree().paused
    _sync_mobile_layout(game, combat_active)

    if hud != null:
        hud.visible = combat_active
    if not gameplay_active:
        _reset_touches()
        return

    var player: Node2D = _get_player(game)
    _sync_control_feedback(player)

    if get_tree().paused:
        _reset_touches()
        return
    if player == null:
        return

    if move_vector.length() > 0.05 and float(player.get("dodge_timer")) <= 0.0:
        var direction := move_vector.normalized()
        player.set("facing", direction)
        player.position += direction * float(player.get("speed")) * float(player.get("move_multiplier")) * delta
        if player.has_method("_clamp_to_bounds"):
            player.call("_clamp_to_bounds")
        player.queue_redraw()

    if attack_touch_id >= 0:
        _try_attack(game, player)

func _input(event: InputEvent) -> void:
    if not touch_device:
        return
    var game: Node = get_tree().current_scene
    if not _is_gameplay_active(game):
        return

    if event is InputEventScreenTouch:
        var touch := event as InputEventScreenTouch
        var game_position := _to_game_position(touch.position)
        if touch.pressed:
            if PAUSE_ZONE.has_point(game_position):
                if game.has_method("_toggle_pause"):
                    game.call("_toggle_pause")
                get_viewport().set_input_as_handled()
                return

            if get_tree().paused:
                return

            if MOVE_ZONE.has_point(game_position) and move_touch_id < 0:
                move_touch_id = touch.index
                move_origin = game_position
                move_vector = Vector2.ZERO
                get_viewport().set_input_as_handled()
                return

            if DODGE_ZONE.has_point(game_position):
                var dodge_player := _get_player(game)
                if dodge_player != null:
                    if dodge_player.has_method("try_dodge_direction"):
                        dodge_player.call("try_dodge_direction", move_vector)
                    elif dodge_player.has_method("try_dodge"):
                        dodge_player.call("try_dodge")
                get_viewport().set_input_as_handled()
                return

            if ATTACK_ZONE.has_point(game_position) and attack_touch_id < 0:
                attack_touch_id = touch.index
                var attack_player := _get_player(game)
                if attack_player != null:
                    _try_attack(game, attack_player)
                get_viewport().set_input_as_handled()
                return
        else:
            if touch.index == move_touch_id:
                move_touch_id = -1
                move_vector = Vector2.ZERO
                get_viewport().set_input_as_handled()
            if touch.index == attack_touch_id:
                attack_touch_id = -1
                get_viewport().set_input_as_handled()

    elif event is InputEventScreenDrag:
        var drag := event as InputEventScreenDrag
        if drag.index == move_touch_id and not get_tree().paused:
            var game_position := _to_game_position(drag.position)
            var raw := (game_position - move_origin) / MOVE_RADIUS
            move_vector = raw.limit_length(1.0)
            if move_vector.length() < 0.14:
                move_vector = Vector2.ZERO
            get_viewport().set_input_as_handled()

func _try_attack(game: Node, player: Node2D) -> void:
    if game.has_method("_do_attack") and player.has_method("can_attack") and bool(player.call("can_attack")):
        game.call("_do_attack")

func _is_gameplay_active(game: Node) -> bool:
    if game == null:
        return false
    var current_state: Variant = game.get("state")
    return current_state != null and int(current_state) == 4

func _get_player(game: Node) -> Node2D:
    if game == null:
        return null
    var candidate: Variant = game.get("player")
    if candidate is Node2D and is_instance_valid(candidate):
        return candidate as Node2D
    return null

func _sync_control_feedback(player: Node2D) -> void:
    if move_label != null:
        move_label.modulate = Color.WHITE if move_touch_id >= 0 else Color(1.0, 1.0, 1.0, 0.72)
    if attack_label != null:
        attack_label.modulate = Color.WHITE if attack_touch_id >= 0 else Color(1.0, 1.0, 1.0, 0.72)
    if dodge_label != null:
        var dodge_ready := player != null and float(player.get("dodge_cooldown")) <= 0.0 and float(player.get("dodge_timer")) <= 0.0
        dodge_label.modulate = Color.WHITE if dodge_ready else Color(1.0, 1.0, 1.0, 0.38)

func _sync_mobile_layout(game: Node, combat_active: bool) -> void:
    if game == null:
        return

    var desired_state := 1 if combat_active else 0
    if desired_state == last_layout_state:
        return
    last_layout_state = desired_state

    var root_ui_value: Variant = game.get("root_ui")
    if not (root_ui_value is CanvasLayer):
        return
    var ui_layer := root_ui_value as CanvasLayer
    if ui_layer.get_child_count() == 0:
        return
    var panel := ui_layer.get_child(0) as PanelContainer
    if panel == null:
        return

    var footer_value: Variant = game.get("footer_label")
    var title_value: Variant = game.get("title_label")
    var subtitle_value: Variant = game.get("subtitle_label")
    var info_value: Variant = game.get("info_label")

    if combat_active:
        if gameplay_panel_style == null:
            _build_styles()
        panel.position = Vector2(8, 5)
        panel.size = Vector2(304, 52)
        panel.add_theme_stylebox_override("panel", gameplay_panel_style)

        if footer_value is Label:
            (footer_value as Label).visible = false
        if title_value is Label:
            (title_value as Label).add_theme_font_size_override("font_size", 10)
        if subtitle_value is Label:
            (subtitle_value as Label).visible = false
        if info_value is Label:
            var info := info_value as Label
            info.add_theme_font_size_override("font_size", 6)
            info.custom_minimum_size = Vector2(0, 16)
    else:
        panel.position = Vector2(8, 7)
        panel.size = Vector2(304, 166)
        panel.remove_theme_stylebox_override("panel")

        if footer_value is Label:
            var footer := footer_value as Label
            footer.visible = true
            if not get_tree().paused:
                footer.text = "Tap options • rotate to landscape for combat"
        if title_value is Label:
            (title_value as Label).add_theme_font_size_override("font_size", 15)
        if subtitle_value is Label:
            var subtitle := subtitle_value as Label
            subtitle.visible = true
            subtitle.add_theme_font_size_override("font_size", 8)
        if info_value is Label:
            var info := info_value as Label
            info.add_theme_font_size_override("font_size", 8)
            info.custom_minimum_size = Vector2(0, 32)

func _reset_touches() -> void:
    move_touch_id = -1
    attack_touch_id = -1
    move_vector = Vector2.ZERO

func _to_game_position(screen_position: Vector2) -> Vector2:
    var visible_size := get_viewport().get_visible_rect().size
    if visible_size.x <= 0.0 or visible_size.y <= 0.0 or visible_size.is_equal_approx(GAME_SIZE):
        return screen_position
    var fit_scale := minf(visible_size.x / GAME_SIZE.x, visible_size.y / GAME_SIZE.y)
    if fit_scale <= 0.0:
        return screen_position
    var rendered_size := GAME_SIZE * fit_scale
    var offset := (visible_size - rendered_size) * 0.5
    return (screen_position - offset) / fit_scale

func _build_styles() -> void:
    gameplay_panel_style = StyleBoxFlat.new()
    gameplay_panel_style.bg_color = Color(0.02, 0.035, 0.028, 0.72)
    gameplay_panel_style.border_color = Color(0.25, 0.34, 0.22, 0.62)
    gameplay_panel_style.border_width_left = 1
    gameplay_panel_style.border_width_top = 1
    gameplay_panel_style.border_width_right = 1
    gameplay_panel_style.border_width_bottom = 1
    gameplay_panel_style.corner_radius_top_left = 3
    gameplay_panel_style.corner_radius_top_right = 3
    gameplay_panel_style.corner_radius_bottom_left = 3
    gameplay_panel_style.corner_radius_bottom_right = 3

func _build_hud() -> void:
    hud = Control.new()
    hud.position = Vector2.ZERO
    hud.size = GAME_SIZE
    hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(hud)

    move_label = _make_label("MOVE", MOVE_VISUAL, 6)
    attack_label = _make_label("ATTACK", ATTACK_VISUAL, 6)
    dodge_label = _make_label("DODGE", DODGE_VISUAL, 5)
    pause_label = _make_label("PAUSE", PAUSE_VISUAL, 4)

func _make_label(text_value: String, rect: Rect2, font_size: int) -> Label:
    var label := Label.new()
    label.position = rect.position
    label.size = rect.size
    label.text = text_value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    label.add_theme_font_size_override("font_size", font_size)

    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.018, 0.035, 0.028, 0.40)
    style.border_color = Color(0.58, 0.72, 0.46, 0.72)
    style.border_width_left = 1
    style.border_width_top = 1
    style.border_width_right = 1
    style.border_width_bottom = 1
    style.corner_radius_top_left = 4
    style.corner_radius_top_right = 4
    style.corner_radius_bottom_left = 4
    style.corner_radius_bottom_right = 4
    label.add_theme_stylebox_override("normal", style)
    hud.add_child(label)
    return label
