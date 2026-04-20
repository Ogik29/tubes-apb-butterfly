import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';

class ToxicityBadge extends StatelessWidget {
  final bool isToxic;
  final bool large;

  const ToxicityBadge({super.key, required this.isToxic, this.large = false});

  @override
  Widget build(BuildContext context) {
    final color = isToxic ? AppColors.danger : AppColors.safe;
    final bgColor = isToxic ? AppColors.dangerLight : AppColors.safeLight;
    final text = isToxic ? 'BERACUN' : 'AMAN';
    final icon = isToxic ? Icons.warning_rounded : Icons.check_circle_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 16 : 10,
        vertical: large ? 8 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(large ? 12 : 8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: large ? 20 : 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.poppins(
              fontSize: large ? 14 : 11,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class ConfidenceBar extends StatelessWidget {
  final double confidence; // 0.0 to 1.0
  final bool showLabel;

  const ConfidenceBar({
    super.key,
    required this.confidence,
    this.showLabel = true,
  });

  Color get _barColor {
    if (confidence >= 0.8) return AppColors.primary;
    if (confidence >= 0.6) return AppColors.accent;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showLabel)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tingkat Keyakinan',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                '${(confidence * 100).toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _barColor,
                ),
              ),
            ],
          ),
        if (showLabel) const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: confidence,
            backgroundColor: AppColors.surfaceLight,
            valueColor: AlwaysStoppedAnimation<Color>(_barColor),
            minHeight: 8,
          ),
        ),
      ],
    );
  }
}

class CollectedBadge extends StatelessWidget {
  const CollectedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.glowGreen.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
          const SizedBox(width: 3),
          Text(
            'Ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
