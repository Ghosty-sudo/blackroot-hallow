class_name BlackrootPlayer
extends Node2D

signal died
signal hp_changed(current: int, maximum: int)
signal hurt(amount: int)

var max_hp := 8
var hp := 8
var speed := 84.0
var damage := 2
var attack_cooldown := 0.0
var hurt_cooldown := 0.0
var dodge_timer := 0.0
var dodge_cooldown := 0.0
var dodge_cooldown_max := 0.72
var dodge_input_locked := false
var facing := Vector2.DOWN
var dodge_direction := Vector2.DOWN
var bounds := Rect2(14, 28, 292, 136)
var damage_multiplier := 1.0
var move_multiplier := 1.0
var incoming_multiplier := 1.0
var lifesteal := 0.0
var weapon: Dictionary = {}
var knockback_velocity := Vector2.ZERO
var relic_names: Array[String] = []

func configure(meta: Dictionary, mark: Dictionary, chosen_weapon: Dictionary) -> void:
    max_hp = maxi(1, 8 + int(meta.get("max_hp_bonus", 0)) + int(mark.get("hp_bonus", 0)))
    damage = 2 + int(meta.get("damage_bonus", 0)) + int(mark.get("damage_bonus", 0))
    damage_multiplier = float(mark.get("damage_mult", 1.0))
    move_multiplier = float(mark.get("speed_mult", 1.0))
    incoming_multiplier = float(mark.get("incoming_mult", 1.0))
    lifesteal = float(mark.get("lifesteal", 0.0))
    weapon = chosen_weapon.duplicate(true)
    dodge_cooldown_max = 0.72
    relic_names.clear()
    hp = max_hp
    dodge_input_locked = false
    hp_changed.emit(hp, max_hp)
    queue_redraw()

func apply_relic(relic: Dictionary) -> void:
    var relic_id := String(relic.get("id", ""))
    if relic_id in relic_names:
        return
    relic_names.append(relic_id)
    match relic_id:
        "thorn_heart":
            max_hp += 2
            hp = mini(max_hp, hp + 2)
        "keen_resin":
            damage_multiplier *= 1.20
        "hollow_step":
            move_multiplier *= 1.12
            dodge_cooldown_max *= 0.80
        "sapglass_fang":
            lifesteal += 0.12
        "warden_knot":
            incoming_multiplier *= 0.85
        "longroot_grip":
            weapon["reach"] = float(weapon.get("reach", 13.0)) * 1.18
            weapon["radius"] = float(weapon.get("radius", 15.0)) + 2.0
    hp_changed.emit(hp, max_hp)
    queue_redraw()

func _process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    hurt_cooldown = maxf(0.0, hurt_cooldown - delta)
    dodge_cooldown = maxf(0.0, dodge_cooldown - delta)
    if dodge_input_locked and not _desktop_dodge_down():
        dodge_input_locked = false
    knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 700.0 * delta)
    if knockback_velocity.length() > 0.1:
        position += knockback_velocity * delta
    if dodge_timer > 0.0:
        dodge_timer = maxf(0.0, dodge_timer - delta)
        position += dodge_direction * 220.0 * delta
        _clamp_to_bounds()
        queue_redraw()
        return
    var move := _movement_input()
    if move.length() > 0.05:
        move = move.normalized()
        facing = move
        position += move * speed * move_multiplier * delta
    _clamp_to_bounds()
    queue_redraw()

func _movement_input() -> Vector2:
    var move := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y += 1.0
    var joy := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    if joy.length() > 0.25:
        move = joy
    return move

func _desktop_dodge_down() -> bool:
    return Input.is_key_pressed(KEY_SHIFT) or Input.is_joy_button_pressed(0, JOY_BUTTON_B)

func try_dodge() -> bool:
    return _begin_dodge(_movement_input(), true)

func try_dodge_direction(requested_direction: Vector2) -> bool:
    return _begin_dodge(requested_direction, false)

func _begin_dodge(requested_direction: Vector2, lock_desktop_input: bool) -> bool:
    if dodge_cooldown > 0.0 or dodge_timer > 0.0:
        return false
    if lock_desktop_input and dodge_input_locked:
        return false
    var direction := requested_direction.normalized() if requested_direction.length() > 0.1 else facing.normalized()
    if direction.length() <= 0.1:
        direction = Vector2.DOWN
    dodge_direction = direction
    facing = direction
    dodge_timer = 0.18
    dodge_cooldown = dodge_cooldown_max
    hurt_cooldown = maxf(hurt_cooldown, 0.26)
    if lock_desktop_input:
        dodge_input_locked = true
    AudioManager.play_sfx("dodge")
    queue_redraw()
    return true

func can_attack() -> bool:
    return attack_cooldown <= 0.0 and dodge_timer <= 0.0

func perform_attack() -> Dictionary:
    attack_cooldown = float(weapon.get("cooldown", 0.32))
    AudioManager.play_sfx("attack")
    return {
        "center": position + facing.normalized() * float(weapon.get("reach", 13.0)),
        "radius": float(weapon.get("radius", 15.0)),
        "damage": maxi(1, roundi(float(damage) * damage_multiplier * float(weapon.get("damage_mult", 1.0)))),
        "knockback": float(weapon.get("knockback", 90.0)),
        "direction": facing.normalized()
    }

func take_damage(amount: int, source_position: Vector2 = Vector2.INF) -> void:
    if hurt_cooldown > 0.0 or dodge_timer > 0.0:
        return
    var final_damage := maxi(1, ceili(float(amount) * incoming_multiplier))
    hp = maxi(0, hp - final_damage)
    hurt_cooldown = 0.65
    if source_position != Vector2.INF:
        knockback_velocity += (position - source_position).normalized() * 95.0
    AudioManager.play_sfx("hurt")
    hurt.emit(final_damage)
    hp_changed.emit(hp, max_hp)
    if hp <= 0:
        died.emit()

func heal_from_damage(dealt: int) -> void:
    if lifesteal <= 0.0 or hp >= max_hp:
        return
    var healing := floori(float(dealt) * lifesteal)
    if healing > 0:
        hp = mini(max_hp, hp + healing)
        hp_changed.emit(hp, max_hp)

func _clamp_to_bounds() -> void:
    position.x = clampf(position.x, bounds.position.x, bounds.end.x)
    position.y = clampf(position.y, bounds.position.y, bounds.end.y)

func _draw() -> void:
    var flicker := hurt_cooldown > 0.0 and int(hurt_cooldown * 18.0) % 2 == 0
    var skin := Color.WHITE if flicker else Color("d9ba91")
    var cloak := Color("394b3d")
    var trim := Color("b99b55")
    if dodge_timer > 0.0:
        cloak = Color(0.45, 0.72, 0.74, 0.62)
        skin = Color(0.78, 0.95, 0.95, 0.68)

    draw_ellipse_shadow()
    # Boots and cloak make the Warden read as a character rather than a collision block.
    draw_rect(Rect2(-5, 4, 4, 3), Color("452f31"))
    draw_rect(Rect2(1, 4, 4, 3), Color("452f31"))
    draw_colored_polygon(PackedVector2Array([Vector2(-5,-4), Vector2(5,-4), Vector2(6,4), Vector2(0,7), Vector2(-6,4)]), cloak)
    draw_rect(Rect2(-5, -4, 2, 7), trim.darkened(0.18))
    draw_rect(Rect2(-3, -9, 6, 6), skin)
    draw_rect(Rect2(-4, -10, 8, 3), Color("2a2329"))
    draw_rect(Rect2(-4, -8, 2, 4), Color("2a2329"))
    if facing.y >= -0.4:
        draw_rect(Rect2(-2, -7, 1, 1), Color("241d20"))
        draw_rect(Rect2(1, -7, 1, 1), Color("241d20"))

    var direction := facing.normalized()
    var side := Vector2(-direction.y, direction.x)
    var hand := direction * 3.0 + side * 2.0
    var weapon_id := String(weapon.get("id", "blade"))
    if weapon_id == "pike":
        var tip := direction * 19.0
        draw_line(hand - direction * 4.0, tip, Color("80633f"), 2.0)
        draw_colored_polygon(PackedVector2Array([tip, tip - direction * 5.0 + side * 2.0, tip - direction * 5.0 - side * 2.0]), Color("d9d2bf"))
    elif weapon_id == "cleaver":
        var haft_end := direction * 11.0
        draw_line(hand, haft_end, Color("765538"), 2.0)
        draw_colored_polygon(PackedVector2Array([haft_end + side * 4.0, haft_end - side * 4.0, haft_end + direction * 6.0 - side * 2.0, haft_end + direction * 6.0 + side * 3.0]), Color("c4beb0"))
    else:
        var blade_tip := direction * 14.0
        draw_line(hand, blade_tip, Color("d7d2c3"), 2.0)
        draw_line(hand - side * 3.0, hand + side * 3.0, trim, 2.0)

func draw_ellipse_shadow() -> void:
    draw_set_transform(Vector2(0, 7), 0.0, Vector2(1.0, 0.45))
    draw_circle(Vector2.ZERO, 7.0, Color(0, 0, 0, 0.28))
    draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
