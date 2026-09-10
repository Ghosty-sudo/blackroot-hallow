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

func configure(meta: Dictionary, mark: Dictionary, chosen_weapon: Dictionary) -> void:
    max_hp = maxi(1, 8 + int(meta.get("max_hp_bonus", 0)) + int(mark.get("hp_bonus", 0)))
    damage = 2 + int(meta.get("damage_bonus", 0)) + int(mark.get("damage_bonus", 0))
    damage_multiplier = float(mark.get("damage_mult", 1.0))
    move_multiplier = float(mark.get("speed_mult", 1.0))
    incoming_multiplier = float(mark.get("incoming_mult", 1.0))
    lifesteal = float(mark.get("lifesteal", 0.0))
    weapon = chosen_weapon.duplicate(true)
    hp = max_hp
    dodge_input_locked = false
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
    var joy := Vector2(
        Input.get_joy_axis(0, JOY_AXIS_LEFT_X),
        Input.get_joy_axis(0, JOY_AXIS_LEFT_Y)
    )
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
    dodge_cooldown = 0.72
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
        var away := (position - source_position).normalized()
        knockback_velocity += away * 95.0
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
    var body_color := Color.WHITE if flicker else Color("e7d6ad")
    if dodge_timer > 0.0:
        body_color = Color(0.75, 0.95, 1.0, 0.65)
    draw_rect(Rect2(-4, -5, 8, 10), body_color)
    draw_rect(Rect2(-3, -9, 6, 4), Color("352a31"))
    draw_rect(Rect2(-5, 4, 4, 3), Color("674244"))
    draw_rect(Rect2(1, 4, 4, 3), Color("674244"))
    draw_rect(Rect2(-5, -3, 2, 5), Color("445a46"))
    var tip := facing.normalized() * (12.0 if weapon.get("id", "") != "pike" else 17.0)
    draw_line(Vector2.ZERO, tip, Color("d9cfb9"), 2.0)
