class_name BlackrootPlayer
extends Node2D

signal died
signal hp_changed(current: int, maximum: int)

var max_hp := 8
var hp := 8
var speed := 84.0
var damage := 2
var attack_cooldown := 0.0
var hurt_cooldown := 0.0
var facing := Vector2.DOWN
var bounds := Rect2(14, 28, 292, 136)
var damage_multiplier := 1.0
var move_multiplier := 1.0
var incoming_multiplier := 1.0
var lifesteal := 0.0

func configure(meta: Dictionary, mark: Dictionary) -> void:
    max_hp = 8 + int(meta.get("max_hp_bonus", 0)) + int(mark.get("hp_bonus", 0))
    damage = 2 + int(meta.get("damage_bonus", 0)) + int(mark.get("damage_bonus", 0))
    damage_multiplier = float(mark.get("damage_mult", 1.0))
    move_multiplier = float(mark.get("speed_mult", 1.0))
    incoming_multiplier = float(mark.get("incoming_mult", 1.0))
    lifesteal = float(mark.get("lifesteal", 0.0))
    hp = max_hp
    hp_changed.emit(hp, max_hp)
    queue_redraw()

func _process(delta: float) -> void:
    attack_cooldown = maxf(0.0, attack_cooldown - delta)
    hurt_cooldown = maxf(0.0, hurt_cooldown - delta)
    var move := Vector2.ZERO
    if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT): move.x -= 1.0
    if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT): move.x += 1.0
    if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP): move.y -= 1.0
    if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN): move.y += 1.0
    var joy := Vector2(Input.get_joy_axis(0, JOY_AXIS_LEFT_X), Input.get_joy_axis(0, JOY_AXIS_LEFT_Y))
    if joy.length() > 0.25:
        move = joy
    if move.length() > 0.05:
        move = move.normalized()
        facing = move
        position += move * speed * move_multiplier * delta
        position.x = clampf(position.x, bounds.position.x, bounds.end.x)
        position.y = clampf(position.y, bounds.position.y, bounds.end.y)
    queue_redraw()

func can_attack() -> bool:
    return attack_cooldown <= 0.0

func perform_attack() -> Dictionary:
    attack_cooldown = 0.32
    return {
        "center": position + facing.normalized() * 13.0,
        "radius": 15.0,
        "damage": maxi(1, roundi(float(damage) * damage_multiplier))
    }

func take_damage(amount: int) -> void:
    if hurt_cooldown > 0.0:
        return
    var final_damage := maxi(1, ceili(float(amount) * incoming_multiplier))
    hp = maxi(0, hp - final_damage)
    hurt_cooldown = 0.65
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

func _draw() -> void:
    var flash := hurt_cooldown > 0.0 and int(hurt_cooldown * 16.0) % 2 == 0
    var body_color := Color("f4e4bc") if not flash else Color.WHITE
    draw_rect(Rect2(-4, -5, 8, 10), body_color)
    draw_rect(Rect2(-3, -9, 6, 4), Color("3b2b2f"))
    draw_rect(Rect2(-5, 4, 4, 3), Color("5d3a3a"))
    draw_rect(Rect2(1, 4, 4, 3), Color("5d3a3a"))
    var tip := facing.normalized() * 11.0
    draw_line(Vector2.ZERO, tip, Color("d8d0c4"), 2.0)
