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
var dash_speed := 175.0
var dash_duration := 0.28
var chained_dashes := 0
var sentinel_mode := ""
var art_presenter: BlackrootArtPresenter
var production_art_active := false

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
        hp = 38
        speed = 24.0
        touch_damage = 2
        reward = 12
        radius = 12.0
        is_boss = true
        special_timer = 1.5
        dash_speed = 175.0
        dash_duration = 0.28
        AudioManager.play_sfx("boss")
    elif kind == "marrow_bell":
        hp = 52
        speed = 18.0
        touch_damage = 2
        reward = 16
        radius = 13.0
        is_boss = true
        special_timer = 1.7
        AudioManager.play_sfx("boss")
    elif kind == "ember_stag":
        hp = 62
        speed = 29.0
        touch_damage = 2
        reward = 20
        radius = 11.0
        is_boss = true
        special_timer = 1.4
        dash_speed = 240.0
        dash_duration = 0.17
        AudioManager.play_sfx("boss")
    elif kind == "heartwood_sentinel":
        hp = 96
        speed = 23.0
        touch_damage = 2
        reward = 30
        radius = 15.0
        is_boss = true
        special_timer = 1.35
        dash_speed = 215.0
        dash_duration = 0.22
        AudioManager.play_sfx("boss")
    max_hp = hp
    _configure_art()
    queue_redraw()

func _configure_art() -> void:
    if art_presenter == null:
        art_presenter = BlackrootArtPresenter.new()
        art_presenter.z_index = 2
        add_child(art_presenter)
    production_art_active = art_presenter.configure("actor", archetype)

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
    _update_art_state()
    queue_redraw()

func _update_art_state() -> void:
    if art_presenter == null or not production_art_active:
        return
    if is_instance_valid(target):
        art_presenter.set_facing(target.position - position)
    art_presenter.set_hit_flash(hit_flash_timer > 0.0)
    if dash_timer > 0.0:
        art_presenter.play(&"attack")
    elif telegraph_timer > 0.0:
        art_presenter.play(&"telegraph")
    else:
        art_presenter.play(&"move")

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
    match archetype:
        "marrow_bell": _process_marrow_bell(delta)
        "ember_stag": _process_ember_stag(delta)
        "heartwood_sentinel": _process_heartwood_sentinel(delta)
        _: _process_briar_warden(delta)

func _process_briar_warden(delta: float) -> void:
    if dash_timer > 0.0:
        dash_timer = maxf(0.0, dash_timer - delta)
        position += dash_direction * dash_speed * delta
        if position.distance_to(target.position) <= radius + 7.0 and attack_timer <= 0.0:
            target.take_damage(touch_damage + 1, position)
            attack_timer = 0.75
        return
    if telegraph_timer > 0.0:
        telegraph_timer = maxf(0.0, telegraph_timer - delta)
        if telegraph_timer <= 0.0:
            dash_timer = dash_duration
        return
    special_timer = maxf(0.0, special_timer - delta)
    if special_timer <= 0.0:
        dash_direction = (target.position - position).normalized()
        telegraph_timer = 0.55
        special_timer = 2.2
        return
    _boss_chase(delta, radius + 9.0)

func _process_marrow_bell(delta: float) -> void:
    if telegraph_timer > 0.0:
        telegraph_timer = maxf(0.0, telegraph_timer - delta)
        if telegraph_timer <= 0.0:
            if position.distance_to(target.position) <= 52.0 and attack_timer <= 0.0:
                target.take_damage(touch_damage + 1, position)
                attack_timer = 0.9
            special_timer = 2.4
        return
    special_timer = maxf(0.0, special_timer - delta)
    if special_timer <= 0.0:
        telegraph_timer = 0.80
        return
    var to_player := target.position - position
    if to_player.length() > 34.0:
        position += to_player.normalized() * speed * delta
    elif to_player.length() < 24.0:
        position -= to_player.normalized() * speed * 0.45 * delta
    elif attack_timer <= 0.0:
        target.take_damage(touch_damage, position)
        attack_timer = 1.0

func _process_ember_stag(delta: float) -> void:
    if dash_timer > 0.0:
        dash_timer = maxf(0.0, dash_timer - delta)
        position += dash_direction * dash_speed * delta
        if position.distance_to(target.position) <= radius + 6.0 and attack_timer <= 0.0:
            target.take_damage(touch_damage + 1, position)
            attack_timer = 0.55
        if dash_timer <= 0.0 and chained_dashes > 0:
            chained_dashes -= 1
            dash_direction = (target.position - position).normalized()
            telegraph_timer = 0.20
        return
    if telegraph_timer > 0.0:
        telegraph_timer = maxf(0.0, telegraph_timer - delta)
        if telegraph_timer <= 0.0:
            dash_timer = dash_duration
        return
    special_timer = maxf(0.0, special_timer - delta)
    if special_timer <= 0.0:
        dash_direction = (target.position - position).normalized()
        chained_dashes = 1
        telegraph_timer = 0.34
        special_timer = 2.3
        return
    _boss_chase(delta, radius + 11.0)

func _process_heartwood_sentinel(delta: float) -> void:
    if dash_timer > 0.0:
        dash_timer = maxf(0.0, dash_timer - delta)
        position += dash_direction * dash_speed * delta
        if position.distance_to(target.position) <= radius + 8.0 and attack_timer <= 0.0:
            target.take_damage(touch_damage + 1, position)
            attack_timer = 0.60
        if dash_timer <= 0.0 and chained_dashes > 0:
            chained_dashes -= 1
            dash_direction = (target.position - position).normalized()
            sentinel_mode = "dash"
            telegraph_timer = 0.22
        return
    if telegraph_timer > 0.0:
        telegraph_timer = maxf(0.0, telegraph_timer - delta)
        if telegraph_timer <= 0.0:
            if sentinel_mode == "pulse":
                if position.distance_to(target.position) <= 58.0 and attack_timer <= 0.0:
                    target.take_damage(touch_damage + 1, position)
                    attack_timer = 0.85
                special_timer = 1.85
            else:
                dash_timer = dash_duration
        return
    special_timer = maxf(0.0, special_timer - delta)
    if special_timer <= 0.0:
        var ratio := float(hp) / float(maxi(1, max_hp))
        if ratio > 0.66:
            sentinel_mode = "dash"
            chained_dashes = 0
            dash_speed = 205.0
            dash_duration = 0.24
            dash_direction = (target.position - position).normalized()
            telegraph_timer = 0.52
            special_timer = 2.0
        elif ratio > 0.33:
            sentinel_mode = "pulse"
            chained_dashes = 0
            telegraph_timer = 0.72
            special_timer = 2.1
        else:
            sentinel_mode = "dash"
            chained_dashes = 2
            dash_speed = 245.0
            dash_duration = 0.16
            dash_direction = (target.position - position).normalized()
            telegraph_timer = 0.30
            special_timer = 2.25
        return
    _boss_chase(delta, radius + 12.0)

func _boss_chase(delta: float, stop_distance: float) -> void:
    var to_player := target.position - position
    if to_player.length() > stop_distance:
        position += to_player.normalized() * speed * delta
    elif attack_timer <= 0.0:
        target.take_damage(touch_damage, position)
        attack_timer = 0.75

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
        if art_presenter != null and production_art_active:
            art_presenter.play(&"death")
        killed.emit(self, reward)
        queue_free()
    else:
        queue_redraw()
    return dealt

func _draw() -> void:
    if not production_art_active:
        _draw_prototype_body()
    _draw_combat_readability()

func _draw_prototype_body() -> void:
    var color := Color("6f8f3d")
    if archetype == "brute": color = Color("76554a")
    elif archetype == "stalker": color = Color("825a83")
    elif archetype == "briar_warden": color = Color("9e4638")
    elif archetype == "marrow_bell": color = Color("978775")
    elif archetype == "ember_stag": color = Color("c05a36")
    elif archetype == "heartwood_sentinel": color = Color("6f7048")
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
    elif archetype == "marrow_bell":
        draw_circle(Vector2.ZERO, 5.0, Color("ded6c8"))
    elif archetype == "ember_stag":
        draw_line(Vector2(-7, -8), Vector2(-13, -16), Color("e6b75b"), 2.0)
        draw_line(Vector2(7, -8), Vector2(13, -16), Color("e6b75b"), 2.0)
    elif archetype == "heartwood_sentinel":
        draw_line(Vector2(-10, -8), Vector2(-16, -18), Color("b8a85e"), 3.0)
        draw_line(Vector2(10, -8), Vector2(16, -18), Color("b8a85e"), 3.0)
        draw_circle(Vector2.ZERO, 5.0, Color("d0bd67"))

func _draw_combat_readability() -> void:
    if is_boss:
        if archetype == "briar_warden" and telegraph_timer > 0.0:
            draw_circle(Vector2.ZERO, radius + 6.0, Color(1.0, 0.25, 0.16, 0.20))
            draw_line(Vector2.ZERO, dash_direction * 34.0, Color(1.0, 0.70, 0.20, 0.85), 2.0)
        elif archetype == "marrow_bell" and telegraph_timer > 0.0:
            draw_arc(Vector2.ZERO, 52.0, 0.0, TAU, 48, Color(0.90, 0.85, 0.72, 0.85), 2.0)
        elif archetype == "ember_stag" and telegraph_timer > 0.0:
            draw_line(Vector2.ZERO, dash_direction * 40.0, Color(1.0, 0.52, 0.20, 0.92), 2.0)
        elif archetype == "heartwood_sentinel" and telegraph_timer > 0.0:
            if sentinel_mode == "pulse":
                draw_arc(Vector2.ZERO, 58.0, 0.0, TAU, 56, Color(0.82, 0.76, 0.36, 0.90), 2.0)
            else:
                draw_line(Vector2.ZERO, dash_direction * 46.0, Color(0.86, 0.68, 0.25, 0.95), 2.0)
        draw_rect(Rect2(-18, -20, 36, 3), Color("251f22"))
        draw_rect(Rect2(-18, -20, 36.0 * clampf(float(hp) / float(max_hp), 0.0, 1.0), 3), Color("e0b84a"))
    elif hp < max_hp:
        draw_rect(Rect2(-radius, -radius - 5.0, radius * 2.0, 2.0), Color("251f22"))
        draw_rect(Rect2(-radius, -radius - 5.0, radius * 2.0 * clampf(float(hp) / float(max_hp), 0.0, 1.0), 2.0), Color("d4c66a"))
