# Touch Quest UI reference pack

The master PNG is an unchanged copy of the reference image supplied by the user.
The screen images and two strips are lossless crops at their original resolution.
They are design/QA references, not production backgrounds or asset exports.

Extract this archive into the root of the `touchquest` repository. The Codex
prompt is in `docs/prompts/touch_quest_ui_prompt.txt`.

## Current user override

Boss-hand artwork, mechanics, audio, badges and the 25,000-tap milestone have
been removed from the game at the user's request. Chaos entry now uses original
abstract neon zone artwork. This supersedes the creature depicted in the master,
Chaos crop and milestone strip. Those raster references remain unchanged archival
material and are not bundled production assets. The ordinary tutorial tap pointer
and original robot mascot remain valid references.

## Approved behavioral changes

- Keep the leaderboard layout, but omit player avatars/profile photographs.
- Keep the original robot as a game mascot in the Profile screen.
- Touch zones remain stationary, preview their next position, and switch
  discretely. Do not implement drifting, bouncing, or continuously moving zones.
- Correct generated-image typos and use accurate live game statistics.
- Phone frames, camera cutouts, presentation headings and the board footer are
  not app UI.

Crop coordinates are recorded in `crop_manifest.json`. The original board's
small illustrated screens do not constitute a layered/vector asset source.
High-resolution production artwork must be recreated separately.
