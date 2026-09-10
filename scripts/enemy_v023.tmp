class_name BlackrootEnemy
extends Node2D

signal killed(enemy: BlackrootEnemy, reward: int)

var hp := 4
var max_hp := 4
var speed := 30.0
var touch_damage := 1
var reward := 1
var radius := 6.0
var is_boss := false
var target: Node2D
var attack_timer := 0.0
var special_timer := 0.0
var telegraph_timer := 0.0
var dash_timer := 0.0
var dash_direction := Vector2.ZERO
var knockback_velocity := Vector2.ZERO
var archetype := "thornling"
var hit_flash_timer := 0.0

func configure(kind: String, depth: int, player: Node2D) -> void:
    archetype = kind
    target = player
    add_to_group("blackroot_enemies")
    if kind == "thornling":
        hp = 3 + depth
        speed = 29.0 + depth * 1.5
        touch_damage = 1
        reward = 1
        radius = 5.0
    elif kind == "brute":
        hp = 7 + depth * 2
        speed = 20.0 + depth
        touch_damage = 2
        reward = 2
        radius = 7.0
    elif kind == "stalker":
        hp = 4 + depth
        speed = 43.0 + depth
        touch_damage = 1
        reward = 2
        radius = 5.0
    elif kind == "briar_warden":
        hp = 34 + depth * 7
        speed = 24.0
        touch_damage = 2
        reward = 12
        radius = 12.0
        is_boss = true
        special_timer = 1.8
        AudioManager.play_sfx("boss")
    max_hp = hp
    queue_redraw()

func _process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    hit_flash_timer = maxf(0.0, hit_flash_timer - delta)
    knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 650.0 * delta)
    if knockback_velocity.length() > 0.1:
        position += knockback_velocity * delta
    if is_boss:
        _process_boss(delta)
    else:
        _process_regular(delta)
        _apply_separation(delta)
    position.x = clampf(position.x, 14.0, 306.0)
    position.y = clampf(position.y, 28.0, 164.0)
    queue_redraw()

func _process_regular(delta: float) -> void:
    var to_player := target.position - position
    if to_player.length() > radius + 6.0:
        position += to_player.normalized() * speed * delta
    elif attack_timer <= 0.0 and target.has_method("take_damage"):
        target.take_damage(touch_damage, position)
        attack_timer = 0.9

func _apply_separation(delta: float) -> void:
    for node: Node in get_tree().get_nodes_in_group("blackroot_enemies"):
        if node == self or not (node is BlackrootEnemy) or not is_instance_valid(node):
            continue
        var other := node as BlackrootEnemy
        if other.is_boss:
            continue
        var offset := position - other.position
        var distance := offset.length()
        var desired := radius + other.radius + 2.0
        if distance >= desired:
            continue
        if distance <= 0.01:
            var angle := float(get_instance_id() % 16) / 16.0 * TAU
            offset = Vector2.RIGHT.rotated(angle)
            distance = 0.0
        position += offset.normalized() * minf(24.0 * delta, maxf(0.0, desired - distance) * 0.5)

func _process_boss(delta: float) -> void:
    if dash_timer > 0.0:
        dash_timer = maxf(0.0, dash_timer - delta)
        position += dash_direction * 175.0 * delta
        if position.distance_to(target.position) <= radius + 7.0 and attack_timer <= 0.0:
            target.take_damage(touch_damage + 1, position)
            attack_timer = 0.75
        return
    if telegraph_timer > 0.0:
        telegraph_timer = maxf(0.0, telegraph_timer - delta)
        if telegraph_timer <= 0.0:
            dash_timer = 0.28
        return
    special_timer = maxf(0.0, special_timer - delta)
    if special_timer <= 0.0:
        dash_direction = (target.position - position).normalized()
        telegraph_timer = 0.55
        special_timer = 2.2
        return
    var to_player := target.position - position
    if to_player.length() > radius + 9.0:
        position += to_player.normalized() * speed * delta
    elif attack_timer <= 0.0:
        target.take_damage(touch_damage, position)
        attack_timer = 0.7

func take_damage(amount: int, force: Vector2 = Vector2.ZERO) -> int:
    var dealt := mini(amount, hp)
    hp -= amount
    hit_flash_timer = 0.10
    if not is_boss:
        knockback_velocity += force
    else:
        knockback_velocity += force * 0.25
    AudioManager.play_sfx("hit")
    if hp <= 0:
        AudioManager.play_sfx("kill")
        killed.emit(self, reward)
        queue_free()
    else:
        queue_redraw()
    return dealt

func _draw() -> void:
    var color := Color("6f8f3d")
    if archetype == "brute": color = Color("76554a")
    elif archetype == "stalker": color = Color("825a83")
    elif archetype == "briar_warden": color = Color("9e4638")
    if hit_flash_timer > 0.0:
        color = color.lightened(0.45)
    draw_rect(Rect2(-radius, -radius, radius * 2.0, radius * 2.0), color)
    draw_rect(Rect2(-radius + 2.0, -radius - 2.0, radius * 2.0 - 4.0, 2.0), Color("2d3829"))
    if archetype == "thornling":
        draw_line(Vector2(-4, -4), Vector2(-8, -9), Color("b7b873"), 2.0)
        draw_line(Vector2(4, -4), Vector2(8, -9), Color("b7b873"), 2.0)
    elif archetype == "brute":
        draw_rect(Rect2(-9, -3, 18, 6), Color(0.22, 0.17, 0.15, 0.5))
    elif archetype == "stalker":
        draw_line(Vector2(-5, 5), Vector2(-10, 10), Color("bb83b0"), 2.0)
        draw_line(Vector2(5, 5), Vector2(10, 10), Color("bb83b0"), 2.0)
    if is_boss:
        if telegraph_timer > 0.0:
            draw_circle(Vector2.ZERO, radius + 6.0, Color(1.0, 0.25, 0.16, 0.20))
            draw_line(Vector2.ZERO, dash_direction * 34.0, Color(1.0, 0.70, 0.20, 0.85), 2.0)
        draw_rect(Rect2(-18, -20, 36, 3), Color("251f22"))
        draw_rect(Rect2(-18, -20, 36.0 * clampf(float(hp) / float(max_hp), 0.0, 1.0), 3), Color("e0b84a"))
    elif hp < max_hp:
        draw_rect(Rect2(-radius, -radius - 5.0, radius * 2.0, 2.0), Color("251f22"))
        draw_rect(Rect2(-radius, -radius - 5.0, radius * 2.0 * clampf(float(hp) / float(max_hp), 0.0, 1.0), 2.0), Color("d4c66a"))
