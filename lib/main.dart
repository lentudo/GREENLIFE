// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// 1. Importa el 'AuthGuardian' que creamos, es nuestro controlador principal.
import 'auth_guardian.dart';

// 2. Importa las opciones de Firebase generadas por la CLI de FlutterFire.
//    (Este archivo se crea automáticamente cuando configuras Firebase).
import 'firebase_options.dart';

void main() async {
  // Asegura que todos los bindings de Flutter estén listos antes de cualquier otra cosa.
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inicializa Firebase de la forma correcta y moderna.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GreenLife',
      theme: ThemeData(
        // 'primarySwatch' está obsoleto. Esta es la forma moderna en Material 3.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, // Opcional: para quitar la cinta de "Debug"

      // 4. Establece 'AuthGate' como la pantalla de inicio.
      //    Él se encargará de decidir si mostrar AuthScreen o HomeScreen.
      //    Esto hace que tu main.dart sea mucho más limpio.
      home: const AuthGuardian(),
    );
  }
}
