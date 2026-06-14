import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/scan_result_model.dart';
import '../../widgets/common/toxicity_badge.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filter = 'all'; // all, toxic, safe, saved
  List<ScanResultModel> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final list = await ApiService.getHistory();
      setState(() {
        _history = list;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteItem(int id, int index) async {
    try {
      await ApiService.deleteHistory(id);
      setState(() {
        _history.removeWhere((item) => item.id == id);
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Riwayat berhasil dihapus', style: GoogleFonts.poppins()),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus riwayat: $e',
                style: GoogleFonts.poppins()),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      _fetchHistory();
    }
  }

  List<ScanResultModel> get _filteredList {
    switch (_filter) {
      case 'toxic':
        return _history.where((s) => s.isToxic).toList();
      case 'safe':
        return _history.where((s) => !s.isToxic).toList();
      case 'saved':
        return _history.where((s) => s.isSaved).toList();
      default:
        return _history;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Riwayat Scan'),
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
            icon: const Icon(Icons.filter_list_rounded,
                color: AppColors.textSecondary),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(),
            _buildStatsRow(),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child:
                          CircularProgressIndicator(color: AppColors.primary),
                    )
                  : _errorMessage != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.error_outline_rounded,
                                    color: AppColors.danger, size: 48),
                                const SizedBox(height: 12),
                                Text(
                                  _errorMessage!,
                                  style: GoogleFonts.poppins(
                                      color: AppColors.textSecondary),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _fetchHistory,
                                  child: Text('Coba Lagi',
                                      style: GoogleFonts.poppins()),
                                ),
                              ],
                            ),
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchHistory,
                          child: _filteredList.isEmpty
                              ? ListView(
                                  children: [
                                    const SizedBox(height: 100),
                                    _buildEmptyState(),
                                  ],
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: _filteredList.length,
                                  itemBuilder: (ctx, i) => _buildHistoryItem(
                                      ctx, _filteredList[i], i),
                                ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'Semua', Icons.list_rounded),
      ('toxic', 'Beracun', Icons.warning_rounded),
      ('safe', 'Aman', Icons.check_circle_rounded),
      ('saved', 'Tersimpan', Icons.bookmark_rounded),
    ];
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final isSelected = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(f.$3,
                        size: 14,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary),
                    const SizedBox(width: 5),
                    Text(
                      f.$2,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _history.length;
    final toxic = _history.where((s) => s.isToxic).length;
    final safe = total - toxic;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          _buildMiniStat('$total', 'Total', AppColors.textSecondary),
          _buildMiniStat('$toxic', 'Beracun', AppColors.danger),
          _buildMiniStat('$safe', 'Aman', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String value, String label, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: GoogleFonts.poppins(fontSize: 10, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(
      BuildContext context, ScanResultModel scan, int index) {
    final isToxic = scan.isToxic;
    final color = isToxic ? AppColors.danger : AppColors.safe;
    return Dismissible(
      key: Key(scan.id?.toString() ?? UniqueKey().toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white, size: 28),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: AppColors.surface,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: Text("Hapus Riwayat",
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w700)),
              content: Text("Apakah Anda yakin ingin menghapus hasil scan ini?",
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: AppColors.textSecondary)),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text("Batal",
                      style:
                          GoogleFonts.poppins(color: AppColors.textSecondary)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.danger),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text("Hapus", style: GoogleFonts.poppins()),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) {
        if (scan.id != null) {
          _deleteItem(scan.id!, index);
        }
      },
      child: GestureDetector(
        onTap: () async {
          await Navigator.pushNamed(context, '/result', arguments: scan);
          _fetchHistory();
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              // Thumbnail
              Container(
                width: 80,
                height: 80,
                margin: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: scan.imagePath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: scan.imagePath.startsWith('http')
                            ? Image.network(
                                scan.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.broken_image_rounded,
                                    color: color,
                                    size: 36,
                                  );
                                },
                              )
                            : Image.file(
                                File(scan.imagePath),
                                fit: BoxFit.cover,
                              ),
                      )
                    : Icon(Icons.flutter_dash, color: color, size: 36),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
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
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('dd MMM yyyy • HH:mm')
                            .format(scan.scannedAt),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          ToxicityBadge(isToxic: isToxic),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${(scan.confidence * 100).toStringAsFixed(0)}%',
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ),
                          if (scan.isSaved) ...[
                            const SizedBox(width: 6),
                            const Icon(Icons.bookmark_rounded,
                                color: AppColors.accent, size: 14),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow
              const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.chevron_right_rounded,
                    color: AppColors.textHint, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.history_rounded,
              size: 60, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Tidak ada riwayat',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai scan kupu-kupu untuk melihat riwayat',
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: AppColors.textHint,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Urutkan',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            ...[
              'Terbaru',
              'Terlama',
              'Beracun Dulu',
              'Confidence Tertinggi',
            ].map((item) => ListTile(
                  title: Text(item,
                      style: GoogleFonts.poppins(
                          color: AppColors.textPrimary, fontSize: 14)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textHint),
                  onTap: () => Navigator.pop(ctx),
                )),
          ],
        ),
      ),
    );
  }
}
