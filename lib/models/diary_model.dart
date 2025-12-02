import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;
  final String plantaId; // A qué planta pertenece esta nota
  final String notas;
  final String? fotoUrl; // Foto opcional del estado actual (Sensor Cámara)
  final DateTime fecha;

  DiaryModel({
    required this.id,
    required this.plantaId,
    required this.notas,
    this.fotoUrl,
    required this.fecha,
  });

  factory DiaryModel.fromMap(Map<String, dynamic> map, String id) {
    return DiaryModel(
      id: id,
      plantaId: map['plantaId'] ?? '',
      notas: map['notas'] ?? '',
      fotoUrl: map['fotoUrl'],
      fecha: (map['fecha'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'plantaId': plantaId,
      'notas': notas,
      'fotoUrl': fotoUrl,
      'fecha': Timestamp.fromDate(fecha),
    };
  }
}