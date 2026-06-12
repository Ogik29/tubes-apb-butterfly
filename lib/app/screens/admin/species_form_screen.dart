import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/butterfly_model.dart';
import '../../widgets/common/custom_button.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../services/api_service.dart';

class SpeciesFormScreen extends StatefulWidget {
  final ButterflyModel? butterfly;
  const SpeciesFormScreen({super.key, this.butterfly});

  @override
  State<SpeciesFormScreen> createState() => _SpeciesFormScreenState();
}

class _SpeciesFormScreenState extends State<SpeciesFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _habitatController = TextEditingController();
  final _distributionController = TextEditingController();
  final _wingSpanController = TextEditingController();
  final _toxinTypeController = TextEditingController();
  final _safetyAdviceController = TextEditingController();
  final _conservationStatusController = TextEditingController();
  final _dietController = TextEditingController();
  bool _isToxic = false;
  bool _isLoading = false;

  bool get _isEditing => widget.butterfly != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      final b = widget.butterfly!;
      _nameController.text = b.name;
      _scientificNameController.text = b.scientificName;
      _descriptionController.text = b.description;
      _isToxic = b.isToxic;
      _habitatController.text = b.habitat ?? '';
      _distributionController.text = b.distribution ?? '';
      _wingSpanController.text = b.wingSpan ?? '';
      _toxinTypeController.text = b.toxinType ?? '';
      _safetyAdviceController.text = b.safetyAdvice ?? '';
      _conservationStatusController.text = b.conservationStatus ?? '';
      _dietController.text = b.diet ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _scientificNameController.dispose();
    _descriptionController.dispose();
    _habitatController.dispose();
    _distributionController.dispose();
    _wingSpanController.dispose();
    _toxinTypeController.dispose();
    _safetyAdviceController.dispose();
    _conservationStatusController.dispose();
    _dietController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final payload = {
        'name': _nameController.text.trim(),
        'scientific_name': _scientificNameController.text.trim(),
        'is_toxic': _isToxic,
        'description': _descriptionController.text.trim(),
        'habitat': _habitatController.text.trim().isEmpty ? null : _habitatController.text.trim(),
        'distribution': _distributionController.text.trim().isEmpty ? null : _distributionController.text.trim(),
        'wing_span': _wingSpanController.text.trim().isEmpty ? null : _wingSpanController.text.trim(),
        'toxin_type': _isToxic && _toxinTypeController.text.trim().isNotEmpty ? _toxinTypeController.text.trim() : null,
        'safety_advice': _isToxic && _safetyAdviceController.text.trim().isNotEmpty ? _safetyAdviceController.text.trim() : null,
        'conservation_status': _conservationStatusController.text.trim().isEmpty ? null : _conservationStatusController.text.trim(),
        'diet': _dietController.text.trim().isEmpty ? null : _dietController.text.trim(),
      };

      try {
        if (_isEditing) {
          await ApiService.updateButterfly(widget.butterfly!.id, payload);
        } else {
          await ApiService.addButterfly(payload);
        }
        
        if (mounted) {
          setState(() => _isLoading = false);
          Navigator.pop(context, true); // return true to trigger refresh in admin panel list
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _isEditing
                    ? 'Spesies berhasil diperbarui!'
                    : 'Spesies baru berhasil ditambahkan!',
                style: GoogleFonts.poppins(),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Spesies' : 'Tambah Spesies'),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image placeholder
                Center(
                  child: GestureDetector(
                    onTap: () {}, // TODO: image picker
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.4),
                            width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.15),
                            blurRadius: 16,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.add_photo_alternate_rounded,
                              size: 36, color: AppColors.primary),
                          const SizedBox(height: 4),
                          Text('Upload\nGambar',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: AppColors.textSecondary)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                // Toxic toggle
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _isToxic
                          ? AppColors.danger.withOpacity(0.4)
                          : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: (_isToxic ? AppColors.danger : AppColors.safe)
                              .withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isToxic
                              ? Icons.warning_rounded
                              : Icons.check_circle_rounded,
                          color: _isToxic ? AppColors.danger : AppColors.safe,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isToxic ? 'Beracun' : 'Tidak Beracun',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: _isToxic
                                    ? AppColors.danger
                                    : AppColors.safe,
                              ),
                            ),
                            Text(
                              'Toggle untuk mengubah status racun',
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _isToxic,
                        onChanged: (v) => setState(() => _isToxic = v),
                        activeThumbColor: AppColors.danger,
                        inactiveThumbColor: AppColors.safe,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Name field
                CustomTextField(
                  label: 'Nama Spesies',
                  hint: 'Contoh: Monarch Butterfly',
                  controller: _nameController,
                  prefixIcon: Icons.flutter_dash,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return 'Nama spesies wajib diisi';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Scientific name
                CustomTextField(
                  label: 'Nama Ilmiah',
                  hint: 'Contoh: Danaus plexippus',
                  controller: _scientificNameController,
                  prefixIcon: Icons.science_rounded,
                ),
                const SizedBox(height: 20),
                // Deskripsi
                CustomTextField(
                  label: 'Deskripsi Tambahan',
                  hint: 'Masukkan deskripsi spesies...',
                  controller: _descriptionController,
                  prefixIcon: Icons.description_rounded,
                  maxLines: 4,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Deskripsi wajib diisi';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                // Habitat
                CustomTextField(
                  label: 'Habitat',
                  hint: 'Contoh: Hutan Hujan Tropis',
                  controller: _habitatController,
                  prefixIcon: Icons.landscape_rounded,
                ),
                const SizedBox(height: 20),
                // Distribution
                CustomTextField(
                  label: 'Persebaran',
                  hint: 'Contoh: Asia Tenggara',
                  controller: _distributionController,
                  prefixIcon: Icons.map_rounded,
                ),
                const SizedBox(height: 20),
                // Wing Span
                CustomTextField(
                  label: 'Rentang Sayap',
                  hint: 'Contoh: 8-12 cm',
                  controller: _wingSpanController,
                  prefixIcon: Icons.straighten_rounded,
                ),
                const SizedBox(height: 20),
                // Diet
                CustomTextField(
                  label: 'Makanan',
                  hint: 'Contoh: Nektar bunga',
                  controller: _dietController,
                  prefixIcon: Icons.restaurant_rounded,
                ),
                const SizedBox(height: 20),
                // Conservation Status
                CustomTextField(
                  label: 'Status Konservasi',
                  hint: 'Contoh: Least Concern (LC)',
                  controller: _conservationStatusController,
                  prefixIcon: Icons.eco_rounded,
                ),
                const SizedBox(height: 20),

                // === Conditionally Rendered Toxin Info ===
                if (_isToxic) ...[
                  const Divider(color: AppColors.border),
                  const SizedBox(height: 16),
                  Text(
                    'Informasi Racun & Keselamatan',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.danger,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Jenis Racun',
                    hint: 'Contoh: Cyanogenic glycosides',
                    controller: _toxinTypeController,
                    prefixIcon: Icons.science_rounded,
                  ),
                  const SizedBox(height: 20),
                  CustomTextField(
                    label: 'Saran Keselamatan',
                    hint: 'Contoh: Segera cuci tangan setelah menyentuh...',
                    controller: _safetyAdviceController,
                    prefixIcon: Icons.health_and_safety_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 12),
                CustomButton(
                  text: _isEditing ? 'Simpan Perubahan' : 'Tambahkan Spesies',
                  icon: _isEditing ? Icons.save_rounded : Icons.add_rounded,
                  isLoading: _isLoading,
                  onPressed: _handleSubmit,
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Batal',
                  isOutlined: true,
                  color: AppColors.textHint,
                  onPressed: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
