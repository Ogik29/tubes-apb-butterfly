import 'package:flutter/material.dart';

class ScanResultModel {
  final int? id;
  final String imagePath; // local path or url
  final String predictedSpecies;
  final bool isToxic;
  final double confidence; // 0.0 - 1.0
  final DateTime scannedAt;
  final bool isSaved;
  final int? butterflyId;

  ScanResultModel({
    this.id,
    required this.imagePath,
    required this.predictedSpecies,
    required this.isToxic,
    required this.confidence,
    required this.scannedAt,
    this.isSaved = false,
    this.butterflyId,
  });

  String get confidencePercent =>
      '${(confidence * 100).toStringAsFixed(1)}%';

  Color get statusColor => isToxic ? const Color(0xFFFF4757) : const Color(0xFF76C893);
  String get statusText => isToxic ? 'BERACUN' : 'TIDAK BERACUN';

  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'],
      imagePath: json['image_path'] ?? '',
      predictedSpecies: json['predicted_species'] ?? '',
      isToxic: json['is_toxic'] ?? false,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      scannedAt: DateTime.parse(json['scanned_at']),
      isSaved: json['is_saved'] ?? false,
      butterflyId: json['butterfly_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_path': imagePath,
      'predicted_species': predictedSpecies,
      'is_toxic': isToxic,
      'confidence': confidence,
      'scanned_at': scannedAt.toIso8601String(),
      'is_saved': isSaved,
      'butterfly_id': butterflyId,
    };
  }
}

// Sample scan history data
final List<ScanResultModel> sampleScanHistory = [
  ScanResultModel(
    id: 1,
    imagePath: '',
    predictedSpecies: 'Monarch Butterfly',
    isToxic: true,
    confidence: 0.947,
    scannedAt: DateTime.now().subtract(const Duration(hours: 2)),
    isSaved: true,
    butterflyId: 1,
  ),
  ScanResultModel(
    id: 2,
    imagePath: '',
    predictedSpecies: 'Blue Morpho',
    isToxic: false,
    confidence: 0.891,
    scannedAt: DateTime.now().subtract(const Duration(days: 1)),
    isSaved: true,
    butterflyId: 4,
  ),
  ScanResultModel(
    id: 3,
    imagePath: '',
    predictedSpecies: 'Swallowtail Butterfly',
    isToxic: false,
    confidence: 0.763,
    scannedAt: DateTime.now().subtract(const Duration(days: 2)),
    isSaved: false,
    butterflyId: 2,
  ),
  ScanResultModel(
    id: 4,
    imagePath: '',
    predictedSpecies: 'Painted Lady',
    isToxic: false,
    confidence: 0.925,
    scannedAt: DateTime.now().subtract(const Duration(days: 3)),
    isSaved: true,
    butterflyId: 8,
  ),
  ScanResultModel(
    id: 5,
    imagePath: '',
    predictedSpecies: 'Unknown Species',
    isToxic: false,
    confidence: 0.412,
    scannedAt: DateTime.now().subtract(const Duration(days: 5)),
    isSaved: false,
    butterflyId: null,
  ),
];
