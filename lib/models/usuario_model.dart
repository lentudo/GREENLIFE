import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nombre;
  final String correo;
  final String rol; // 'admin' o 'user'
  final String? tokenNotificacion;
  final DateTime creadoEn;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.correo,
    required this.rol,
    this.tokenNotificacion,
    required this.creadoEn,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String id) {
    return UsuarioModel(
      uid: id,
      nombre: map['nombre'] ?? '',
      correo: map['correo'] ?? '',
      rol: map['rol'] ?? 'user',
      tokenNotificacion: map['tokenNotificacion'],
      creadoEn: (map['creadoEn'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'tokenNotificacion': tokenNotificacion,
      'creadoEn': Timestamp.fromDate(creadoEn),
    };
  }
}