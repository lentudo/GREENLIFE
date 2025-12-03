import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_servicio.dart';
import '../services/db_servicio.dart';
import '../models/planta_model.dart';
import 'details_planta.dart';
import 'planta.dart';
import 'buscar_viveros.dart';

import 'nivelador.dart';



class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final AuthService _auth = AuthService();
  final DBService _db = DBService();
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Plantas 🌿'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _auth.signOut(),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'GreenLife',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Menú Principal',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Mis Plantas'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer
              },
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Buscar Viveros'),
              onTap: () {
                Navigator.pop(context); // Cierra el drawer antes de navegar
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BuscarViverosScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.water_drop),
              title: const Text('Nivelador de Maceta'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NiveladorScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _auth.signOut();
              },
            ),
          ],
        ),
      ),
      // BOTÓN FLOTANTE PARA AGREGAR
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AgregarPlantaScreen()),
          );
        },
      ),
      body: StreamBuilder<List<PlantaModel>>(
        stream: _db.obtenerPlantasUsuario(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No tienes plantas aún. ¡Agrega una! 🌱'),
            );
          }

          final plantas = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: plantas.length,
            itemBuilder: (context, index) {
              final planta = plantas[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(10),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: NetworkImage(planta.imagenUrl),
                    backgroundColor: Colors.grey[200],
                  ),
                  title: Text(
                    planta.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  subtitle: Text('${planta.tipo} • ${planta.ubicacion}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap:
                      () {

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetallePlantaScreen(planta: planta),
                          ),
                        );
                    // AQUÍ IREMOS AL DETALLE EN FASE 3
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}