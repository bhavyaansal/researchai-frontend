import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark Pro & Warm Light Theme Colors & Design Tokens for ResearchAI
class AppColors {
  // Dark Pro Mode Tokens (Default)
  static const darkBgDeep       = Color(0xFF060610); // Deepest bg, behind sidebar
  static const darkBgBase       = Color(0xFF0D0D1F); // Main page background
  static const darkSurfaceCard  = Color(0xFF13132A); // Card / panel surface
  static const darkSurfaceElev  = Color(0xFF1A1A35); // Elevated cards, inputs
  static const darkBorderSubtle = Color(0xFF252545); // Card borders, dividers
  static const darkBorderMid    = Color(0xFF2E2E58); // Active borders, focus

  static const darkAccentGreen  = Color(0xFF00E5A0); // Primary CTA, electric cyan-green
  static const darkAccentGreenDim = Color(0xFF00B880); // Hover state of green
  static const darkAccentRed    = Color(0xFFFF4D6A); // Flagged / direct match
  static const darkAccentOrange = Color(0xFFFF8C42); // Paraphrased / warning
  static const darkAccentBlue   = Color(0xFF4D8EFF); // Info, mitigation stage
  static const darkAccentPurple = Color(0xFF8B5CF6); // Secondary accent, AI

  static const darkTextPrimary   = Color(0xFFF0F0FF); // Headlines, body text
  static const darkTextSecondary = Color(0xFF8888BB); // Labels, subtitles
  static const darkTextTertiary  = Color(0xFF4A4A7A); // Placeholders, muted

  // Warm Light Mode Tokens
  static const lightBgBase       = Color(0xFFFAFAF8);
  static const lightSurfaceCard  = Color(0xFFFFFFFF);
  static const lightSurfaceElev  = Color(0xFFF5F4F0);
  static const lightBorderSubtle = Color(0xFFE8E6E0);
  static const lightBorderMid    = Color(0xFFD4D0C8);

  static const lightAccentGreen  = Color(0xFF4338CA); // Indigo primary
  static const lightAccentGreenDim = Color(0xFF3730A3);
  static const lightAccentRed    = Color(0xFFB91C1C);
  static const lightAccentOrange = Color(0xFFB45309);
  static const lightAccentBlue   = Color(0xFF0F766E);
  static const lightAccentPurple = Color(0xFF6D28D9);

  static const lightTextPrimary   = Color(0xFF1C1917);
  static const lightTextSecondary = Color(0xFF57534E);
  static const lightTextTertiary  = Color(0xFFA8A29E);

  // Dynamic Getters based on context brightness
  static Color bgDeep(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBgDeep : const Color(0xFFF0EFEA);

  static Color bgBase(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBgBase : lightBgBase;

  static Color surfaceCard(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceCard : lightSurfaceCard;

  static Color surfaceElevated(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkSurfaceElev : lightSurfaceElev;

  static Color borderSubtle(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorderSubtle : lightBorderSubtle;

  static Color borderMid(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkBorderMid : lightBorderMid;

  static Color accentGreen(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentGreen : lightAccentGreen;

  static Color accentGreenDim(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentGreenDim : lightAccentGreenDim;

  static Color accentRed(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentRed : lightAccentRed;

  static Color accentOrange(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentOrange : lightAccentOrange;

  static Color accentBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentBlue : lightAccentBlue;

  static Color accentPurple(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkAccentPurple : lightAccentPurple;

  static Color textPrimary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextPrimary : lightTextPrimary;

  static Color textSecondary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextSecondary : lightTextSecondary;

  static Color textTertiary(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? darkTextTertiary : lightTextTertiary;

  // Legacy fallback static constants for dark theme default
  static const bgPrimary = darkBgDeep;
  static const bgSecondary = darkBgBase;
  static const bgSurface = darkSurfaceCard;
  static const bgElevated = darkSurfaceElev;
  static const borderSubtleStatic = darkBorderSubtle;
  static const borderMidStatic = darkBorderMid;

  static const accentGreenStatic = darkAccentGreen;
  static const accentGreenDimStatic = darkAccentGreenDim;
  static const accentRedStatic = darkAccentRed;
  static const accentOrangeStatic = darkAccentOrange;
  static const accentBlueStatic = darkAccentBlue;
  static const accentPurpleStatic = darkAccentPurple;

  static const textPrimaryStatic = darkTextPrimary;
  static const textSecondaryStatic = darkTextSecondary;
  static const textMutedStatic = darkTextTertiary;

  static Color scoreColor(double percent) {
    if (percent <= 10) return darkAccentGreen;
    if (percent <= 30) return darkAccentOrange;
    return darkAccentRed;
  }
}

class AppGradients {
  static const cyanGreen = LinearGradient(
    colors: [Color(0xFF00E5A0), Color(0xFF00B880)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const purpleCyan = LinearGradient(
    colors: [Color(0xFF8B5CF6), Color(0xFF00E5A0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkBgRadial = RadialGradient(
    center: Alignment(-0.8, -0.8),
    radius: 1.2,
    colors: [
      Color(0x2000E5A0),
      Color(0x108B5CF6),
      Color(0x00060610),
    ],
  );

  static const scoreGreen = LinearGradient(colors: [Color(0xFF00E5A0), Color(0xFF10B981)]);
  static const scoreOrange = LinearGradient(colors: [Color(0xFFFF8C42), Color(0xFFF59E0B)]);
  static const scoreRed = LinearGradient(colors: [Color(0xFFFF4D6A), Color(0xFFDC2626)]);
}

class AppRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const pill = 999.0;
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.darkBgBase,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.darkAccentGreen,
          secondary: AppColors.darkAccentPurple,
          surface: AppColors.darkSurfaceCard,
          error: AppColors.darkAccentRed,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          const TextTheme(
            headlineLarge: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5),
            headlineMedium: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600),
            titleMedium: TextStyle(
                color: AppColors.darkTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: AppColors.darkTextPrimary, fontSize: 14, height: 1.6),
            bodyMedium: TextStyle(color: AppColors.darkTextSecondary, fontSize: 13, height: 1.5),
            bodySmall: TextStyle(color: AppColors.darkTextTertiary, fontSize: 11),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.darkSurfaceElev,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.darkBorderMid),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.darkBorderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.darkAccentGreen, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.darkTextTertiary),
        ),
      );

  static ThemeData get light => ThemeData(
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.lightBgBase,
        fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
        colorScheme: const ColorScheme.light(
          primary: AppColors.lightAccentGreen,
          secondary: AppColors.lightAccentPurple,
          surface: AppColors.lightSurfaceCard,
          error: AppColors.lightAccentRed,
        ),
        textTheme: GoogleFonts.spaceGroteskTextTheme(
          const TextTheme(
            headlineLarge: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5),
            headlineMedium: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600),
            titleMedium: TextStyle(
                color: AppColors.lightTextPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w600),
            bodyLarge: TextStyle(color: AppColors.lightTextPrimary, fontSize: 14, height: 1.6),
            bodyMedium: TextStyle(color: AppColors.lightTextSecondary, fontSize: 13, height: 1.5),
            bodySmall: TextStyle(color: AppColors.lightTextTertiary, fontSize: 11),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.lightSurfaceElev,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightBorderMid),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightBorderSubtle),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.lightAccentGreen, width: 1.5),
          ),
          hintStyle: const TextStyle(color: AppColors.lightTextTertiary),
        ),
      );
}