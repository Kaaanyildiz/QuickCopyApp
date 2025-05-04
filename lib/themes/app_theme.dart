import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

class AppTheme {
  // Light tema
  static ThemeData light() {
    final baseTheme = FlexThemeData.light(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 9,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 10,
        blendOnColors: false,
        cardRadius: 12.0,
        inputDecoratorRadius: 10.0,
        dialogRadius: 16.0,
        bottomSheetRadius: 24.0,
        elevatedButtonRadius: 10.0,
        textButtonRadius: 8.0,
        toggleButtonsRadius: 10.0,
        chipRadius: 8.0,
        fabRadius: 16.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.nunitoSansTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.nunitoSansTextTheme(baseTheme.primaryTextTheme),
    );
  }

  // Dark tema
  static ThemeData dark() {
    final baseTheme = FlexThemeData.dark(
      scheme: FlexScheme.blue,
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 15,
      subThemesData: const FlexSubThemesData(
        blendOnLevel: 20,
        blendOnColors: false,
        cardRadius: 12.0,
        inputDecoratorRadius: 10.0,
        dialogRadius: 16.0,
        bottomSheetRadius: 24.0,
        elevatedButtonRadius: 10.0,
        textButtonRadius: 8.0,
        toggleButtonsRadius: 10.0,
        chipRadius: 8.0,
        fabRadius: 16.0,
      ),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
    );

    return baseTheme.copyWith(
      textTheme: GoogleFonts.nunitoSansTextTheme(baseTheme.textTheme),
      primaryTextTheme: GoogleFonts.nunitoSansTextTheme(baseTheme.primaryTextTheme),
    );
  }
}