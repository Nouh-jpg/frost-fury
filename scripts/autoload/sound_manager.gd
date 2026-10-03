extends Node

# Retro 16-bit Sound Synthesizer & Manager
# Generates authentic Sega Genesis / Arcade sounds procedurally at runtime!

var sfx_streams: Dictionary = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_generate_retro_sfx()

func _generate_retro_sfx() -> void:
	sfx_streams["punch"] = _create_hit_noise(0.08, 220.0, 60.0)
	sfx_streams["punch_heavy"] = _create_hit_noise(0.16, 160.0, 40.0)
	sfx_streams["uppercut"] = _create_sweep(0.22, 180.0, 700.0, "saw")
	sfx_streams["blitz"] = _create_sweep(0.28, 400.0, 950.0, "square")
	sfx_streams["jump"] = _create_sweep(0.14, 200.0, 480.0, "square")
	sfx_streams["freeze"] = _create_chime(0.35, [523.25, 659.25, 783.99, 1046.5])
	sfx_streams["kick_sphere"] = _create_hit_noise(0.25, 120.0, 45.0)
	sfx_streams["sphere_bounce"] = _create_sweep(0.12, 350.0, 180.0, "triangle")
	sfx_streams["shatter"] = _create_hit_noise(0.30, 400.0, 80.0, true)
	sfx_streams["pickup"] = _create_chime(0.18, [659.25, 880.0, 1318.5])
	sfx_streams["special"] = _create_sweep(0.45, 150.0, 880.0, "saw")
	sfx_streams["victory"] = _create_chime(0.60, [440.0, 554.37, 659.25, 880.0])

func play(sfx_name: String, pitch_scale: float = 1.0) -> void:
	if not sfx_streams.has(sfx_name):
		return
	
	var player := AudioStreamPlayer.new()
	player.stream = sfx_streams[sfx_name]
	player.pitch_scale = pitch_scale + randf_range(-0.06, 0.06)
	player.volume_db = -4.0
	add_child(player)
	player.play()
	player.finished.connect(func(): player.queue_free())

func _create_hit_noise(duration: float, start_freq: float, end_freq: float, is_shatter: bool = false) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	var phase := 0.0
	for i in range(num_samples):
		var t := float(i) / float(num_samples)
		var freq: float = lerp(start_freq, end_freq, t)
		phase += freq / float(sample_rate)
		
		# Square/Noise blend for punch impact
		var osc := 1.0 if fmod(phase, 1.0) < 0.5 else -1.0
		var noise := randf_range(-1.0, 1.0)
		var env := pow(1.0 - t, 2.0)
		
		var sample := 0.0
		if is_shatter:
			sample = (noise * 0.7 + osc * 0.3) * env
		else:
			sample = (osc * 0.6 + noise * 0.4) * env
		
		var byte_val := clampi(int((sample * 0.75 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _create_sweep(duration: float, start_freq: float, end_freq: float, wave_type: String) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	var phase := 0.0
	for i in range(num_samples):
		var t := float(i) / float(num_samples)
		var freq: float = lerp(start_freq, end_freq, t)
		phase += freq / float(sample_rate)
		
		var sample := 0.0
		var frac := fmod(phase, 1.0)
		if wave_type == "square":
			sample = 1.0 if frac < 0.5 else -1.0
		elif wave_type == "saw":
			sample = 2.0 * frac - 1.0
		elif wave_type == "triangle":
			sample = 4.0 * abs(frac - 0.5) - 1.0
			
		var env := 1.0 - t
		sample *= env * 0.7
		var byte_val := clampi(int((sample * 0.75 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream

func _create_chime(duration: float, freqs: Array) -> AudioStreamWAV:
	var sample_rate := 22050
	var num_samples := int(duration * sample_rate)
	var data := PackedByteArray()
	data.resize(num_samples)
	
	var note_duration := float(num_samples) / float(freqs.size())
	var phase := 0.0
	for i in range(num_samples):
		var note_idx := clampi(int(float(i) / note_duration), 0, freqs.size() - 1)
		var freq: float = freqs[note_idx]
		phase += freq / float(sample_rate)
		
		var t_note := fmod(float(i), note_duration) / note_duration
		var osc := sin(phase * TAU)
		var env := (1.0 - t_note) * 0.8
		var sample := osc * env
		
		var byte_val := clampi(int((sample * 0.75 + 0.5) * 255.0), 0, 255)
		data[i] = byte_val
		
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_8_BITS
	stream.mix_rate = sample_rate
	stream.data = data
	return stream
