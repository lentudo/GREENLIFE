import 'package:flutter/material.dart';
import 'package:greenlife/models/usuario_model.dart';
import 'package:greenlife/services/auth_servicio.dart';
import 'package:greenlife/services/db_servicio.dart';
import 'package:greenlife/pantallas/admin_user_posts.dart';
import 'package:intl/intl.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final DBService _dbService = DBService();
  final AuthService _authService = AuthService();
  List<UsuarioModel> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuarios();
  }

  Future<void> _cargarUsuarios() async {
    setState(() => _isLoading = true);
    final usuarios = await _dbService.obtenerTodosLosUsuarios();
    setState(() {
      _usuarios = usuarios;
      _isLoading = false;
    });
  }

  void _cerrarSesion() async {
    await _authService.signOut();
   
  }

  void _eliminarUsuario(UsuarioModel usuario) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de eliminar a "${usuario.nombre}"? Esta acción no se puede deshacer.'),
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
      final exito = await _dbService.eliminarUsuario(usuario.uid);
      if (exito) {
        _cargarUsuarios(); // Recargar lista
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Usuario eliminado correctamente')),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al eliminar usuario')),
        );
      }
    }
  }

  void _verPublicaciones(UsuarioModel usuario) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserPostsScreen(usuario: usuario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Fondo gris claro, sobrio
      appBar: AppBar(
        title: const Text('Panel de Administración'),
        backgroundColor: const Color(0xFF2C3E50), // Azul oscuro, formal
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar Sesión',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarUsuarios,
              child: _usuarios.isEmpty
                  ? const Center(
                      child: Text(
                        'No hay usuarios registrados aún.',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _usuarios.length,
                      itemBuilder: (context, index) {
                        final usuario = _usuarios[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            onTap: () => _verPublicaciones(usuario), // Ver posts al tocar
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF34495E), // Azul grisáceo
                              child: Text(
                                usuario.nombre.isNotEmpty
                                    ? usuario.nombre[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              usuario.nombre,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.email, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(usuario.correo),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Registrado: ${DateFormat('dd/MM/yyyy').format(usuario.creadoEn)}',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _eliminarUsuario(usuario),
                              tooltip: 'Eliminar Usuario',
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
