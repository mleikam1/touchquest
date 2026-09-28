import 'package:flutter/material.dart';

abstract final class ArcadeColors {
  static const background = Color(0xff050a24);
  static const panel = Color(0xff071b3b);
  static const panelHighlight = Color(0xff0d2d59);
  static const cyan = Color(0xff00d9ff);
  static const magenta = Color(0xfff13cff);
  static const violet = Color(0xff7938f2);
  static const yellow = Color(0xffffe13b);
  static const orange = Color(0xffff9a00);
  static const green = Color(0xff00ee69);
  static const white = Color(0xfff5f7ff);
  static const muted = Color(0xffa8bcd8);
}

abstract final class ArcadeMetrics {
  static const portraitWidth = 430.0;
  static const pageInset = 20.0;
  static const radius = 12.0;
  static const minimumControl = 48.0;
  static const adWidth = 320.0;
  static const adHeight = 50.0;
}

abstract final class ArcadeMotion {
  static const press = Duration(milliseconds: 80);
  static const release = Duration(milliseconds: 120);
  static const page = Duration(milliseconds: 200);
  static const activation = Duration(milliseconds: 160);
}

abstract final class ArcadeTypography {
  static const display = TextStyle(
    fontFamily: 'BarlowCondensed',
    fontWeight: FontWeight.w800,
    color: ArcadeColors.white,
  );
  static const body = TextStyle(
    fontFamily: 'Rajdhani',
    fontWeight: FontWeight.w600,
    color: ArcadeColors.white,
    fontSize: 16,
  );
  static TextStyle title([double size = 26]) =>
      display.copyWith(fontSize: size, height: 1.05);
}

ThemeData arcadeTheme() => ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: ArcadeColors.background,
  fontFamily: 'Rajdhani',
  colorScheme: const ColorScheme.dark(
    primary: ArcadeColors.cyan,
    secondary: ArcadeColors.magenta,
    surface: ArcadeColors.panel,
    onSurface: ArcadeColors.white,
    error: Color(0xffff738f),
  ),
  textTheme: const TextTheme(
    bodyMedium: ArcadeTypography.body,
    bodyLarge: ArcadeTypography.body,
    bodySmall: TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: ArcadeColors.muted,
    ),
  ),
  dividerColor: const Color(0xff173b61),
  sliderTheme: SliderThemeData(
    activeTrackColor: ArcadeColors.cyan,
    inactiveTrackColor: const Color(0xff030b20),
    thumbColor: ArcadeColors.cyan,
    overlayColor: ArcadeColors.cyan.withValues(alpha: .15),
    trackHeight: 4,
    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
  ),
  switchTheme: SwitchThemeData(
    thumbColor: const WidgetStatePropertyAll(ArcadeColors.white),
    trackColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected)
          ? ArcadeColors.green
          : const Color(0xff415d86),
    ),
  ),
  dialogTheme: DialogThemeData(
    backgroundColor: ArcadeColors.panel,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: const BorderSide(color: ArcadeColors.cyan, width: .8),
    ),
  ),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: ArcadeColors.panelHighlight,
    contentTextStyle: ArcadeTypography.body,
    behavior: SnackBarBehavior.floating,
  ),
);

String formatNumber(num value) => value.round().toString().replaceAllMapped(
  RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
  (m) => '${m[1]},',
);
