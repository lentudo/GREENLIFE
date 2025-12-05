import 'package:cloud_firestore/cloud_firestore.dart';

class PlantaModel {
  final String id;
  final String usuarioId; // Relación con Usuario
  final String nombre;
  final String tipo;      // Especie o tipo
  final String ubicacion; // Texto descriptivo (Ej: "Sala")
  final String imagenUrl; // FOTO DE LA PLANTA 
  final int frecuenciaRiego; // Días
  final DateTime ultimoRiego;
  final GeoPoint? coordenadas; // Para Google Maps
  final DateTime creadoEn;

  PlantaModel({
    required this.id,
    required this.usuarioId,
    required this.nombre,
    required this.tipo,
    required this.ubicacion,
    required this.imagenUrl,
    required this.frecuenciaRiego,
    required this.ultimoRiego,
    this.coordenadas,
    required this.creadoEn,
  });

  factory PlantaModel.fromMap(Map<String, dynamic> map, String id) {
    return PlantaModel(
      id: id,
      usuarioId: map['usuarioId'] ?? '',
      nombre: map['nombre'] ?? 'Sin nombre',
      tipo: map['tipo'] ?? 'Desconocida',
      ubicacion: map['ubicacion'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      frecuenciaRiego: map['frecuenciaRiego'] ?? 1,
      ultimoRiego: (map['ultimoRiego'] as Timestamp?)?.toDate() ?? DateTime.now(),
      coordenadas: map['coordenadas'] as GeoPoint?,
      creadoEn: (map['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'usuarioId': usuarioId,
      'nombre': nombre,
      'tipo': tipo,
      'ubicacion': ubicacion,
      'imagenUrl': imagenUrl,
      'frecuenciaRiego': frecuenciaRiego,
      'ultimoRiego': Timestamp.fromDate(ultimoRiego),
      'coordenadas': coordenadas,
      'creadoEn': Timestamp.fromDate(creadoEn),
    };
  }
}