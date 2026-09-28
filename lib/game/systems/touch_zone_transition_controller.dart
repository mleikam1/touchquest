import 'dart:math';
import 'dart:ui';

/// Arena-local geometry is the single source for both paint and input.
/// Nothing in this controller continuously moves an accepted hit area.
class TouchZoneTransitionController {
  TouchZoneTransitionController({
    int seed = 42,
    this.difficulty = 0,
    this.previewTapCount = 3,
    this.minimumPreviewDuration = .6,
    this.handoffDuration = .2,
    this.tapsBeforePreview = 4,
    this.arena = const Size(400, 500),
  }) : assert(previewTapCount >= 3),
       assert(minimumPreviewDuration >= .6),
       assert(handoffDuration >= 0),
       _random = Random(seed) {
    active = _initialZone();
  }

  final Random _random;

  /// Applied only when generating a future preview; existing geometry is immutable.
  int difficulty;
  final int previewTapCount, tapsBeforePreview;
  final double minimumPreviewDuration, handoffDuration;
  Size arena;
  late RRect active;
  RRect? next, previous;
  int previewTapsRemaining = 0, _acceptedSinceActivation = 0;
  double previewElapsed = 0, activationAge = 1, graceRemaining = 0;
  bool get isPreviewing => next != null;
  bool get previewReady => isPreviewing && previewTapsRemaining == 0;

  bool accepts(Offset point) =>
      active.contains(point) ||
      (graceRemaining > 0 && (previous?.contains(point) ?? false));

  /// Call once only after input has passed the old geometry's acceptance test.
  void acceptedTap([Offset? point]) {
    // Old grace-area taps score, but only the current area advances a preview.
    if (point != null && !active.contains(point)) return;
    if (next != null) {
      if (previewTapsRemaining > 0) previewTapsRemaining--;
      if (previewTapsRemaining == 0 &&
          previewElapsed + 1e-9 >= minimumPreviewDuration) {
        previous = active;
        active = next!;
        next = null;
        activationAge = 0;
        graceRemaining = handoffDuration;
        _acceptedSinceActivation = 0;
      }
      return;
    }
    _acceptedSinceActivation++;
    if (_acceptedSinceActivation >= tapsBeforePreview) startPreview();
  }

  void update(double activeSeconds) {
    if (activeSeconds <= 0) return;
    activationAge += activeSeconds;
    if (next != null) previewElapsed += activeSeconds;
    graceRemaining = max(0, graceRemaining - activeSeconds);
    if (graceRemaining < 1e-9) {
      graceRemaining = 0;
      previous = null;
    }
  }

  void startPreview() {
    if (next != null) return;
    next = _nextZone();
    previewTapsRemaining = previewTapCount;
    previewElapsed = 0;
  }

  RRect _initialZone() {
    final width = min(arena.width - 24, max(104.0, arena.width * .56));
    final height = min(arena.height - 24, max(88.0, arena.height * .23));
    return _bounded(
      Rect.fromCenter(
        center: Offset(arena.width * .5, arena.height * .68),
        width: width,
        height: height,
      ),
    );
  }

  RRect _nextZone() {
    final width = min(
      arena.width - 24,
      max(88.0, arena.width * (.52 - min(difficulty, 49) * .003)),
    );
    final height = min(
      arena.height - 24,
      max(88.0, arena.height * (.23 - min(difficulty, 49) * .001)),
    );
    // Alternate upper/lower positions; seeded jitter changes only future bounds.
    final below = active.center.dy < arena.height * .5;
    final center = Offset(
      arena.width * (.35 + _random.nextDouble() * .3),
      arena.height * (below ? .70 : .30),
    );
    return _bounded(
      Rect.fromCenter(center: center, width: width, height: height),
    );
  }

  RRect _bounded(Rect rect) {
    final inset = min(12.0, min(arena.width, arena.height) / 8);
    final width = rect.width.clamp(
      min(88.0, max(1.0, arena.width - inset * 2)),
      max(1.0, arena.width - inset * 2),
    );
    final height = rect.height.clamp(
      min(88.0, max(1.0, arena.height - inset * 2)),
      max(1.0, arena.height - inset * 2),
    );
    final left = rect.left.clamp(
      inset,
      max(inset, arena.width - inset - width),
    );
    final top = rect.top.clamp(
      inset,
      max(inset, arena.height - inset - height),
    );
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        left.toDouble(),
        top.toDouble(),
        width.toDouble(),
        height.toDouble(),
      ),
      Radius.circular(min(18, min(width, height) / 5)),
    );
  }

  /// Owner pauses first. Resize invalidates grace and re-arms any visible preview.
  void resize(Size newArena) {
    if (newArena == arena || newArena.isEmpty) return;
    final old = arena;
    arena = newArena;
    RRect scale(RRect zone) => _bounded(
      Rect.fromLTRB(
        zone.left / old.width * arena.width,
        zone.top / old.height * arena.height,
        zone.right / old.width * arena.width,
        zone.bottom / old.height * arena.height,
      ),
    );
    active = scale(active);
    if (next != null) {
      next = scale(next!);
      previewElapsed = 0;
      previewTapsRemaining = previewTapCount;
    }
    previous = null;
    graceRemaining = 0;
  }

  /// Deterministic gallery/test state. Does not write profile or progression data.
  void setFixture({
    required RRect active,
    RRect? next,
    RRect? previous,
    int previewTapsRemaining = 3,
    double previewElapsed = 0,
    double activationAge = 1,
    double graceRemaining = 0,
  }) {
    this.active = active;
    this.next = next;
    this.previous = previous;
    this.previewTapsRemaining = next == null ? 0 : previewTapsRemaining;
    this.previewElapsed = previewElapsed;
    this.activationAge = activationAge;
    this.graceRemaining = graceRemaining;
    _acceptedSinceActivation = 0;
  }
}
