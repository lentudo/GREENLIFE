import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import '../services/db_servicio.dart';
import '../models/planta_model.dart';

class AgregarPlantaScreen extends StatefulWidget {
  const AgregarPlantaScreen({super.key});

  @override
  State<AgregarPlantaScreen> createState() => _AgregarPlantaScreenState();
}

class _AgregarPlantaScreenState extends State<AgregarPlantaScreen> {
  final _formKey = GlobalKey<FormState>();
  final DBService _dbService = DBService();

  // Controladores
  final TextEditingController _nombreCtrl = TextEditingController();
  final TextEditingController _tipoCtrl = TextEditingController();
  final TextEditingController _ubicacionCtrl = TextEditingController();
  final TextEditingController _frecuenciaCtrl = TextEditingController();

  File? _imagenSeleccionada;
  bool _isLoading = false;

  // Seleccionar imagen
  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    // Muestra diálogo para elegir cámara o galería
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagenSeleccionada = File(pickedFile.path);
      });
    }
  }

  // Guardar en Firebase
  void _guardarPlanta() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Por favor agrega una foto de tu planta!')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // 1. Subir imagen
      String? urlImagen = await _dbService.subirImagen(_imagenSeleccionada!);

      if (urlImagen == null) throw Exception("Error al subir imagen");

      // 2. Crear modelo
      final nuevaPlanta = PlantaModel(
        id: const Uuid().v4(), // Generamos ID único
        usuarioId: user.uid,
        nombre: _nombreCtrl.text.trim(),
        tipo: _tipoCtrl.text.trim(),
        ubicacion: _ubicacionCtrl.text.trim(),
        imagenUrl: urlImagen,
        frecuenciaRiego: int.tryParse(_frecuenciaCtrl.text) ?? 1,
        ultimoRiego: DateTime.now(),
        creadoEn: DateTime.now(),
      );

      // 3. Guardar en Firestore
      await _dbService.agregarPlanta(nuevaPlanta);

      if (mounted) {
        Navigator.pop(context); // Volver al Home
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva Planta'), backgroundColor: Colors.green),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Área de Imagen
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    image: _imagenSeleccionada != null
                        ? DecorationImage(
                      image: FileImage(_imagenSeleccionada!),
                      fit: BoxFit.cover,
                    )
                        : null,
                  ),
                  child: _imagenSeleccionada == null
                      ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt, size: 50, color: Colors.grey),
                      Text('Toca para agregar foto'),
                    ],
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 20),

              // Campos
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre de la planta (Ej: Juanita)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _tipoCtrl,
                decoration: const InputDecoration(labelText: 'Tipo (Ej: Suculenta)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _ubicacionCtrl,
                decoration: const InputDecoration(labelText: 'Ubicación (Ej: Sala)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              TextFormField(
                controller: _frecuenciaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Frecuencia de riego (días)'),
                validator: (v) => v!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 30),

              // Botón Guardar
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: _isLoading ? null : _guardarPlanta,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar Planta', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}