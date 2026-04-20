class ButterflyModel {
  final int id;
  final String name;
  final String scientificName;
  final bool isToxic;
  final String description;
  final String? imageUrl;
  final bool isCollected; // apakah sudah pernah discan user ini

  ButterflyModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.isToxic,
    required this.description,
    this.imageUrl,
    this.isCollected = false,
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
    };
  }

  ButterflyModel copyWith({
    String? name,
    String? scientificName,
    bool? isToxic,
    String? description,
    String? imageUrl,
    bool? isCollected,
  }) {
    return ButterflyModel(
      id: id,
      name: name ?? this.name,
      scientificName: scientificName ?? this.scientificName,
      isToxic: isToxic ?? this.isToxic,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      isCollected: isCollected ?? this.isCollected,
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
    description: 'Kupu-kupu Monarch mengandung cardenolide aglycones yang berasal dari tanaman milkweed yang dimakannya. Senyawa ini bersifat toksik bagi predator seperti burung.',
    imageUrl: null,
    isCollected: true,
  ),
  ButterflyModel(
    id: 2,
    name: 'Swallowtail Butterfly',
    scientificName: 'Papilio machaon',
    isToxic: false,
    description: 'Kupu-kupu ekor walet adalah salah satu kupu-kupu terbesar dan paling terkenal. Tidak beracun dan umumnya jinak terhadap manusia.',
    imageUrl: null,
    isCollected: true,
  ),
  ButterflyModel(
    id: 3,
    name: 'Pipevine Swallowtail',
    scientificName: 'Battus philenor',
    isToxic: true,
    description: 'Mengandung aristolochic acids dari tanaman inang pipevine. Racunnya dipertahankan sepanjang siklus hidup termasuk pada fase dewasa.',
    imageUrl: null,
    isCollected: false,
  ),
  ButterflyModel(
    id: 4,
    name: 'Blue Morpho',
    scientificName: 'Morpho menelaus',
    isToxic: false,
    description: 'Kupu-kupu dengan sayap biru metalik yang indah dari hutan hujan Amerika Selatan. Tidak beracun dan merupakan salah satu kupu-kupu paling cantik di dunia.',
    imageUrl: null,
    isCollected: true,
  ),
  ButterflyModel(
    id: 5,
    name: 'Zebra Longwing',
    scientificName: 'Heliconius charithonia',
    isToxic: true,
    description: 'Mengandung cyanogenic compounds dari tanaman passionflower. Warna belang hitam-kuning merupakan aposematism peringatan bahaya.',
    imageUrl: null,
    isCollected: false,
  ),
  ButterflyModel(
    id: 6,
    name: 'Glasswing Butterfly',
    scientificName: 'Greta oto',
    isToxic: false,
    description: 'Kupu-kupu sayap kaca yang memiliki sayap transparan unik. Tidak beracun dan berasal dari hutan hujan Amerika Tengah.',
    imageUrl: null,
    isCollected: false,
  ),
  ButterflyModel(
    id: 7,
    name: 'Queen Butterfly',
    scientificName: 'Danaus gilippus',
    isToxic: true,
    description: 'Kerabat dekat Monarch yang juga menyerap racun dari milkweed. Memiliki mekanisme pertahanan serupa dengan Monarch butterfly.',
    imageUrl: null,
    isCollected: false,
  ),
  ButterflyModel(
    id: 8,
    name: 'Painted Lady',
    scientificName: 'Vanessa cardui',
    isToxic: false,
    description: 'Salah satu kupu-kupu yang paling tersebar di dunia. Tidak beracun dan dapat ditemukan di hampir semua benua kecuali Antartika.',
    imageUrl: null,
    isCollected: true,
  ),
];
