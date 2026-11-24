import 'package:flutter/material.dart';

/// Cuiviénen Night, the palette of belle.fyi and tide-tracker: cream and
/// lilac stars on navy, with periwinkle for what you act on.
class AppColors {
  /// Behind everything: the night sky.
  static const Color night = Color(0xFF141A29);

  /// Panels and cards sitting on the sky.
  static const Color navy = Color(0xFF181F30);

  /// Hairline borders and empty tracks.
  static const Color border = Color(0xFF232C44);

  /// A faint lift over navy, for inputs and pressed states.
  static const Color raised = Color(0x0FFFFFFF);

  /// The white margin of the Major Arcana scans, filling the gap where a
  /// scan is shorter than a whole card.
  static const Color cardMargin = Color(0xFFFFFFFF);

  /// Body text.
  static const Color text = Color(0xFFC8CDE0);

  /// Secondary text, labels and hints.
  static const Color muted = Color(0xFF7C86A3);

  /// What you act on: buttons, the selected tab, focus.
  static const Color periwinkle = Color(0xFF9FA6CE);

  /// Text and icons on periwinkle.
  static const Color onPeriwinkle = night;

  /// Sparkles and their glow.
  static const Color lilac = Color(0xFFD0C0E6);

  /// Headings, card names and the stars themselves.
  static const Color cream = Color(0xFFEAE0CF);

  /// A correct answer.
  static const Color teal = Color(0xFF8FD0CC);

  /// A wrong answer.
  static const Color rose = Color(0xFFE07A7A);
}
