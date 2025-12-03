// lib/auth_guardian.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greenlife/pantallas/auth.dart';
import 'package:greenlife/pantallas/home.dart';
import 'package:greenlife/pantallas/admin_dashboard.dart';

class AuthGuardian extends StatelessWidget {
  const AuthGuardian({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.green));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Ha ocurrido un error. Inténtalo de nuevo.'));
          }

          if (snapshot.hasData) {
            // Usuario autenticado, verificamos su rol en Firestore
            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.green));
                }

                if (userSnapshot.hasData && userSnapshot.data!.exists) {
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  final rol = userData['rol'] ?? 'user';

                  if (rol == 'admin') {
                    return const AdminDashboard();
                  } else {
                    return HomeScreen();
                  }
                }

                // Si no se encuentra el usuario en BD (caso raro), mandamos a Home o Logout
                return HomeScreen();
              },
            );
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
