import 'dart:io'; // Para manejar el archivo de la imagen
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart'; // Necesario para nombres únicos de fotos
import '../models/planta_model.dart';

class DBService {
  // Instancias de Firebase
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // -------------------------
  // 1. SUBIR IMAGEN (Storage)
  // -------------------------
  // Sube una foto y devuelve la URL pública para guardarla en la BD
  Future<String?> subirImagen(File imagen) async {
    try {
      // Generamos un nombre único para no sobreescribir fotos
      String fileName = const Uuid().v4();

      // Referencia: carpeta 'plantas_imgs' -> nombre_archivo.jpg
      Reference ref = _storage.ref().child('plantas_imgs/$fileName.jpg');

      // Subir el archivo
      UploadTask uploadTask = ref.putFile(imagen);

      // Esperar a que termine
      TaskSnapshot snapshot = await uploadTask;

      // Obtener la URL de descarga
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error subiendo imagen: $e");
      return null;
    }
  }

  // -------------------------
  // 2. GUARDAR PLANTA (Firestore)
  // -------------------------
  Future<bool> agregarPlanta(PlantaModel planta) async {
    try {
      // Usamos el ID de la planta (generado previamente) como ID del documento
      await _firestore
          .collection('plantas')
          .doc(planta.id)
          .set(planta.toMap());
      return true;
    } catch (e) {
      print("Error guardando planta: $e");
      return false;
    }
  }

  // -------------------------
  // 3. OBTENER PLANTAS (Firestore - Tiempo Real)
  // -------------------------
  // Escucha cambios en la DB. Si agregas una planta, la lista se actualiza sola.
  Stream<List<PlantaModel>> obtenerPlantasUsuario(String usuarioId) {
    return _firestore
        .collection('plantas')
        .where('usuarioId', isEqualTo: usuarioId) // Solo mis plantas
        .orderBy('creadoEn', descending: true)    // Las nuevas primero
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return PlantaModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  // -------------------------
  // 4. OBTENER TODAS LAS PLANTAS (Para el Mapa - Fase 4)
  // -------------------------
  // Esta función servirá para ver las plantas de la comunidad
  Future<List<PlantaModel>> obtenerTodasLasPlantas() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('plantas')
          .orderBy('creadoEn', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return PlantaModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Error obteniendo comunidad: $e");
      return [];
    }
  }
}