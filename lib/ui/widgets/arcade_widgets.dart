import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/arcade_theme.dart';
export '../theme/arcade_theme.dart';

class NeonPanel extends StatelessWidget {
  const NeonPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.color,
    this.borderColor,
    this.radius = 12,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color, borderColor;
  final double radius;
  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color ?? ArcadeColors.panelHighlight.withValues(alpha: .68),
          color ?? ArcadeColors.panel.withValues(alpha: .91),
        ],
      ),
      border: Border.all(
        color: borderColor ?? const Color(0xff296797),
        width: 1,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0x66000012),
          offset: Offset(0, 3),
          blurRadius: 8,
        ),
      ],
    ),
    child: child,
  );
}

enum ArcadeButtonStyle { primary, secondary, blue, green }

class ArcadeButton extends StatefulWidget {
  const ArcadeButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.style = ArcadeButtonStyle.secondary,
    this.height = 52,
  });
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final ArcadeButtonStyle style;
  final double height;
  @override
  State<ArcadeButton> createState() => _ArcadeButtonState();
}

class _ArcadeButtonState extends State<ArcadeButton> {
  bool down = false;
  @override
  Widget build(BuildContext context) {
    final colors = switch (widget.style) {
      ArcadeButtonStyle.primary => const [Color(0xffffe84d), Color(0xffffad09)],
      ArcadeButtonStyle.blue => const [Color(0xff19b9ff), Color(0xff0065ff)],
      ArcadeButtonStyle.green => const [Color(0xff39ff92), Color(0xff00da4e)],
      ArcadeButtonStyle.secondary => const [
        Color(0xff082951),
        Color(0xff040f2c),
      ],
    };
    final bright =
        widget.style == ArcadeButtonStyle.primary ||
        widget.style == ArcadeButtonStyle.green;
    final edge = switch (widget.style) {
      ArcadeButtonStyle.primary => const Color(0xfffff18c),
      ArcadeButtonStyle.green => const Color(0xffa5ffc3),
      _ => const Color(0xff50cafb),
    };
    return Semantics(
      button: true,
      enabled: widget.onPressed != null,
      child: AnimatedScale(
        scale: down && !MediaQuery.disableAnimationsOf(context) ? .975 : 1,
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : down
            ? ArcadeMotion.press
            : ArcadeMotion.release,
        child: Opacity(
          opacity: widget.onPressed == null ? .48 : 1,
          child: Container(
            constraints: BoxConstraints(minHeight: math.max(48, widget.height)),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: colors,
              ),
              border: Border.all(color: edge, width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: (bright ? colors.last : ArcadeColors.cyan).withValues(
                    alpha: widget.onPressed == null
                        ? .05
                        : bright
                        ? .38
                        : .11,
                  ),
                  blurRadius: bright ? 15 : 6,
                ),
                BoxShadow(
                  color: bright
                      ? const Color(0xff804211)
                      : const Color(0xff05071c),
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(11),
                onTap: widget.onPressed,
                onHighlightChanged: (v) => setState(() => down = v),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          size: 23,
                          color: bright
                              ? const Color(0xff111625)
                              : ArcadeColors.white,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Flexible(
                        child: Text(
                          widget.label,
                          textAlign: TextAlign.center,
                          style: ArcadeTypography.display.copyWith(
                            fontSize: widget.style == ArcadeButtonStyle.primary
                                ? 25
                                : 20,
                            height: 1.1,
                            color: bright
                                ? const Color(0xff111625)
                                : ArcadeColors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArcadeHeader extends StatelessWidget {
  const ArcadeHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.trailing,
  });
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(5, 13, 5, 10),
    child: Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: 'Back',
          icon: const Icon(Icons.chevron_left, size: 30),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: ArcadeTypography.title(25),
          ),
        ),
        SizedBox(width: 48, child: trailing),
      ],
    ),
  );
}

class ArcadeBottomNav extends StatelessWidget {
  const ArcadeBottomNav({
    super.key,
    required this.selected,
    required this.onNavigate,
    this.destinations = const ['menu', 'campaign', 'chaos', 'leaderboard'],
  });
  final String selected;
  final ValueChanged<String> onNavigate;
  final List<String> destinations;
  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Color(0xff04132c),
      border: Border(top: BorderSide(color: Color(0xff174b74))),
    ),
    padding: const EdgeInsets.fromLTRB(4, 3, 4, 4),
    child: Row(
      children: [
        for (final route in destinations)
          Expanded(
            child: Semantics(
              selected: selected == route,
              child: TextButton(
                onPressed: () => onNavigate(route),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 9),
                  foregroundColor: selected == route
                      ? ArcadeColors.cyan
                      : ArcadeColors.muted,
                  minimumSize: const Size(48, 62),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      switch (route) {
                        'menu' || 'home' => Icons.home_outlined,
                        'campaign' => Icons.workspace_premium_outlined,
                        'chaos' => Icons.auto_awesome_outlined,
                        'profile' => Icons.person_outline,
                        'settings' => Icons.settings_outlined,
                        _ => Icons.leaderboard_outlined,
                      },
                      size: 27,
                      shadows: selected == route
                          ? const [
                              Shadow(color: ArcadeColors.cyan, blurRadius: 13),
                            ]
                          : null,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      switch (route) {
                        'menu' || 'home' => 'Home',
                        'leaderboard' => 'Leaderboard',
                        _ => '${route[0].toUpperCase()}${route.substring(1)}',
                      },
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    ),
  );
}

class ArcadeBackground extends StatelessWidget {
  const ArcadeBackground({
    super.key,
    this.asset,
    required this.child,
    this.crimson = false,
    this.artOpacity = 1,
  });
  final String? asset;
  final Widget child;
  final bool crimson;
  final double artOpacity;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      gradient: RadialGradient(
        center: const Alignment(.2, -.5),
        radius: 1.3,
        colors: crimson
            ? const [Color(0xff4e0730), Color(0xff10051b), Color(0xff050719)]
            : const [Color(0xff0b2550), Color(0xff050d29), Color(0xff03091e)],
      ),
    ),
    child: Stack(
      fit: StackFit.expand,
      children: [
        if (asset != null)
          Positioned.fill(
            child: ExcludeSemantics(
              child: Opacity(
                opacity: artOpacity,
                child: Image.asset(
                  asset!,
                  fit: BoxFit.cover,
                  gaplessPlayback: true,
                ),
              ),
            ),
          ),
        child,
      ],
    ),
  );
}

class ArcadeLogo extends StatelessWidget {
  const ArcadeLogo({super.key});
  @override
  Widget build(BuildContext context) => Semantics(
    label: 'Touch Quest',
    image: true,
    child: ExcludeSemantics(
      child: FittedBox(
        fit: BoxFit.contain,
        child: Transform.rotate(
          angle: -.055,
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              BeveledTitle(
                text: 'TOUCH',
                fontSize: 100,
                colors: [
                  Color(0xffeaffff),
                  Color(0xff36f0ff),
                  Color(0xff0595f0),
                ],
                stroke: Color(0xff66f4ff),
                shadow: Color(0xff07378c),
              ),
              BeveledTitle(
                text: 'QUEST',
                fontSize: 110,
                colors: [
                  Color(0xffffff90),
                  Color(0xffffc932),
                  Color(0xffff5b70),
                ],
                stroke: Color(0xffffd562),
                shadow: Color(0xffa80b92),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class BeveledTitle extends StatelessWidget {
  const BeveledTitle({
    super.key,
    required this.text,
    required this.fontSize,
    required this.colors,
    this.stroke = ArcadeColors.yellow,
    this.shadow = const Color(0xff870d44),
  });
  final String text;
  final double fontSize;
  final List<Color> colors;
  final Color stroke, shadow;
  @override
  Widget build(BuildContext context) {
    final style = ArcadeTypography.display.copyWith(
      fontSize: fontSize,
      fontStyle: FontStyle.italic,
      height: .9,
      letterSpacing: 1,
    );
    return Stack(
      children: [
        Transform.translate(
          offset: const Offset(0, 5),
          child: Text(
            text,
            style: style.copyWith(
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = 5
                ..color = shadow,
              shadows: [Shadow(color: shadow, blurRadius: 15)],
            ),
          ),
        ),
        Text(
          text,
          style: style.copyWith(
            foreground: Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = 2.5
              ..color = stroke,
          ),
        ),
        ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ).createShader(rect),
          child: Text(text, style: style.copyWith(color: Colors.white)),
        ),
      ],
    );
  }
}

class BannerAdSlot extends StatelessWidget {
  const BannerAdSlot({super.key, required this.child, this.preview = false});
  final Widget child;
  final bool preview;
  @override
  Widget build(BuildContext context) => Container(
    key: const ValueKey('banner-region'),
    height: 70,
    padding: const EdgeInsets.only(top: 12, bottom: 8),
    decoration: const BoxDecoration(
      color: Color(0xff061022),
      border: Border(top: BorderSide(color: Color(0xff244a71))),
    ),
    alignment: Alignment.center,
    child: SizedBox(
      width: 320,
      height: 50,
      child: preview
          ? const ColoredBox(
              color: Color(0xffbed3ea),
              child: Center(
                child: Text(
                  'Ad Banner Area\n(320×50) · Preview',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff163875),
                    fontSize: 13,
                    height: 1.2,
                  ),
                ),
              ),
            )
          : child,
    ),
  );
}
