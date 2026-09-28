"""Generate Touch Quest's original mono PCM sound library. Run from repo root."""
import math
import struct
import wave
from pathlib import Path
# Stable synthesis IDs preserve existing sounds when catalog entries are removed.
SOUNDS = [('tap', 0), ('pop', 1), ('boing', 2), ('laser', 3), ('milestone', 4),
          ('danger', 5), ('gameover', 6), ('revive', 7), ('electric', 8),
          ('fireworks', 10), ('countdown', 11), ('menu', 12), ('music', 13), ('overdrive', 14)]
for name, index in SOUNDS:
    duration = 4 if name in ('music', 'overdrive') else .12 if index < 4 else .4
    rate = 22050
    with wave.open(str(Path('assets/audio') / (name + '.wav')), 'wb') as output:
        output.setnchannels(1)
        output.setsampwidth(2)
        output.setframerate(rate)
        frames = []
        for frame in range(int(rate * duration)):
            time = frame / rate
            if duration == 4:
                note = [220, 277.18, 329.63, 440, 329.63, 277.18, 246.94, 329.63][int(time * 2) % 8]
                sample = .16 * math.sin(2 * math.pi * note * time) * math.exp(-5 * (time % .5)) + .07 * math.sin(2 * math.pi * 110 * time)
                if name == 'overdrive':
                    sample += .08 * math.sin(2 * math.pi * 440 * time) * math.exp(-12 * (time % .25))
            else:
                frequency = 300 + index * 63 + (300 * math.sin(time * 25) if name == 'boing' else -200 * time)
                sample = .45 * math.sin(2 * math.pi * frequency * time) * math.exp(-time * 12) * min(time * 200, 1)
            frames.append(struct.pack('<h', int(sample * 32767)))
        output.writeframes(b''.join(frames))
