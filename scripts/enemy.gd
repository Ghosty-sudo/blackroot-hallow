class_name BlackrootEnemy
extends Node2D

signal killed(enemy: BlackrootEnemy, reward: int)

var hp := 4
var speed := 30.0
var touch_damage := 1
var reward := 1
var radius := 6.0
var is_boss := false
var target: Node2D
var attack_timer := 0.0
var archetype := "thornling"

func configure(kind: String, depth: int, player: Node2D) -> void:
    archetype = kind
    target = player
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
    elif kind == "heartwood":
        hp = 32 + depth * 6
        speed = 24.0
        touch_damage = 2
        reward = 12
        radius = 12.0
        is_boss = true
    queue_redraw()

func _process(delta: float) -> void:
    if not is_instance_valid(target):
        return
    attack_timer = maxf(0.0, attack_timer - delta)
    var to_player := target.position - position
    if to_player.length() > radius + 6.0:
        position += to_player.normalized() * speed * delta
    elif attack_timer <= 0.0 and target.has_method("take_damage"):
        target.take_damage(touch_damage)
        attack_timer = 0.9 if not is_boss else 0.65
    queue_redraw()

func take_damage(amount: int) -> int:
    var dealt := mini(amount, hp)
    hp -= amount
    if hp <= 0:
        killed.emit(self, reward)
        queue_free()
    else:
        queue_redraw()
    return dealt

func _draw() -> void:
    var c := Color("6f8f3d")
    if archetype == "brute": c = Color("755447")
    elif archetype == "stalker": c = Color("80506b")
    elif archetype == "heartwood": c = Color("a14b3d")
    draw_rect(Rect2(-radius, -radius, radius * 2.0, radius * 2.0), c)
    draw_rect(Rect2(-radius + 2, -radius - 2, radius * 2.0 - 4, 2), Color("2d3829"))
    if is_boss:
        draw_rect(Rect2(-10, -17, 20, 3), Color("251f22"))
        draw_rect(Rect2(-10, -17, 20.0 * clampf(float(hp) / 50.0, 0.0, 1.0), 3), Color("e0b84a"))
