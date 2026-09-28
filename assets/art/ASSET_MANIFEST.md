# Production artwork manifest

Generated 2026-09-28 with the built-in OpenAI `image_gen` image generation tool. All listed files are original generated production artwork. The supplied reference master and screen crops were visually inspected for style and composition only; they were not inserted, traced, or cropped into these production assets. No screenshot is bundled as production background art. Actual pixel dimensions below were verified with macOS `sips`; requested generation dimensions may differ from returned dimensions.

## Source and rights notes

- Method: individual built-in image generation requests, one per asset; ten world illustrations share one contact-sheet atlas.
- All images are copied unchanged from built-in generated outputs into this repository. No downloaded third-party artwork, image-processing edits, or screenshot crops were used.
- License/provenance: AI-generated output made for this project, subject to the user's applicable OpenAI terms. No separate third-party artwork license is asserted, and this manifest makes no claim that AI output is exclusively copyrightable.
- Alpha transparency was requested for the three character images and verified present. Backgrounds and atlas are opaque PNGs.
- Original generator source directory: `/Users/MattLeikam/.codex/generated_images/01a0e9b6-5e4b-76a3-b91b-dbc97d9188f7/`. Original files are retained there, but app asset paths refer only to repository copies.
- Quality checks: each generated output was visually inspected for composition, missing text/UI, expected theme and silhouette. Rendering checks should continue in the app at device scale.

## Inventory

| Asset relative to assets/art | Dimensions | Alpha | Purpose |
|---|---|---|---|
| backgrounds/menu.png | 948 × 1659 | No | Menu clouds, sky and floating islands; overlay live logo and controls. |
| characters/chaos_hand.png | 1312 × 1199 | Yes | Chaos boss hero, profile skin or milestone. |
| characters/robot.png | 1145 × 1374 | Yes | Profile avatar / tap assistant mascot. |
| characters/tutorial_hand.png | 1226 × 1283 | Yes | Gameplay tutorial hand; ripple circles drawn by widgets. |
| worlds/world_atlas.png | 1983 × 793 | No | Ten campaign world thumbnails, row-major grid below. |
| backgrounds/gameplay.png | 941 × 1672 | No | Calm gameplay atmosphere; overlay live particles and targets. |
| backgrounds/gameover.png | 941 × 1672 | No | Red storm atmosphere; overlay live result title and statistics. |

## Atlas mapping

`worlds/world_atlas.png` contains five columns and two rows with no gutters. Read equal normalized rectangles; fractional pixel dimensions are expected because 1983/5 and 793/2 are not integers. Order is zero-based, row-major.

| Index | Column | Row | Theme |
|---|---|---|---|
| 0 | 0 | 0 | Neon Beginnings |
| 1 | 1 | 0 | Pixel Panic |
| 2 | 2 | 0 | Underwater Tap |
| 3 | 3 | 0 | Cosmic Touch |
| 4 | 4 | 0 | Lava Fingers |
| 5 | 0 | 1 | Cyber City |
| 6 | 1 | 1 | Candy Chaos |
| 7 | 2 | 1 | Wizard Warp |
| 8 | 3 | 1 | Alien Arcade |
| 9 | 4 | 1 | Temple of the Tap God |

## Complete generation prompts and original sources

### backgrounds/menu.png

Original source filename: `exec-e881a00f-7748-4ed9-88ce-30dded10ecc4.png`

Use case: stylized-concept. Generate a production background asset for a polished portrait mobile arcade fantasy game. 1024x1792 tall portrait composition. Render only the environment, absolutely no text, logo, buttons, interface, phone frame, icon, hand, or character. The environment matches a glossy vibrant hand-painted 2D fantasy mobile illustration: near-black navy starry sky in the top 45 percent, sweeping lush billowing blue cyan and violet clouds framing both sides, electric magenta underglow along lower cloud edges, small purple rocky floating islands with vivid turquoise grassy tops and tiny stylized crystal formations near the bottom left and right edges. Distant small blue islands and sparkling particles provide depth. The main island on left sits near 75 percent down, right at 67 percent, another bottom right 88 percent. Leave the broad central column clean darker navy for separately drawn mobile interface: calm dark upper center for logo and dark open center for buttons. Lower center transitions to luminous violet blue mist. Rich deep blue shadows, cyan rim light, magenta accent sparkles, crisp readable stylized shapes and polished painterly texture, exciting magical arcade atmosphere. No real landscape horizon, no photorealism, no water, no lettering or symbols.

### characters/chaos_hand.png

Original source filename: `exec-0f7c5f54-7db7-4a64-a0c7-56296cc802a4.png`

Use case: stylized-concept. Asset type: isolated transparent PNG game boss illustration. Draw an original giant spectral purple hand reaching out at the viewer in a dramatic claw gesture, five distinct fingers with rounded magical violet nails and a wide palm, wrist tapering to an ethereal wisp at lower right. Entire hand visible with generous transparent margin all sides. Tilt the hand slightly clockwise, fingers curl downward toward viewer, index in upper center, thumb at left, little finger at right. Glossy hand-painted 2D arcade fantasy illustration, simple bold rounded anatomy, dark ultramarine purple interior shadows, luminous saturated violet and magenta edge highlights, subtle bright blue reflected glow. Sparse very small violet sparks around fingertips. Transparent background, genuinely empty alpha behind hand and glow. No scene, no interface, no text, no symbols, no card, no border, no objects, no humanoid body, no jewelry. Polished mobile game mascot style; playful menacing magical chaos hand.

### characters/robot.png

Original source filename: `exec-96491c18-f79a-469e-b171-f2bc998ff8b0.png`

Use case: stylized-concept. Asset type: transparent PNG mobile game robot mascot. One original cute tiny futuristic robot tap assistant, full body, facing viewer, centered on genuinely transparent background. Large rounded square white pearl head with navy black glass face, two bright cyan round expressive eyes and tiny glowing cyan smile; no mouth hole. Round white and lavender body with a simple cyan circular chest light, short chunky white arms with small rounded hands, sturdy short white and lavender boots. Small simple purple ear modules, a very short little antenna. Polished glossy hand-painted 3D-like 2D game illustration, joyful and friendly, clear readable rounded silhouette, white blue cyan palette with purple shaded edges, soft reflected cyan illumination. Entire mascot visible, generous empty margins around all sides. No text, no logos, no letters, no background, no scenery, no frame, no card, no floor shadow outside character. Exactly one robot. Original design, not a known movie character.

### characters/tutorial_hand.png

Original source filename: `exec-1b50d53f-298c-4e77-b2cc-afd5daa90d92.png`

Use case: stylized-concept. Asset type: isolated transparent tutorial hand pointer for neon arcade mobile game. Single friendly simplified white cartoon glove hand, palm angled toward viewer, index finger extended toward upper left, middle ring little fingers gently curled, thumb visible on left, wrist at bottom right. Compact crisp hand silhouette, only four cartoon fingers total like a simple game tutorial cursor. Smooth glossy white face, lavender purple shade, strong thin blue purple outline, soft cyan rim lighting. A violet glowing fingertip only, NO circles or ripple rings, no target and no extra particles so the app can animate a target separately. Centered entire hand with generous genuinely transparent margin. Glossy hand-painted polished mobile game illustration, readable at 60 pixels. Not a realistic skin hand. No text, no background, no UI, no other objects, no scenery, no checkerboard baked into image.

### worlds/world_atlas.png

Original source filename: `exec-d94608b2-36cb-41c2-88ea-fd1ef4604006.png`

Use case: stylized-concept. Asset type: ten-tile world thumbnail atlas for a mobile fantasy arcade game. Create one wide landscape 5-column by 2-row CONTACT SHEET. Aspect ratio 5:2. Every cell is EXACTLY the same square size, all cells touch edge-to-edge with NO gutters, NO borders, NO corner rounding. Exactly TEN distinct square illustrations, five across top and five across bottom. Illustrations do not cross their square cell edges. Each scene is full bleed, colorful polished glossy hand-painted 2D fantasy game art, crisp readable silhouettes and strong focal point for small thumbnails. Row one, left to right: (1) magical futuristic neon blue purple crystal city with a bright pink energy portal beam; (2) misty grayscale jagged pixel-like mountainous canyon with ruined angular towers, dramatic silver fog; (3) luminous cyan underwater coral realm with ocean ruins and a sunbeam; (4) deep violet outer space crystal valley framing a glowing cyan purple cosmic orb; (5) red-orange molten lava canyon with bright magma falls and black volcanic rocks. Row two, left to right: (6) bright blue cyan cyberpunk future city with pink neon lights; (7) candy-pink fantasy landscape of lollipops, candy hills and purple sweets; (8) magical wizard tower with floating spellbooks and a vibrant violet portal; (9) alien arcade world with green neon crystals, extraterrestrial mushroom architecture and violet sky; (10) golden ancient temple sanctuary, glowing gold altar and radiant crown-like mystical sun. No text anywhere, no letters, no labels, no words, no numbers, no logos, no locks, no badges, no UI. Exact regular grid with 5 columns × 2 rows, square cells of equal size. Ten unique game world illustrations.

### backgrounds/gameplay.png

Original source filename: `exec-8a9b635b-1f73-438e-a75f-426d207be918.png`

Use case: stylized-concept. Asset type: production portrait mobile arcade game background, pure environment with no interface. Tall portrait 9:16 illustration. Deep nearly black navy blue open starry sky with subtle electric blue luminous energy rays emanating from a point at center about 60 percent down, tiny distant violet and cyan sparkles. Faint purple faceted rock formations hug the far left and far right edges in lower half, soft dark blue violet mist at bottom. Keep the center 70 percent width very clean dark navy throughout for gameplay widgets to sit on top; center ray origin glow subtle dark blue, no bright orb. Top quarter especially calm, dark navy with sparse tiny stars. Polished hand-painted fantasy arcade atmosphere, rich blue black shadows with saturated cyan and violet accents at edges, dimensional but restrained. No text, no numbers, no logo, no phone, no UI, no border, no ring, no targets, no hand, no objects in the central play area. Full bleed opaque background.

### backgrounds/gameover.png

Original source filename: `exec-0a5bab8c-44d9-40e4-9003-19dd2902cee1.png`

Use case: stylized-concept. Asset type: pure portrait background environment for a mobile arcade game defeat results screen. Tall portrait 9:16 full bleed illustration. Deep dark black cherry burgundy sky, dramatic saturated red and magenta lightning in the UPPER THIRD and along upper side edges. Glowing stylized red storm cloud banks framing the upper corners, crimson crackles near top, dark wine-purple mist and subtle navy black shadows across bottom two thirds. Keep center broad calm very dark burgundy and purple for separately rendered title, panels, and buttons. Upper center remains dark enough for a gold title overlay. Polished glossy hand-painted 2D fantasy mobile game illustration, crisp dramatic cloud edges, vibrant red rim light, cinematic depth, fun high-energy game-over atmosphere. Do not draw any title or text or interface. No words, no numbers, no buttons, no icons, no phone or border, no symbols, no skulls, no people. Pure background scene only.



## Native vector and font assets

- Logo and warm GAME OVER/CHAOS titles: original layered Flutter vector/text
  composition in `lib/ui/widgets/arcade_widgets.dart` (ArcadeLogo/BeveledTitle),
  resolution independent. Editable source is the production implementation.
- Tap onboarding rings/sparks: original deterministic Canvas drawing in
  `lib/ui/widgets/tutorial_tap_artwork.dart`, composited with transparent hand.
- Active/next outlines, activation bursts and tap particles: original Flame
  Canvas drawing in `lib/game/touch_quest_game.dart`; bounded to the arena.
- Badges, medals, crown, locks and effects thumbnails: original Canvas artwork
  plus Material Icons in `lib/ui/screens/secondary_screens.dart`. Material Icons
  are Apache 2.0 licensed through Flutter; no player portraits/placeholders.
- Barlow Condensed ExtraBold and ExtraBold Italic: downloaded from
  https://github.com/google/fonts/tree/main/ofl/barlowcondensed; SIL OFL 1.1,
  full license at `assets/fonts/BarlowCondensed-OFL.txt`.
- Rajdhani SemiBold and Bold: downloaded from
  https://github.com/google/fonts/tree/main/ofl/rajdhani; SIL OFL 1.1,
  full license at `assets/fonts/Rajdhani-OFL.txt`.

Native art uses the project's source licensing. Generated art does not embed
labels, scores, progress, or interactive controls. Comparison PNGs and goldens
are excluded from the production asset bundle.
