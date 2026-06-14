import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/scan_result_model.dart';
import '../../models/butterfly_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/toxicity_badge.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class ResultScreen extends StatefulWidget {
  final ScanResultModel? result;
  const ResultScreen({super.key, this.result});

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;
  late Animation<double> _confidenceAnim;
  late Animation<double> _iconPulse;
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isSaved = widget.result?.isSaved ?? false;
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _fadeIn =
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut);
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _entranceController, curve: Curves.easeOut));
    _confidenceAnim = Tween<double>(
      begin: 0,
      end: widget.result?.confidence ?? 0.85,
    ).animate(CurvedAnimation(
      parent: _entranceController,
      curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
    ));
    _iconPulse = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _entranceController.forward();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  ScanResultModel get _result =>
      widget.result ??
      ScanResultModel(
        imagePath: '',
        predictedSpecies: 'Monarch Butterfly',
        isToxic: true,
        confidence: 0.947,
        scannedAt: DateTime.now(),
      );

  ButterflyModel? get _butterlyInfo {
    try {
      return sampleButterflies
          .firstWhere((b) => b.name == _result.predictedSpecies);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isToxic = _result.isToxic;
    final statusColor = isToxic ? AppColors.danger : AppColors.safe;
    final statusGradient =
        isToxic ? AppColors.dangerGradient : AppColors.primaryGradient;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header image area
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.background,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.black45,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    size: 16, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: Colors.black45,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share_rounded,
                      size: 16, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroImage(statusColor, statusGradient, isToxic),
            ),
          ),
          // Result content
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SlideTransition(
                position: _slideUp,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Result card
                      _buildResultCard(isToxic, statusColor),
                      const SizedBox(height: 20),
                      // Confidence
                      _buildConfidenceCard(),
                      const SizedBox(height: 20),
                      // Species info
                      if (_butterlyInfo != null) ...[
                        _buildSpeciesInfo(),
                        const SizedBox(height: 20),
                      ],
                      // Warning (if toxic)
                      if (isToxic) ...[
                        _buildWarningCard(),
                        const SizedBox(height: 20),
                      ],
                      // Scan meta
                      _buildScanMeta(),
                      const SizedBox(height: 24),
                      // Action buttons
                      _buildActions(context),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroImage(Color statusColor, Gradient gradient, bool isToxic) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Background
        Container(
          decoration: BoxDecoration(
            gradient: gradient,
          ),
          child: Opacity(
            opacity: 0.15,
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
              ),
            ),
          ),
        ),
        // Image or icon
        _result.imagePath.isNotEmpty
            ? (_result.imagePath.startsWith('http')
                ? Image.network(
                    _result.imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          size: 64,
                          color: statusColor,
                        ),
                      );
                    },
                  )
                : Image.file(
                    File(_result.imagePath),
                    fit: BoxFit.cover,
                  ))
            : Center(
                child: AnimatedBuilder(
                  animation: _iconPulse,
                  builder: (context, child) => Transform.scale(
                    scale: _iconPulse.value,
                    child: child,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: statusColor.withOpacity(0.15),
                      boxShadow: [
                        BoxShadow(
                          color: statusColor.withOpacity(0.4),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.flutter_dash,
                      size: 80,
                      color: statusColor,
                    ),
                  ),
                ),
              ),
        // Overlay gradient
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
        // Status ribbon
        Positioned(
          bottom: 20,
          left: 20,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.4),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isToxic ? Icons.warning_rounded : Icons.verified_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  isToxic ? 'BERACUN' : 'TIDAK BERACUN',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultCard(bool isToxic, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: statusColor.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hasil Identifikasi',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _result.predictedSpecies,
            style: GoogleFonts.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          if (_butterlyInfo != null) ...[
            const SizedBox(height: 4),
            Text(
              _butterlyInfo!.scientificName,
              style: GoogleFonts.poppins(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 14),
          ToxicityBadge(isToxic: isToxic, large: true),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tingkat Keyakinan Model',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          AnimatedBuilder(
            animation: _confidenceAnim,
            builder: (context, child) {
              final confidence = _confidenceAnim.value;
              Color barColor;
              if (confidence >= 0.8) {
                barColor = AppColors.primary;
              } else if (confidence >= 0.6) {
                barColor = AppColors.accent;
              } else {
                barColor = AppColors.danger;
              }

              return Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${(confidence * 100).toStringAsFixed(1)}%',
                        style: GoogleFonts.poppins(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: barColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: barColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          confidence >= 0.8
                              ? 'Sangat Yakin'
                              : confidence >= 0.6
                                  ? 'Cukup Yakin'
                                  : 'Kurang Yakin',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: barColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: confidence,
                      backgroundColor: AppColors.surfaceLight,
                      valueColor: AlwaysStoppedAnimation<Color>(barColor),
                      minHeight: 10,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpeciesInfo() {
    final butterfly = _butterlyInfo!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline,
                  color: AppColors.secondary, size: 18),
              const SizedBox(width: 8),
              Text(
                'Informasi Spesies',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            butterfly.description,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.danger.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.danger, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERINGATAN BAHAYA',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.danger,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kupu-kupu ini berpotensi beracun. Hindari kontak langsung dan jangan menyentuh tanpa perlindungan.',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: AppColors.danger.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanMeta() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time_rounded,
              color: AppColors.textHint, size: 16),
          const SizedBox(width: 8),
          Text(
            'Discan pada: ${DateFormat('dd MMMM yyyy, HH:mm').format(_result.scannedAt)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final canSave = _result.id != null && !_isSaved;

    return Column(
      children: [
        CustomButton(
          text: _isSaved ? 'Tersimpan ke Koleksi ✓' : 'Simpan ke Koleksi',
          icon: _isSaved ? Icons.check_rounded : Icons.save_rounded,
          color: _isSaved ? AppColors.primaryDark : null,
          isLoading: _isSaving,
          onPressed: canSave
              ? () async {
                  setState(() => _isSaving = true);
                  try {
                    await ApiService.saveScan(_result.id!);
                    setState(() {
                      _isSaved = true;
                      _isSaving = false;
                    });
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Hasil scan berhasil disimpan ke koleksi!',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.primary,
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  } catch (e) {
                    setState(() => _isSaving = false);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            e.toString().replaceAll('Exception: ', ''),
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  }
                }
              : null,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Kembali ke Dashboard',
          isOutlined: true,
          color: AppColors.textHint,
          onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context, '/dashboard', (r) => false),
        ),
      ],
    );
  }
}
