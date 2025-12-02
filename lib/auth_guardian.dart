// lib/auth_guardian.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/pantallas/auth.dart'; // Asegúrate que la ruta sea correcta
import 'package:greenlife/pantallas/home.dart';       // Asegúrate que la ruta sea correcta

class AuthGuardian extends StatelessWidget {
  const AuthGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // <--- 1. Envuelve todo en un Scaffold
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // --- 2. MANEJO DEL ESTADO DE CONEXIÓN ---
          // Mientras espera la respuesta de Firebase, muestra un círculo de carga.
          // ¡ESTO RESUELVE LA PANTALLA EN BLANCO!
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green, // Opcional: para que combine con tu tema
              ),
            );
          }

          // --- 3. MANEJO DE ERRORES ---
          // Si hubo un error en el stream, muéstralo.
          if (snapshot.hasError) {
            return const Center(
              child: Text('Ha ocurrido un error. Inténtalo de nuevo.'),
            );
          }

          // --- 4. LÓGICA PRINCIPAL (esta ya la tenías) ---
          // Si el stream ya respondió y tiene datos (usuario logueado)...
          if (snapshot.hasData) {
            return HomeScreen(); // Muestra la pantalla de inicio
          } else {
            // Si no tiene datos (usuario no logueado)...
            return AuthScreen(); // Muestra la pantalla de autenticación
          }
        },
      ),
    );
  }
}
