import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/butterfly_model.dart';
import '../../theme/app_colors.dart';
import 'toxicity_badge.dart';

class ButterflyCard extends StatelessWidget {
  final ButterflyModel butterfly;
  final VoidCallback? onTap;
  final bool showCollected;

  const ButterflyCard({
    super.key,
    required this.butterfly,
    this.onTap,
    this.showCollected = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: butterfly.isCollected
                ? AppColors.primary.withOpacity(0.4)
                : AppColors.border,
          ),
          boxShadow: butterfly.isCollected
              ? [
                  BoxShadow(
                    color: AppColors.glowGreen.withOpacity(0.15),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image area
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    _buildImage(),
                    if (showCollected && butterfly.isCollected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.glowGreen.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                    if (!butterfly.isCollected && showCollected)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.35),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock_rounded,
                              color: Colors.white.withOpacity(0.5),
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Info area
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        butterfly.name,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: butterfly.isCollected
                              ? AppColors.textPrimary
                              : AppColors.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      ToxicityBadge(isToxic: butterfly.isToxic),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      color: AppColors.surfaceLight,
      child: Center(
        child: Icon(
          Icons.flutter_dash,
          size: 48,
          color: butterfly.isToxic
              ? AppColors.danger.withOpacity(0.6)
              : AppColors.primary.withOpacity(0.6),
        ),
      ),
    );
  }
}
