extends Node

const SAMPLE_RATE := 22050
var players: Array[AudioStreamPlayer] = []
var cursor := 0
var cache: Dictionary = {}

func _ready() -> void:
    for _i in range(8):
        var player := AudioStreamPlayer.new()
        player.bus = "SFX"
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
    player.pitch_scale = 0.97 + float((cursor * 7) % 5) * 0.015 if kind in ["hit", "kill"] else 1.0
    player.play()

func _noise(i: int) -> float:
    return sin(float(i * 15731 + 789221)) * 0.55 + sin(float(i * 31337 + 137631)) * 0.45

func _make_stream(kind: String) -> AudioStreamWAV:
    var duration := 0.08
    if kind == "kill": duration = 0.18
    elif kind == "hurt": duration = 0.14
    elif kind == "dodge": duration = 0.12
    elif kind == "boss": duration = 0.32
    elif kind == "ui": duration = 0.07
    var sample_count := maxi(1, int(SAMPLE_RATE * duration))
    var bytes := PackedByteArray()
    bytes.resize(sample_count * 2)

    for i in range(sample_count):
        var t := float(i) / float(SAMPLE_RATE)
        var progress := float(i) / float(sample_count)
        var env := pow(maxf(0.0, 1.0 - progress), 1.65)
        var wave := 0.0

        match kind:
            "attack":
                var f := lerpf(720.0, 180.0, progress)
                wave = sin(TAU * f * t) * 0.46 + _noise(i) * 0.20
                env *= sin(minf(1.0, progress * 7.0) * PI * 0.5)
            "hit":
                wave = _noise(i) * 0.46 + sin(TAU * 135.0 * t) * 0.34 + sin(TAU * 74.0 * t) * 0.18
            "kill":
                var f := lerpf(175.0, 48.0, progress)
                wave = sin(TAU * f * t) * 0.46 + sin(TAU * f * 1.97 * t) * 0.18 + _noise(i) * 0.18
            "hurt":
                var f := lerpf(118.0, 72.0, progress)
                wave = sin(TAU * f * t) * 0.44 + sin(TAU * f * 0.49 * t) * 0.22 + _noise(i) * 0.16
            "dodge":
                var f := lerpf(980.0, 360.0, progress)
                wave = sin(TAU * f * t) * 0.20 + _noise(i) * (0.10 + progress * 0.18)
                env *= sin(minf(1.0, progress * 5.0) * PI * 0.5)
            "boss":
                var pulse := sin(TAU * 5.0 * t) * 0.5 + 0.5
                wave = sin(TAU * 54.0 * t) * 0.36 + sin(TAU * 81.0 * t) * 0.23 + sin(TAU * 108.0 * t) * 0.10
                wave += _noise(i) * 0.08 * pulse
                env = pow(maxf(0.0, 1.0 - progress), 0.9)
            "ui":
                wave = sin(TAU * 620.0 * t) * 0.26 + sin(TAU * 930.0 * t) * 0.12
                env *= sin(minf(1.0, progress * 9.0) * PI * 0.5)
            _:
                wave = sin(TAU * 330.0 * t) * 0.20

        var sample := clampi(int(wave * env * 32767.0), -32768, 32767)
        bytes[i * 2] = sample & 0xff
        bytes[i * 2 + 1] = (sample >> 8) & 0xff

    var stream := AudioStreamWAV.new()
    stream.format = AudioStreamWAV.FORMAT_16_BITS
    stream.mix_rate = SAMPLE_RATE
    stream.stereo = false
    stream.data = bytes
    return stream
