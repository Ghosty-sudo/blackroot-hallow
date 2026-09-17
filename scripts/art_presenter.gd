class_name BlackrootArtPresenter
extends Node2D

var category: String = "actor"
var art_id: String = ""
var production_active: bool = false
var animated: AnimatedSprite2D
var static_sprite: Sprite2D

func configure(next_category: String, next_art_id: String) -> bool:
    category = next_category
    art_id = next_art_id
    _clear_visuals()
    var data := BlackrootArtCatalog.profile(category, art_id)
    if data.is_empty():
        production_active = false
        return false

    var frames_path := String(data.get("frames", ""))
    if not frames_path.is_empty() and ResourceLoader.exists(frames_path):
        var resource := load(frames_path)
        if resource is SpriteFrames:
            animated = AnimatedSprite2D.new()
            animated.sprite_frames = resource as SpriteFrames
            animated.centered = true
            animated.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            animated.scale = Vector2.ONE * float(data.get("scale", 1.0))
            add_child(animated)
            production_active = true
            play("idle")
            return true

    var texture_path := String(data.get("texture", ""))
    if not texture_path.is_empty() and ResourceLoader.exists(texture_path):
        var resource := load(texture_path)
        if resource is Texture2D:
            static_sprite = Sprite2D.new()
            static_sprite.texture = resource as Texture2D
            static_sprite.centered = true
            static_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
            static_sprite.scale = Vector2.ONE * float(data.get("scale", 1.0))
            add_child(static_sprite)
            production_active = true
            return true

    production_active = false
    return false

func play(animation: StringName) -> void:
    if animated == null or animated.sprite_frames == null:
        return
    if animated.sprite_frames.has_animation(animation):
        animated.play(animation)
    elif animated.sprite_frames.has_animation(&"idle"):
        animated.play(&"idle")

func set_facing(direction: Vector2) -> void:
    if absf(direction.x) < 0.1:
        return
    var flip := direction.x < 0.0
    if animated != null:
        animated.flip_h = flip
    if static_sprite != null:
        static_sprite.flip_h = flip

func set_hit_flash(active: bool) -> void:
    var modulation := Color(1.35, 1.35, 1.35, 1.0) if active else Color.WHITE
    if animated != null:
        animated.modulate = modulation
    if static_sprite != null:
        static_sprite.modulate = modulation

func _clear_visuals() -> void:
    if animated != null:
        animated.queue_free()
        animated = null
    if static_sprite != null:
        static_sprite.queue_free()
        static_sprite = null
    production_active = false
