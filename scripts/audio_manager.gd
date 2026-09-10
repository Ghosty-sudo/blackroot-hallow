extends Node

const SAMPLE_RATE := 22050
var players: Array[AudioStreamPlayer] = []
var cursor := 0
var cache: Dictionary = {}

func _ready() -> void:
    for _i in range(6):
        var player := AudioStreamPlayer.new()
        add_child(player)
        players.append(player)

func play_sfx(kind: String) -> void:
    if players.is_empty():
        return
    if not cache.has(kind):
        cache[kind] = _make_stream(kind)
    var player := players[cursor]
    cursor = (cursor + 1) % players.size()
    player.stream = cache[kind]
    player.play()

func _make_stream(kind: String) -> AudioStreamWAV:
    var spec := {
        "attack": [520.0, 0.055, 0.22],
        "hit": [190.0, 0.045, 0.28],
        "kill": [120.0, 0.10, 0.30],
        "hurt": [95.0, 0.09, 0.34],
        "dodge": [760.0, 0.055, 0.18],
        "boss": [70.0, 0.22, 0.36],
        "ui": [630.0, 0.035, 0.14]
    }.get(kind, [330.0, 0.05, 0.15])
    var frequency := float(spec[0])
    var duration := float(spec[1])
    var amplitude := float(spec[2])
    var sample_count := maxi(1, int(SAMPLE_RATE * duration))
    var bytes := PackedByteArray()
    bytes.resize(sample_count * 2)
    for i in range(sample_count):
        var t := float(i) / float(SAMPLE_RATE)
        var decay := 1.0 - float(i) / float(sample_count)
        var wave := sin(TAU * frequency * t)
        if kind in ["hit", "hurt", "kill"]:
            wave = wave * 0.65 + sin(TAU * frequency * 0.51 * t) * 0.35
        var sample := clampi(int(wave * decay * amplitude * 32767.0), -32768, 32767)
        bytes[i * 2] = sample & 0xff
        bytes[i * 2 + 1] = (sample >> 8) & 0xff
    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = SAMPLE_RATE
    stream.stereo = false
    stream.data = bytes
    return stream
