class ButterflyModel {
  final int id;
  final String name;
  final String scientificName;
  final bool isToxic;
  final String description;
  final String? imageUrl;
  final bool isCollected; // apakah sudah pernah discan user ini

  // === Field tambahan untuk database ===
  final String? habitat;           // Habitat asli kupu-kupu
  final String? distribution;      // Persebaran geografis
  final String? wingSpan;          // Rentang sayap (contoh: "8–12 cm")
  final String? toxinType;         // Jenis racun (jika beracun)
  final String? safetyAdvice;      // Saran keselamatan jika beracun
  final String? conservationStatus; // Status konservasi (LC, NT, VU, EN, CR)
  final String? diet;              // Makanan larva/dewasa

  ButterflyModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.isToxic,
    required this.description,
    this.imageUrl,
    this.isCollected = false,
    this.habitat,
    this.distribution,
    this.wingSpan,
    this.toxinType,
    this.safetyAdvice,
    this.conservationStatus,
    this.diet,
  });

  factory ButterflyModel.fromJson(Map<String, dynamic> json) {
    return ButterflyModel(
      id: json['id'],
      name: json['name'],
      scientificName: json['scientific_name'] ?? '',
      isToxic: json['is_toxic'] ?? false,
      description: json['description'] ?? '',
      imageUrl: json['image_url'],
      isCollected: json['is_collected'] ?? false,
      habitat: json['habitat'],
      distribution: json['distribution'],
      wingSpan: json['wing_span'],
      toxinType: json['toxin_type'],
      safetyAdvice: json['safety_advice'],
      conservationStatus: json['conservation_status'],
      diet: json['diet'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'scientific_name': scientificName,
      'is_toxic': isToxic,
      'description': description,
      'image_url': imageUrl,
      'is_collected': isCollected,
      'habitat': habitat,
      'distribution': distribution,
      'wing_span': wingSpan,
      'toxin_type': toxinType,
      'safety_advice': safetyAdvice,
      'conservation_status': conservationStatus,
      'diet': diet,
    };
  }

  ButterflyModel copyWith({
    String? name,
    String? scientificName,
    bool? isToxic,
    String? description,
    String? imageUrl,
    bool? isCollected,
    String? habitat,
    String? distribution,
    String? wingSpan,
    String? toxinType,
    String? safetyAdvice,
    String? conservationStatus,
    String? diet,
  }) {
    return ButterflyModel(
      id: id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      isToxic: isToxic ?? this.isToxic,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isCollected: isCollected ?? this.isCollected,
      habitat: habitat ?? this.habitat,
      distribution: distribution ?? this.distribution,
      wingSpan: wingSpan ?? this.wingSpan,
      toxinType: toxinType ?? this.toxinType,
      safetyAdvice: safetyAdvice ?? this.safetyAdvice,
      conservationStatus: conservationStatus ?? this.conservationStatus,
      diet: diet ?? this.diet,
    );
  }
}

// Sample data untuk demo
final List<ButterflyModel> sampleButterflies = [
  ButterflyModel(
    id: 1,
    name: 'Monarch Butterfly',
    scientificName: 'Danaus plexippus',
    isToxic: true,
    description:
        'Kupu-kupu Monarch mengandung cardenolide aglycones yang berasal dari tanaman milkweed yang dimakannya. Senyawa ini bersifat toksik bagi predator seperti burung.',
    imageUrl: null,
    isCollected: true,
    habitat: 'Padang rumput, ladang milkweed, taman',
    distribution: 'Amerika Utara, bermigrasi ke Meksiko',
    wingSpan: '8,9–10,2 cm',
    toxinType: 'Cardenolide aglycones (glikosida jantung)',
    safetyAdvice:
        '⚠️ Jika menyentuh kupu-kupu ini, segera cuci tangan dengan sabun dan air mengalir selama minimal 20 detik. Hindari menyentuh wajah, mata, atau mulut sebelum mencuci tangan. Bila terjadi iritasi kulit atau reaksi alergi seperti kemerahan atau gatal, segera konsultasikan ke dokter. Jangan mengonsumsi bagian tubuhnya.',
    conservationStatus: 'Endangered (EN)',
    diet: 'Nektar bunga (dewasa), daun milkweed (larva)',
  ),
  ButterflyModel(
    id: 2,
    name: 'Swallowtail Butterfly',
    scientificName: 'Papilio machaon',
    isToxic: false,
    description:
        'Kupu-kupu ekor walet adalah salah satu kupu-kupu terbesar dan paling terkenal. Tidak beracun dan umumnya jinak terhadap manusia.',
    imageUrl: null,
    isCollected: true,
    habitat: 'Padang rumput, perbukitan berbatu, taman',
    distribution: 'Eropa, Asia, Amerika Utara',
    wingSpan: '6,5–8,6 cm',
    toxinType: null,
    safetyAdvice: null,
    conservationStatus: 'Least Concern (LC)',
    diet: 'Nektar bunga (dewasa), daun wortel & adas (larva)',
  ),
  ButterflyModel(
    id: 3,
    name: 'Pipevine Swallowtail',
    scientificName: 'Battus philenor',
    isToxic: true,
    description:
        'Mengandung aristolochic acids dari tanaman inang pipevine. Racunnya dipertahankan sepanjang siklus hidup termasuk pada fase dewasa.',
    imageUrl: null,
    isCollected: false,
    habitat: 'Hutan riparian, semak belukar, tepi hutan',
    distribution: 'Amerika Serikat bagian Selatan dan Timur, Meksiko',
    wingSpan: '7–13 cm',
    toxinType: 'Aristolochic acids',
    safetyAdvice:
        '⚠️ Jika terpapar atau menyentuh spesies ini, cuci tangan segera dengan sabun dan air mengalir. Hindari kontak dengan mata atau mulut. Aristolochic acids bersifat nefrotoksik (merusak ginjal) jika tertelan dalam jumlah besar. Jika tertelan atau muncul gejala seperti mual, pusing, atau nyeri perut, segera hubungi tenaga medis atau unit gawat darurat.',
    conservationStatus: 'Least Concern (LC)',
    diet: 'Nektar bunga (dewasa), daun pipevine (larva)',
  ),
  ButterflyModel(
    id: 4,
    name: 'Blue Morpho',
    scientificName: 'Morpho menelaus',
    isToxic: false,
    description:
        'Kupu-kupu dengan sayap biru metalik yang indah dari hutan hujan Amerika Selatan. Tidak beracun dan merupakan salah satu kupu-kupu paling cantik di dunia.',
    imageUrl: null,
    isCollected: true,
    habitat: 'Hutan hujan tropis dataran rendah',
    distribution: 'Amerika Tengah dan Amerika Selatan',
    wingSpan: '12–20 cm',
    toxinType: null,
    safetyAdvice: null,
    conservationStatus: 'Near Threatened (NT)',
    diet: 'Buah busuk, getah pohon (dewasa), daun legum (larva)',
  ),
  ButterflyModel(
    id: 5,
    name: 'Zebra Longwing',
    scientificName: 'Heliconius charithonia',
    isToxic: true,
    description:
        'Mengandung cyanogenic compounds dari tanaman passionflower. Warna belang hitam-kuning merupakan aposematism peringatan bahaya.',
    imageUrl: null,
    isCollected: false,
    habitat: 'Hutan tropis dan subtropis, semak-semak berbunga',
    distribution: 'Florida, Amerika Tengah, Amerika Selatan utara',
    wingSpan: '7,2–10 cm',
    toxinType: 'Cyanogenic glycosides',
    safetyAdvice:
        '⚠️ Hindari menyentuh langsung atau memegangnya tanpa sarung tangan. Jika kontak terjadi, segera cuci tangan dengan sabun dan air. Cyanogenic compounds dapat melepaskan HCN (asam sianida) dalam kondisi tertentu. Jika tertelan bagian dari kupu-kupu ini dan muncul gejala seperti sesak napas, pusing, atau mual hebat, segera hubungi layanan darurat medis (IGD) dan informasikan jenis paparan yang terjadi.',
    conservationStatus: 'Least Concern (LC)',
    diet: 'Serbuk sari bunga passiflora (dewasa), daun passionflower (larva)',
  ),
  ButterflyModel(
    id: 6,
    name: 'Glasswing Butterfly',
    scientificName: 'Greta oto',
    isToxic: false,
    description:
        'Kupu-kupu sayap kaca yang memiliki sayap transparan unik. Tidak beracun dan berasal dari hutan hujan Amerika Tengah.',
    imageUrl: null,
    isCollected: false,
    habitat: 'Hutan hujan tropis lembab',
    distribution: 'Amerika Tengah (Meksiko hingga Panama)',
    wingSpan: '5,5–6 cm',
    toxinType: null,
    safetyAdvice: null,
    conservationStatus: 'Least Concern (LC)',
    diet: 'Nektar Lantana (dewasa), daun Cestrum (larva)',
  ),
  ButterflyModel(
    id: 7,
    name: 'Queen Butterfly',
    scientificName: 'Danaus gilippus',
    isToxic: true,
    description:
        'Kerabat dekat Monarch yang juga menyerap racun dari milkweed. Memiliki mekanisme pertahanan serupa dengan Monarch butterfly.',
    imageUrl: null,
    isCollected: false,
    habitat: 'Padang rumput kering, gurun, ladang terbuka',
    distribution: 'Amerika Selatan bagian Barat, Amerika Tengah, Karibia',
    wingSpan: '7–8,8 cm',
    toxinType: 'Cardenolide aglycones (glikosida jantung)',
    safetyAdvice:
        '⚠️ Sama seperti Monarch, segera cuci tangan setelah kontak langsung. Hindari menyentuh area wajah sebelum mencuci tangan. Racun ini mempengaruhi sistem kardiovaskular jika tertelan. Untuk kontak kulit biasa biasanya tidak berbahaya, namun tetap waspadai reaksi alergi. Jika tertelan, segera cari pertolongan medis.',
    conservationStatus: 'Least Concern (LC)',
    diet: 'Nektar bunga (dewasa), daun milkweed (larva)',
  ),
  ButterflyModel(
    id: 8,
    name: 'Painted Lady',
    scientificName: 'Vanessa cardui',
    isToxic: false,
    description:
        'Salah satu kupu-kupu yang paling tersebar di dunia. Tidak beracun dan dapat ditemukan di hampir semua benua kecuali Antartika.',
    imageUrl: null,
    isCollected: true,
    habitat: 'Padang rumput terbuka, taman, pinggir jalan',
    distribution: 'Hampir seluruh permukaan bumi',
    wingSpan: '5,1–7,3 cm',
    toxinType: null,
    safetyAdvice: null,
    conservationStatus: 'Least Concern (LC)',
    diet: 'Nektar berbagai bunga (dewasa), daun thistle (larva)',
  ),
];
