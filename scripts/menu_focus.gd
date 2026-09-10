extends Node

var recovery_notice_shown := false
var styled_panel: PanelContainer
var panel_style: StyleBoxFlat
var button_normal: StyleBoxFlat
var button_hover: StyleBoxFlat
var button_focus: StyleBoxFlat
var button_pressed: StyleBoxFlat

func _ready() -> void:
    _build_styles()

func _build_styles() -> void:
    panel_style = StyleBoxFlat.new()
    panel_style.bg_color = Color("111915")
    panel_style.border_color = Color("526044")
    panel_style.set_border_width_all(1)
    panel_style.set_corner_radius_all(3)
    panel_style.shadow_color = Color(0, 0, 0, 0.45)
    panel_style.shadow_size = 3

    button_normal = _button_style(Color("1a251d"), Color("46563d"))
    button_hover = _button_style(Color("263427"), Color("7b8e5c"))
    button_focus = _button_style(Color("2b3728"), Color("c1a75e"))
    button_pressed = _button_style(Color("34432e"), Color("dfc56e"))

func _button_style(fill: Color, border: Color) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = fill
    style.border_color = border
    style.set_border_width_all(1)
    style.set_corner_radius_all(2)
    style.content_margin_left = 6.0
    style.content_margin_right = 6.0
    style.content_margin_top = 2.0
    style.content_margin_bottom = 2.0
    return style

func _process(_delta: float) -> void:
    var scene := get_tree().current_scene
    if scene == null:
        return

    if not recovery_notice_shown and SaveManager.last_load_notice != "":
        var state_value: Variant = scene.get("state")
        var info_value: Variant = scene.get("info_label")
        if state_value != null and int(state_value) == 0 and info_value is Label:
            (info_value as Label).text += "\n" + SaveManager.last_load_notice
            recovery_notice_shown = true

    _style_scene(scene)
    _restore_focus(scene)

func _style_scene(scene: Node) -> void:
    var root_ui_value: Variant = scene.get("root_ui")
    if root_ui_value is CanvasLayer:
        var layer := root_ui_value as CanvasLayer
        if layer.get_child_count() > 0 and layer.get_child(0) is PanelContainer:
            var panel := layer.get_child(0) as PanelContainer
            if panel != styled_panel:
                styled_panel = panel
                panel.add_theme_stylebox_override("panel", panel_style)

    var title_value: Variant = scene.get("title_label")
    if title_value is Label:
        var title := title_value as Label
        title.add_theme_color_override("font_color", Color("eadcb5"))
        title.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.75))
        title.add_theme_constant_override("shadow_offset_x", 1)
        title.add_theme_constant_override("shadow_offset_y", 1)

    var subtitle_value: Variant = scene.get("subtitle_label")
    if subtitle_value is Label:
        (subtitle_value as Label).add_theme_color_override("font_color", Color("a9b892"))
    var info_value: Variant = scene.get("info_label")
    if info_value is Label:
        (info_value as Label).add_theme_color_override("font_color", Color("d8d3c3"))
    var footer_value: Variant = scene.get("footer_label")
    if footer_value is Label:
        (footer_value as Label).add_theme_color_override("font_color", Color("839078"))

    var menu_value: Variant = scene.get("menu_box")
    if not (menu_value is VBoxContainer):
        return
    for child: Node in (menu_value as VBoxContainer).get_children():
        if not (child is Button) or child.is_queued_for_deletion():
            continue
        var button := child as Button
        if button.has_meta("blackroot_styled"):
            continue
        button.set_meta("blackroot_styled", true)
        button.add_theme_stylebox_override("normal", button_normal)
        button.add_theme_stylebox_override("hover", button_hover)
        button.add_theme_stylebox_override("focus", button_focus)
        button.add_theme_stylebox_override("pressed", button_pressed)
        button.add_theme_color_override("font_color", Color("e0ddcf"))
        button.add_theme_color_override("font_hover_color", Color("fff4cc"))
        button.add_theme_color_override("font_focus_color", Color("fff0b0"))
        button.add_theme_color_override("font_pressed_color", Color("fff4c2"))

func _restore_focus(scene: Node) -> void:
    var viewport := get_viewport()
    if viewport.gui_get_focus_owner() != null:
        return
    var menu_value: Variant = scene.get("menu_box")
    if not (menu_value is VBoxContainer):
        return
    for child: Node in (menu_value as VBoxContainer).get_children():
        if child is Button and not child.is_queued_for_deletion() and child.visible and not child.disabled:
            (child as Button).grab_focus()
            return
