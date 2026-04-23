import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_colors.dart';
import '../../models/scan_result_model.dart';
import '../../widgets/common/custom_button.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 85,
      maxWidth: 1024,
    );
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() => _isAnalyzing = true);

    // Simulate AI analysis delay
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      setState(() => _isAnalyzing = false);
      // Generate mock result
      final rand = Random();
      final isToxic = rand.nextBool();
      final confidence = 0.6 + rand.nextDouble() * 0.39;
      final species = isToxic
          ? ['Monarch Butterfly', 'Pipevine Swallowtail', 'Zebra Longwing'][rand.nextInt(3)]
          : ['Blue Morpho', 'Swallowtail Butterfly', 'Painted Lady'][rand.nextInt(3)];

      final result = ScanResultModel(
        imagePath: _selectedImage!.path,
        predictedSpecies: species,
        isToxic: isToxic,
        confidence: confidence,
        scannedAt: DateTime.now(),
      );

      Navigator.pushNamed(context, '/result', arguments: result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Scan Kupu-Kupu'),
        backgroundColor: AppColors.background,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Image preview area
              _buildImageArea(),
              const SizedBox(height: 28),
              // Instruction
              if (_selectedImage == null) _buildInstruction(),
              // Action buttons
              if (_selectedImage == null) ...[
                const SizedBox(height: 24),
                _buildSourceButtons(),
              ],
              if (_selectedImage != null) ...[
                const SizedBox(height: 20),
                _buildAnalyzeSection(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageArea() {
    return Container(
        width: double.infinity,
        height: 280,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedImage != null
                ? AppColors.primary.withOpacity(0.6)
                : AppColors.border,
            width: 2,
          ),
          boxShadow: _selectedImage != null
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    Image.file(
                      _selectedImage!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                    if (_isAnalyzing)
                      Container(
                        color: Colors.black.withOpacity(0.6),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(
                                color: AppColors.primary,
                                strokeWidth: 3,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Menganalisis gambar...',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'Model CNN sedang bekerja',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Remove button
                    if (!_isAnalyzing)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close_rounded,
                                color: Colors.white, size: 18),
                          ),
                        ),
                      ),
                  ],
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.add_photo_alternate_rounded,
                        size: 52,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih atau ambil foto kupu-kupu',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kualitas gambar mempengaruhi akurasi',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
        ),
      );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_rounded,
                  color: AppColors.accent, size: 18),
              const SizedBox(width: 8),
              Text(
                'Tips untuk hasil terbaik:',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[
            'Pastikan kupu-kupu terlihat jelas di foto',
            'Gunakan pencahayaan yang cukup',
            'Fokus pada sayap dan pola warnanya',
            'Hindari foto yang buram atau terpotong',
          ].map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSourceButtons() {
    return Row(
      children: [
        Expanded(
          child: CustomButton(
            text: 'Buka Kamera',
            icon: Icons.camera_alt_rounded,
            onPressed: () => _pickImage(ImageSource.camera),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CustomButton(
            text: 'Dari Galeri',
            icon: Icons.photo_library_rounded,
            isOutlined: true,
            onPressed: () => _pickImage(ImageSource.gallery),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzeSection() {
    return Column(
      children: [
        CustomButton(
          text: _isAnalyzing ? 'Menganalisis...' : 'Analisis dengan CNN',
          icon: Icons.biotech_rounded,
          isLoading: _isAnalyzing,
          onPressed: _analyzeImage,
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Ganti Gambar',
          icon: Icons.refresh_rounded,
          isOutlined: true,
          onPressed: _isAnalyzing
              ? null
              : () => setState(() => _selectedImage = null),
        ),
      ],
    );
  }
}
