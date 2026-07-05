import 'package:flutter/material.dart';

/// "Blood Rite" design tokens — see docs/design-spec.md.
abstract class ImpColors {
  /// Screen background, everywhere.
  static const Color voidBlack = Color(0xFF0C0806);

  /// Player cards, dialogs, menu buttons.
  static const Color surface = Color(0xFF1A1109);

  /// Hairline borders on cards/dialogs.
  static const Color border = Color(0xFF2E2114);

  /// Border of a Seen player card.
  static const Color borderSeen = Color(0xFF3A1712);

  /// App bar bottom hairline.
  static const Color appBarBorder = Color(0xFF1E1408);

  /// Primary text, neutral filled buttons.
  static const Color bone = Color(0xFFE9DDC6);

  /// Text on blood fills.
  static const Color boneBright = Color(0xFFF2E9DA);

  /// Dialog body text, scoreboard points.
  static const Color boneDim = Color(0xFFC0B49A);

  /// Secondary text, hints, cancel actions, labels.
  static const Color ash = Color(0xFF8A7D66);

  /// Danger/drama accent. Scarce by design.
  static const Color blood = Color(0xFFA31621);

  static const Color deadSurface = Color(0xFF120C07);
  static const Color deadBorder = Color(0xFF1E1710);
  static const Color deadText = Color(0xFF5A5248);

  /// Text field underline, scoreboard dotted leaders.
  static const Color inputLine = Color(0xFF4A3A24);

  /// Dialog backdrop over game screen (~72% black).
  static const Color dimScrim = Color(0xB8000000);
}

abstract class ImpFonts {
  static const String display = 'Nosifer';
  static const String body = 'EB Garamond';
}

abstract class ImpTheme {
  /// Hero text glow: `0 0 40–50px blood@30–50%`.
  static List<Shadow> glow({double opacity = .4, double blur = 45}) => [
        Shadow(
          color: ImpColors.blood.withValues(alpha: opacity),
          blurRadius: blur,
        ),
      ];

  /// Ambient radial vignette for takeovers/menu: blood fading to
  /// transparent at ~70% radius.
  static BoxDecoration vignette({
    double opacity = .12,
    AlignmentGeometry center = const Alignment(0, -0.35),
  }) =>
      BoxDecoration(
        color: ImpColors.voidBlack,
        gradient: RadialGradient(
          center: center,
          radius: 0.9,
          colors: [
            ImpColors.blood.withValues(alpha: opacity),
            Colors.transparent,
          ],
          stops: const [0.0, 0.7],
        ),
      );

  static final RoundedRectangleBorder _buttonShape =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(4));

  static const TextStyle _buttonTextStyle = TextStyle(
    fontFamily: ImpFonts.body,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );

  /// Filled confirm — blood. Destructive/dramatic only.
  static ButtonStyle bloodButton({EdgeInsets? padding, double? fontSize}) =>
      ElevatedButton.styleFrom(
        backgroundColor: ImpColors.blood,
        foregroundColor: ImpColors.boneBright,
        elevation: 0,
        shape: _buttonShape,
        padding:
            padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        textStyle: fontSize == null
            ? _buttonTextStyle
            : _buttonTextStyle.copyWith(fontSize: fontSize),
      );

  static final ThemeData themeData = ThemeData(
    useMaterial3: true,

    colorScheme: const ColorScheme.dark(
      primary: ImpColors.bone,
      onPrimary: ImpColors.voidBlack,
      secondary: ImpColors.blood,
      onSecondary: ImpColors.boneBright,
      surface: ImpColors.surface,
      onSurface: ImpColors.bone,
      error: ImpColors.blood,
    ),

    fontFamily: ImpFonts.body,
    scaffoldBackgroundColor: ImpColors.voidBlack,
    splashFactory: InkRipple.splashFactory,

    appBarTheme: const AppBarTheme(
      backgroundColor: ImpColors.voidBlack,
      foregroundColor: ImpColors.bone,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      toolbarHeight: 60,
      titleSpacing: 20,
      titleTextStyle: TextStyle(
        fontFamily: ImpFonts.display,
        fontSize: 18,
        color: ImpColors.bone,
      ),
      shape: Border(
        bottom: BorderSide(color: ImpColors.appBarBorder, width: 1),
      ),
    ),

    textTheme: const TextTheme(
      // display-hero — menu title, revealed secret word.
      displayLarge: TextStyle(
        fontFamily: ImpFonts.display,
        fontSize: 54,
        color: ImpColors.bone,
      ),
      // display-lg — reveal name.
      displayMedium: TextStyle(
        fontFamily: ImpFonts.display,
        fontSize: 40,
        color: ImpColors.bone,
      ),
      // display-md — dialog pronouncements (copyWith fontSize per dialog).
      displaySmall: TextStyle(
        fontFamily: ImpFonts.display,
        fontSize: 26,
        color: ImpColors.bone,
      ),
      // heading — functional dialog titles.
      titleLarge: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ImpColors.bone,
      ),
      // body — dialog body, card names (21), input text.
      bodyLarge: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 19,
        height: 1.5,
        color: ImpColors.bone,
      ),
      // caption — subtexts, hints.
      bodyMedium: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 16,
        color: ImpColors.boneDim,
      ),
      // label — buttons, caps + tracking applied at use site.
      labelLarge: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 17,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: ImpColors.ash,
      ),
      labelMedium: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 2,
        color: ImpColors.ash,
      ),
    ),

    dialogTheme: DialogThemeData(
      backgroundColor: ImpColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      barrierColor: ImpColors.dimScrim,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: ImpColors.border, width: 1),
      ),
      titleTextStyle: const TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: ImpColors.bone,
      ),
      contentTextStyle: const TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 19,
        height: 1.5,
        color: ImpColors.boneDim,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(26, 8, 26, 20),
    ),

    // Filled confirm — bone. Neutral confirms (Add, Continue).
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ImpColors.bone,
        foregroundColor: ImpColors.voidBlack,
        elevation: 0,
        shape: _buttonShape,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        textStyle: _buttonTextStyle,
      ),
    ),

    // Quiet cancel — bare ash text, no container.
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: ImpColors.ash,
        textStyle: const TextStyle(fontFamily: ImpFonts.body, fontSize: 17),
      ),
    ),

    inputDecorationTheme: const InputDecorationTheme(
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ImpColors.inputLine, width: 1),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: ImpColors.inputLine, width: 1),
      ),
      hintStyle: TextStyle(
        fontFamily: ImpFonts.body,
        fontSize: 19,
        fontStyle: FontStyle.italic,
        color: ImpColors.ash,
      ),
    ),
  );
}
