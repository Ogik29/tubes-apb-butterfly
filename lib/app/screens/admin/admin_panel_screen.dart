import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/butterfly_model.dart';
import '../../widgets/common/toxicity_badge.dart';
import '../../services/api_service.dart';
import '../../../main.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  List<ButterflyModel> _species = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSpecies();
  }

  Future<void> _fetchSpecies() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final list = await ApiService.getButterflies();
      setState(() {
        _species = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  List<ButterflyModel> get _filteredSpecies {
    if (_searchQuery.isEmpty) return _species;
    return _species
        .where((b) =>
            b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            b.scientificName.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Admin Panel'),
        backgroundColor: AppColors.background,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.danger),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            '/species-form',
          );
          if (result != null) {
            _fetchSpecies();
          }
        },
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text('Tambah Spesies', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Stats bar
            _buildStatsBar(),
            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: _searchController,
                style: GoogleFonts.poppins(
                    fontSize: 13, color: AppColors.textPrimary),
                onChanged: (v) => setState(() => _searchQuery = v),
                decoration: InputDecoration(
                  hintText: 'Cari spesies...',
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AppColors.textHint, size: 20),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded,
                              color: AppColors.textHint, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Row(
                children: [
                  Text(
                    '${_filteredSpecies.length} spesies',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // List
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded, color: AppColors.danger, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchSpecies,
                                  child: Text('Coba Lagi', style: GoogleFonts.poppins()),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchSpecies,
                          child: _filteredSpecies.isEmpty
                              ? ListView(
                                  children: [
                                    const SizedBox(height: 100),
                                    _buildEmptyState(),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                                  itemCount: _filteredSpecies.length,
                                  itemBuilder: (ctx, i) =>
                                      _buildSpeciesItem(ctx, _filteredSpecies[i]),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final toxicCount = _species.where((b) => b.isToxic).length;
    final safeCount = _species.length - toxicCount;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          _buildStatItem('${_species.length}', 'Total Spesies', AppColors.primary),
          _buildDivider(),
          _buildStatItem('$toxicCount', 'Beracun', AppColors.danger),
          _buildDivider(),
          _buildStatItem('$safeCount', 'Tidak Beracun', AppColors.safe),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.w700, color: color)),
          Text(label,
              style: GoogleFonts.poppins(
                  fontSize: 11, color: AppColors.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.border,
      margin: const EdgeInsets.symmetric(horizontal: 8),
    );
  }

  Widget _buildSpeciesItem(BuildContext context, ButterflyModel butterfly) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            color: (butterfly.isToxic ? AppColors.danger : AppColors.safe)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: (butterfly.isToxic ? AppColors.danger : AppColors.safe)
                  .withOpacity(0.3),
            ),
          ),
          child: Icon(
            Icons.flutter_dash,
            color:
                butterfly.isToxic ? AppColors.danger : AppColors.safe,
            size: 28,
          ),
        ),
        title: Text(
          butterfly.name,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              butterfly.scientificName,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            ToxicityBadge(isToxic: butterfly.isToxic),
          ],
        ),
        trailing: PopupMenuButton<String>(
          color: AppColors.surface,
          icon: const Icon(Icons.more_vert_rounded, color: AppColors.textHint),
          onSelected: (action) async {
            if (action == 'edit') {
              final result = await Navigator.pushNamed(
                context,
                '/species-form',
                arguments: butterfly,
              );
              if (result != null) {
                _fetchSpecies();
              }
            } else if (action == 'delete') {
              _showDeleteDialog(context, butterfly);
            }
          },
          itemBuilder: (ctx) => [
            PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  const Icon(Icons.edit_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 8),
                  Text('Edit',
                      style: GoogleFonts.poppins(
                          color: AppColors.textPrimary, fontSize: 13)),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  const Icon(Icons.delete_rounded,
                      color: AppColors.danger, size: 18),
                  const SizedBox(width: 8),
                  Text('Hapus',
                      style: GoogleFonts.poppins(
                          color: AppColors.danger, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded,
              size: 60, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Spesies tidak ditemukan',
            style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ButterflyModel butterfly) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Hapus Spesies',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${butterfly.name}" dari data master?',
          style: GoogleFonts.poppins(
              color: AppColors.textSecondary, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await ApiService.deleteButterfly(butterfly.id);
                setState(() {
                  _species.removeWhere((b) => b.id == butterfly.id);
                });
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${butterfly.name} telah dihapus',
                          style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menghapus: $e',
                          style: GoogleFonts.poppins()),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Hapus', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Keluar',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        content: Text('Apakah Anda yakin ingin keluar?',
            style: GoogleFonts.poppins(
                color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.poppins(color: AppColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.logout();
              if (context.mounted) {
                AppState.of(context)?.setUser(name: 'Pengguna', isAdmin: false);
                Navigator.pushNamedAndRemoveUntil(
                    context, '/login', (r) => false);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: Text('Keluar', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }
}
