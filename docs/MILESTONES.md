# Milestone implementation matrix

All 27 thresholds fire once per run, preserve their fired state on revive, and persist an achievement. Raw physical taps are never increased by effects. Tests advance a deterministic session through 100,001 taps and verify the entire ordered list.

| Taps | Implemented v1 presentation / behavior |
|---:|---|
| 100 | Background palette shift and achievement banner |
| 200 | Larger per-tap bounded particle bursts |
| 300 | 12-second original boing/pop/laser variation |
| 400 | 5-second low-amplitude color pulse; smooth accessibility policy |
| 500 | 10-second 2× bonus score, multiplier badge, alternate original music loop |
| 600 | Particle attraction/spiral gravity field |
| 700 | Clearly labeled in-game comedy message; no advertising calls |
| 800 | Fire-colored sparks and rings for the run |
| 900 | 8-second stronger bursts, large shockwaves and edge glow |
| 1,000 | Repeated fireworks, permanent badge, celebration sound and haptics |
| 2,000 | World palette/environment transformation |
| 3,000 | Local assistant comments on pace and near timeout |
| 4,000 | 10-second alternate palette overlay |
| 5,000 | Permanent-for-run gold effects; persistent gold cosmetic unlock |
| 6,000 | Tap-triggered percussion variation and animated rhythm equalizer |
| 7,000 | Canvas touch-origin ripple distortion fallback |
| 8,000 | Original “ABSOLUTE TAP UNIT” reaction message |
| 9,000 | Visual-only ghost rings; never routed to scoring |
| 10,000 | Golden HUD, persistent environment rings, repeated celebration |
| 15,000 | Persistent score perk: +1 bonus every ten future taps; raw count unchanged |
| 20,000 | Lightning strokes and electric audio on taps |
| 30,000 | 5-second scanline/fake system response sequence |
| 40,000 | Background palette responds to run tap speed |
| 50,000 | Original developer thank-you message |
| 60,000 | 30-second nested vortex presentation with spiral particles |
| 75,000 | Permanent Hall of Fame achievement; ranking category exposed |
| 100,000 | TAP GOD title/profile emblem, gold presentation and continuous celebration |

These are cross-platform Canvas interpretations, not advanced GPU lens shaders. Reduce Motion suppresses movement and repeated celebration bursts; the object pool remains capped. Hyper mode increases bounded bursts, rings, and a restrained edge glow; no target motion or camera shake is added. Beat feedback recognizes cadence consistency from the last eight tap intervals. Casual remains full-arena throughout; Campaign and Chaos change rectangles only after a visible three-tap/600ms preview and an accepted triggering tap. These effects are working Canvas implementations rather than GPU shader simulations. Hall of Fame publication requires trusted ranking service configuration.
