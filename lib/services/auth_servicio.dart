// lib/services/auth_service.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart'; // Importamos el modelo creado

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get usuario {
    return _auth.authStateChanges();
  }

  // -------------------------
  // 1. REGISTRO (Sign Up)
  // -------------------------
  Future<UsuarioModel?> signUp(String nombre, String correo, String contrasena) async {
    try {
      // 1. Crear el usuario en Firebase Authentication
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      User? user = result.user;

      if (user != null) {
        // 2. Crear el modelo de usuario (U4)
        UsuarioModel nuevoUsuario = UsuarioModel(
          uid: user.uid,
          nombre: nombre,
          correo: correo,
          rol: 'user', // Por defecto, es un usuario normal
          creadoEn: DateTime.now(),
          tokenNotificacion: null, // Se asignará más tarde con Notificaciones
        );

        // 3. Guardar el usuario en Firestore (U4)
        await _firestore.collection('users').doc(user.uid).set(nuevoUsuario.toMap());

        return nuevoUsuario;
      }
      return null;
    } catch (e) {
      print("Error en el registro: $e");
      return null;
    }
  }

  // -------------------------
  // 2. INICIO DE SESIÓN (Log In)
  // -------------------------
  Future<User?> signIn(String correo, String contrasena) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: correo,
        password: contrasena,
      );
      return result.user;
    } catch (e) {
      print("Error en el inicio de sesión: $e");
      return null;
    }
  }

  // -------------------------
  // 3. CERRAR SESIÓN (Log Out)
  // -------------------------
  Future<void> signOut() async {
    await _auth.signOut();
  }
}