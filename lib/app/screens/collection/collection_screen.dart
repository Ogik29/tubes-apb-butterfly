import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_colors.dart';
import '../../models/butterfly_model.dart';

class CollectionScreen extends StatefulWidget {
  const CollectionScreen({super.key});

  @override
  State<CollectionScreen> createState() => _CollectionScreenState();
}

class _CollectionScreenState extends State<CollectionScreen> {
  String _filter = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  List<ButterflyModel> get _filteredList {
    var list = sampleButterflies.where((b) {
      final matchSearch = _searchQuery.isEmpty ||
          b.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          b.scientificName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchSearch;
    }).toList();

    switch (_filter) {
      case 'collected':
        return list.where((b) => b.isCollected).toList();
      case 'not_collected':
        return list.where((b) => !b.isCollected).toList();
      default:
        return list;
    }
  }

  int get _collectedCount => sampleButterflies.where((b) => b.isCollected).length;
  int get _totalCount => sampleButterflies.length;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onCardTap(BuildContext ctx, ButterflyModel butterfly) {
    if (!butterfly.isCollected) {
      // Tampilkan snackbar / dialog — tidak boleh masuk ke detail
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.lock_rounded, color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Scan spesies ini terlebih dahulu untuk membuka detailnya!',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.surfaceLight,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    // Hanya yang sudah dikumpulkan boleh ke detail
    Navigator.pushNamed(ctx, '/species-detail', arguments: butterfly);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Koleksi Kupu-Kupu'),
        backgroundColor: AppColors.background,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressHeader(),
            _buildSearchBar(),
            _buildFilterChips(),
            Expanded(
              child: _filteredList.isEmpty
                  ? _buildEmptyState()
                  : GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: _filteredList.length,
                      itemBuilder: (ctx, i) => _CollectionCard(
                        butterfly: _filteredList[i],
                        onTap: () => _onCardTap(ctx, _filteredList[i]),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressHeader() {
    final progress = _collectedCount / _totalCount;
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 16,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Progres Koleksi',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$_collectedCount / $_totalCount Spesies',
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withOpacity(0.15),
                  border: Border.all(
                      color: AppColors.primary.withOpacity(0.4), width: 2),
                ),
                child: Center(
                  child: Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.primary, size: 12),
              const SizedBox(width: 4),
              Text(
                '$_collectedCount ditemukan • ${_totalCount - _collectedCount} belum ditemukan',
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textPrimary),
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'Cari spesies kupu-kupu...',
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
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      ('all', 'Semua'),
      ('collected', 'Ditemukan ⭐'),
      ('not_collected', 'Belum'),
    ];
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: filters.map((f) {
          final isSelected = _filter == f.$1;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary.withOpacity(0.2)
                      : AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Text(
                  f.$2,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off_rounded, size: 60, color: AppColors.textHint),
          const SizedBox(height: 16),
          Text(
            'Tidak ditemukan',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Card koleksi khusus: jika locked → sembunyikan badge toksisitas & tampilkan ikon kunci
class _CollectionCard extends StatelessWidget {
  final ButterflyModel butterfly;
  final VoidCallback onTap;

  const _CollectionCard({required this.butterfly, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isCollected = butterfly.isCollected;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isCollected
                ? AppColors.primary.withOpacity(0.45)
                : AppColors.border,
          ),
          boxShadow: isCollected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.18),
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
                  fit: StackFit.expand,
                  children: [
                    // Background icon
                    Container(
                      color: AppColors.surfaceLight,
                      child: Center(
                        child: Icon(
                          Icons.flutter_dash,
                          size: 52,
                          color: isCollected
                              ? AppColors.primary.withOpacity(0.7)
                              : AppColors.textHint.withOpacity(0.3),
                        ),
                      ),
                    ),
                    // Overlay gelap jika locked
                    if (!isCollected)
                      Container(
                        color: Colors.black.withOpacity(0.45),
                        child: const Center(
                          child: Icon(
                            Icons.lock_rounded,
                            color: Colors.white54,
                            size: 32,
                          ),
                        ),
                      ),
                    // Star badge jika sudah dikumpulkan
                    if (isCollected)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Icon(Icons.star_rounded,
                              color: Colors.white, size: 13),
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
                        // Tampilkan nama hanya jika sudah ditemukan, else "???"
                        isCollected ? butterfly.name : '???',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isCollected
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Badge toksisitas HANYA tampil jika sudah ditemukan
                      if (isCollected)
                        _ToxicityMiniChip(isToxic: butterfly.isToxic)
                      else
                        Text(
                          'Belum ditemukan',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: AppColors.textHint,
                          ),
                        ),
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
}

class _ToxicityMiniChip extends StatelessWidget {
  final bool isToxic;
  const _ToxicityMiniChip({required this.isToxic});

  @override
  Widget build(BuildContext context) {
    final color = isToxic ? AppColors.danger : AppColors.safe;
    final bg = isToxic ? AppColors.dangerLight : AppColors.safeLight;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isToxic ? Icons.warning_rounded : Icons.check_circle_rounded,
            size: 11,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            isToxic ? 'Beracun' : 'Aman',
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
