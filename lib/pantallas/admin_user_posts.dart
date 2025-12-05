import 'package:flutter/material.dart';
import 'package:greenlife/models/planta_model.dart';
import 'package:greenlife/models/usuario_model.dart';
import 'package:greenlife/services/db_servicio.dart';
import 'package:intl/intl.dart';

class AdminUserPostsScreen extends StatefulWidget {
  final UsuarioModel usuario;

  const AdminUserPostsScreen({super.key, required this.usuario});

  @override
  State<AdminUserPostsScreen> createState() => _AdminUserPostsScreenState();
}

class _AdminUserPostsScreenState extends State<AdminUserPostsScreen> {
  final DBService _dbService = DBService();

  void _eliminarPlanta(PlantaModel planta) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Publicación'),
        content: Text('¿Estás seguro de eliminar la planta "${planta.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      final exito = await _dbService.eliminarPlanta(planta.id);
      if (exito && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Publicación eliminada correctamente')),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar la publicación')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publicaciones de ${widget.usuario.nombre}'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<PlantaModel>>(
        stream: _dbService.obtenerPlantasUsuario(widget.usuario.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar publicaciones'));
          }

          final plantas = snapshot.data ?? [];

          if (plantas.isEmpty) {
            return const Center(
              child: Text(
                'Este usuario no tiene publicaciones.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: plantas.length,
            itemBuilder: (context, index) {
              final planta = plantas[index];
              return Card(
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        planta.imagenUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  planta.nombre,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _eliminarPlanta(planta),
                                tooltip: 'Eliminar Publicación',
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ubicación: ${planta.ubicacion}',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Publicado: ${DateFormat('dd/MM/yyyy').format(planta.creadoEn)}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
