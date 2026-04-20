import 'package:flutter/material.dart';

class AppColors {
  // Primary palette - soft pink / butterfly theme
  static const Color primary = Color(0xFFF48FB1); // Soft pink
  static const Color primaryDark = Color(0xFFEC407A); // Deeper pink
  static const Color secondary = Color(0xFFCE93D8); // Soft lavender/purple
  static const Color accent = Color(0xFFF8BBD0); // Blush pink

  // Backgrounds - dark with warm tint
  static const Color background = Color(0xFF1A1118); // Very dark purple-black
  static const Color surface = Color(0xFF251A22); // Dark berry
  static const Color surfaceLight = Color(0xFF342030); // Lighter berry
  static const Color card = Color(0xFF2E1E2B); // Card bg

  // Status colors
  static const Color danger = Color(0xFFFF6B9D); // Hot pink for toxic/danger
  static const Color dangerLight = Color(0x33FF6B9D);
  static const Color safe = Color(0xFFA5D6A7); // Soft green kept for "safe"
  static const Color safeLight = Color(0x33A5D6A7);
  static const Color warning = Color(0xFFFFCC80); // Soft amber
  static const Color warningLight = Color(0x33FFCC80);

  // Text
  static const Color textPrimary = Color(0xFFFCE4EC); // Very light pink white
  static const Color textSecondary = Color(0xFFBB8FA9); // Muted mauve
  static const Color textHint = Color(0xFF6D4C61); // Dark mauve

  // Border & Divider
  static const Color border = Color(0xFF4A2D42); // Muted berry border
  static const Color divider = Color(0xFF2E1E2B);

  // Glow colors
  static const Color glowPink = Color(0xFFF48FB1);
  static const Color glowLavender = Color(0xFFCE93D8);
  static const Color glowRed = Color(0xFFFF6B9D);
  // Keep alias for backward compat
  static const Color glowGreen = Color(0xFFA5D6A7);

  // Gradient pairs
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF6B9D), Color(0xFFE91E63)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF2E1E2B), Color(0xFF251A22)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF1A1118), Color(0xFF2A1528)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFFCE93D8), Color(0xFFAB47BC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
