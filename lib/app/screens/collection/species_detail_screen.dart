import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/butterfly_model.dart';
import '../../widgets/common/toxicity_badge.dart';

class SpeciesDetailScreen extends StatelessWidget {
  final ButterflyModel butterfly;
  const SpeciesDetailScreen({super.key, required this.butterfly});

  @override
  Widget build(BuildContext context) {
    final isToxic = butterfly.isToxic;
    final statusColor = isToxic ? AppColors.danger : AppColors.safe;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                    color: Colors.black45, shape: BoxShape.circle),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  butterfly.imageUrl != null && butterfly.imageUrl!.isNotEmpty
                      ? Image.network(
                          butterfly.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.surfaceLight,
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 120,
                                color: statusColor.withOpacity(0.5),
                              ),
                            );
                          },
                        )
                      : Container(
                          color: AppColors.surfaceLight,
                          child: Icon(
                            Icons.flutter_dash,
                            size: 120,
                            color: statusColor.withOpacity(0.5),
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                  if (butterfly.isCollected)
                    Positioned(
                      top: 56,
                      right: 20,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary.withOpacity(0.9),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.5),
                              blurRadius: 12,
                            )
                          ],
                        ),
                        child: const Icon(Icons.star_rounded,
                            color: Colors.white, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name & badge
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(butterfly.name,
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                )),
                            if (butterfly.scientificName.isNotEmpty)
                              Text(butterfly.scientificName,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textSecondary,
                                  )),
                          ],
                        ),
                      ),
                      ToxicityBadge(isToxic: isToxic, large: true),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Collected status
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: butterfly.isCollected
                          ? AppColors.primary.withOpacity(0.1)
                          : AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: butterfly.isCollected
                            ? AppColors.primary.withOpacity(0.4)
                            : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          butterfly.isCollected
                              ? Icons.star_rounded
                              : Icons.lock_outline_rounded,
                          color: butterfly.isCollected
                              ? AppColors.primary
                              : AppColors.textHint,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            butterfly.isCollected
                                ? 'Spesies ini sudah ada di koleksi Anda!'
                                : 'Scan spesies ini untuk menambahkan ke koleksi Anda',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: butterfly.isCollected
                                  ? AppColors.primary
                                  : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description
                  _buildSectionTitle('Deskripsi'),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Text(
                      butterfly.description,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.7,
                      ),
                    ),
                  ),

                  // === SARAN KESELAMATAN (hanya untuk yang beracun) ===
                  if (isToxic && butterfly.safetyAdvice != null) ...[
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.health_and_safety_rounded,
                            color: AppColors.danger, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Saran Keselamatan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.dangerLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: AppColors.danger.withOpacity(0.4)),
                      ),
                      child: Text(
                        butterfly.safetyAdvice!,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          height: 1.7,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24),

                  // Properties / Informasi detail
                  _buildSectionTitle('Informasi Spesies'),
                  const SizedBox(height: 8),
                  _buildInfoItem('Nama Ilmiah', butterfly.scientificName),
                  _buildInfoItem('Status Racun',
                      isToxic ? '⚠️ Beracun' : '✅ Tidak Beracun'),
                  if (butterfly.habitat != null)
                    _buildInfoItem('Habitat', butterfly.habitat!),
                  if (butterfly.distribution != null)
                    _buildInfoItem('Persebaran', butterfly.distribution!),
                  if (butterfly.wingSpan != null)
                    _buildInfoItem('Rentang Sayap', butterfly.wingSpan!),
                  if (butterfly.diet != null)
                    _buildInfoItem('Makanan', butterfly.diet!),
                  if (butterfly.toxinType != null)
                    _buildInfoItem('Jenis Racun', butterfly.toxinType!),
                  if (butterfly.conservationStatus != null)
                    _buildInfoItem(
                        'Status Konservasi', butterfly.conservationStatus!),
                  _buildInfoItem(
                    'Status Koleksi',
                    butterfly.isCollected
                        ? '⭐ Sudah ditemukan'
                        : '🔒 Belum ditemukan',
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
