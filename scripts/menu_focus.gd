extends Node

var recovery_notice_shown := false

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
