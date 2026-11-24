import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';
import 'widgets/night_sky.dart';

/// belle.fyi's look: Lora for headings and names, Figtree for the text, both
/// on the night sky.
class AppTheme {
  static TextStyle display({
    double? fontSize,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.cream,
  }) =>
      GoogleFonts.lora(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static TextStyle body({
    double? fontSize,
    FontWeight? fontWeight,
    Color color = AppColors.text,
  }) =>
      GoogleFonts.figtree(fontSize: fontSize, fontWeight: fontWeight, color: color);

  static ThemeData get theme {
    final bodyTextTheme = GoogleFonts.figtreeTextTheme(
      ThemeData.dark().textTheme,
    ).apply(bodyColor: AppColors.text, displayColor: AppColors.cream);

    TextStyle? heading(TextStyle? base) => base?.merge(display());

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      // Every page paints its own night sky (see NightSky), so pages stay
      // see-through and the stars show behind them.
      scaffoldBackgroundColor: Colors.transparent,
      pageTransitionsTheme: PageTransitionsTheme(
        builders: {
          for (final platform in TargetPlatform.values)
            platform: const NightSkyPageTransitionsBuilder(),
        },
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.periwinkle,
        onPrimary: AppColors.onPeriwinkle,
        secondary: AppColors.lilac,
        onSecondary: AppColors.night,
        surface: AppColors.navy,
        onSurface: AppColors.text,
        outline: AppColors.border,
        error: AppColors.rose,
      ),
      textTheme: bodyTextTheme.copyWith(
        displayLarge: heading(bodyTextTheme.displayLarge),
        displayMedium: heading(bodyTextTheme.displayMedium),
        displaySmall: heading(bodyTextTheme.displaySmall),
        headlineLarge: heading(bodyTextTheme.headlineLarge),
        headlineMedium: heading(bodyTextTheme.headlineMedium),
        headlineSmall: heading(bodyTextTheme.headlineSmall),
        titleLarge: heading(bodyTextTheme.titleLarge),
        bodyLarge: bodyTextTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.45),
        bodyMedium: bodyTextTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.45),
        bodySmall: bodyTextTheme.bodySmall?.copyWith(color: AppColors.muted),
        labelLarge: bodyTextTheme.labelLarge?.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: AppColors.cream,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: display(fontSize: 24),
      ),
      iconTheme: const IconThemeData(color: AppColors.periwinkle),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.periwinkle,
        linearTrackColor: AppColors.border,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.periwinkle,
        selectionColor: AppColors.periwinkle.withValues(alpha: 0.3),
        selectionHandleColor: AppColors.periwinkle,
      ),
      tooltipTheme: TooltipThemeData(
        textStyle: body(fontSize: 12, color: AppColors.cream),
        decoration: BoxDecoration(
          color: AppColors.navy,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.border),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        labelStyle: body(fontSize: 13),
        side: const BorderSide(color: AppColors.border),
        shape: const StadiumBorder(),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.periwinkle,
          foregroundColor: AppColors.onPeriwinkle,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.muted,
          elevation: 0,
          textStyle: body(fontSize: 16, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.periwinkle,
          backgroundColor: AppColors.raised,
          side: const BorderSide(color: AppColors.border),
          textStyle: body(fontSize: 16, fontWeight: FontWeight.w500),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.muted,
          textStyle: body(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: AppColors.cream,
        unselectedLabelColor: AppColors.muted,
        indicatorColor: AppColors.lilac,
        dividerColor: AppColors.border,
        overlayColor: WidgetStatePropertyAll(AppColors.raised),
      ),
    );
  }
}
