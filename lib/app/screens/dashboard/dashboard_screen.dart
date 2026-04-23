import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/scan_result_model.dart';
import '../../models/butterfly_model.dart';
import '../../widgets/common/toxicity_badge.dart';
import '../../../main.dart';
import '../scan/scan_screen.dart';
import '../history/history_screen.dart';
import '../collection/collection_screen.dart';
import '../admin/admin_panel_screen.dart';
import 'package:intl/intl.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    final isAdmin = appState?.isAdmin ?? false;

    // Halaman nyata langsung di-embed di tab
    final pages = isAdmin
        ? <Widget>[
            _HomeTab(isAdmin: isAdmin),
            const AdminPanelScreen(),
          ]
        : <Widget>[
            _HomeTab(isAdmin: isAdmin),
            const ScanScreen(),
            const HistoryScreen(),
            const CollectionScreen(),
          ];

    final navItems = isAdmin
        ? const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.admin_panel_settings_rounded),
              label: 'Admin',
            ),
          ]
        : const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.camera_rounded),
              label: 'Scan',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'Riwayat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.collections_bookmark_rounded),
              label: 'Koleksi',
            ),
          ];

    return Scaffold(
      backgroundColor: AppColors.background,
      // IndexedStack menjaga state tiap tab (tidak rebuild saat pindah tab)
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          items: navItems,
        ),
      ),
    );
  }
}

// ---------- HOME TAB ----------
class _HomeTab extends StatelessWidget {
  final bool isAdmin;
  const _HomeTab({required this.isAdmin});

  @override
  Widget build(BuildContext context) {
    final appState = AppState.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, appState),
            const SizedBox(height: 24),
            if (!isAdmin) _buildStatsRow(),
            if (!isAdmin) const SizedBox(height: 24),
            _buildQuickAccessGrid(context, isAdmin),
            const SizedBox(height: 28),
            if (!isAdmin) ...[
              _buildSectionTitle('Scan Terakhir'),
              const SizedBox(height: 12),
              _buildRecentScans(context),
            ],
            if (isAdmin) ...[
              _buildSectionTitle('Ringkasan Admin'),
              const SizedBox(height: 12),
              _buildAdminSummary(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppState? appState) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Woi, ${appState?.userName ?? "Pengguna"} 👋',
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                isAdmin
                    ? 'Panel Admin Aktif'
                    : 'Selamat datang di Kupu-Kupu Asik',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: AppColors.surface,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                title: Text('Keluar',
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary)),
                content: Text('Apakah Anda yakin ingin keluar?',
                    style: GoogleFonts.poppins(
                        color: AppColors.textSecondary, fontSize: 13)),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text('Batal',
                        style: GoogleFonts.poppins(
                            color: AppColors.textSecondary)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx); // Tutup dialog
                      Navigator.pushNamedAndRemoveUntil(
                          context, '/login', (route) => false);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.danger),
                    child: Text('Keluar', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 12,
                ),
              ],
            ),
            child:
                const Icon(Icons.logout_rounded, color: Colors.white, size: 22),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    // Hitung data dinamis dari sample data
    final totalScan = sampleScanHistory.length;
    final safeButterflies =
        sampleButterflies.where((b) => b.isCollected && !b.isToxic).length;
    final toxicFound =
        sampleButterflies.where((b) => b.isCollected && b.isToxic).length;
    final collectedCount = sampleButterflies.where((b) => b.isCollected).length;
    final totalCount = sampleButterflies.length;

    // Rata-rata confidence dari semua scan yang tersimpan
    final savedScans = sampleScanHistory.where((s) => s.isSaved).toList();
    final avgConfidence = savedScans.isEmpty
        ? 0.0
        : savedScans.map((s) => s.confidence).reduce((a, b) => a + b) /
            savedScans.length;

    return Column(
      children: [
        Row(
          children: [
            _buildStatCard('$totalScan', 'Total Scan', Icons.camera_alt_rounded,
                AppColors.secondary),
            const SizedBox(width: 12),
            _buildStatCard('$safeButterflies', 'Kupu-Kupu\nAman',
                Icons.flutter_dash, AppColors.safe),
            const SizedBox(width: 12),
            _buildStatCard('$toxicFound', 'Kupu-Kupu\nBeracun',
                Icons.warning_rounded, AppColors.danger),
          ],
        ),
        const SizedBox(height: 12),
        // Card rata-rata keyakinan berdasar koleksi user
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.analytics_rounded,
                    color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rata-rata \nKeyakinan Model',
                      style: GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textSecondary, height: 1.2),
                    ),
                    Text(
                      '${(avgConfidence * 100).toStringAsFixed(1)}%',
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$collectedCount/$totalCount spesies',
                    style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    'terkoleksi',
                    style: GoogleFonts.poppins(
                        fontSize: 11, color: AppColors.textHint),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(
                  fontSize: 10, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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

  Widget _buildQuickAccessGrid(BuildContext context, bool isAdmin) {
    final items = isAdmin
        ? [
            _QuickItem('Data Spesies', Icons.bug_report_rounded,
                AppColors.primary, '/admin'),
            _QuickItem('Tambah Spesies', Icons.add_circle_rounded,
                AppColors.secondary, '/species-form'),
          ]
        : [
            _QuickItem('Scan Kupu-Kupu', Icons.camera_rounded,
                AppColors.primary, '/scan'),
            _QuickItem('Riwayat Scan', Icons.history_rounded,
                AppColors.secondary, '/history'),
            _QuickItem('Koleksi Saya', Icons.collections_bookmark_rounded,
                AppColors.accent, '/collection'),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Akses Cepat'),
        const SizedBox(height: 12),
        Row(
          children: items
              .map((item) => Expanded(
                    child: Padding(
                      padding:
                          EdgeInsets.only(right: item != items.last ? 12 : 0),
                      child: _buildQuickCard(context, item),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildQuickCard(BuildContext context, _QuickItem item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item.route),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              item.color.withOpacity(0.15),
              item.color.withOpacity(0.05)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: item.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color, size: 26),
            ),
            const SizedBox(height: 10),
            Text(
              item.label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentScans(BuildContext context) {
    final recent = sampleScanHistory.take(3).toList();
    return Column(
      children: recent.map((scan) => _buildScanItem(context, scan)).toList(),
    );
  }

  Widget _buildScanItem(BuildContext context, ScanResultModel scan) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/result', arguments: scan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.flutter_dash,
                color: scan.isToxic ? AppColors.danger : AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.predictedSpecies,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(scan.scannedAt),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ToxicityBadge(isToxic: scan.isToxic),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminSummary() {
    return Row(
      children: [
        _buildAdminStatCard('8', 'Spesies\nTerdaftar', Icons.bug_report_rounded,
            AppColors.primary),
        const SizedBox(width: 12),
        _buildAdminStatCard('5', 'Scan\nTotal User', Icons.camera_alt_rounded,
            AppColors.secondary),
        const SizedBox(width: 12),
        _buildAdminStatCard(
            '4', 'User\nAktif', Icons.people_rounded, AppColors.accent),
      ],
    );
  }

  Widget _buildAdminStatCard(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(value,
                style: GoogleFonts.poppins(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 10, color: AppColors.textSecondary),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _QuickItem {
  final String label;
  final IconData icon;
  final Color color;
  final String route;
  _QuickItem(this.label, this.icon, this.color, this.route);
}
