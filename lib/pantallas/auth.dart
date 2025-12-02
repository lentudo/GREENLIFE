import 'package:flutter/material.dart';
import '../services/auth_servicio.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controladores de texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passController = TextEditingController();

  // Estado: true = Login, false = Registro
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passController.dispose();
    super.dispose();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? error;

    if (_isLogin) {
      // --- LOGIN ---
      final user = await _auth.signIn(
        _correoController.text.trim(),
        _passController.text.trim(),
      );
      if (user == null) error = "Error al iniciar sesión. Verifique credenciales.";
    } else {
      // --- REGISTRO  ---
      final nuevoUsuario = await _auth.signUp(
        _nombreController.text.trim(), // <--- CAMPO NUEVO
        _correoController.text.trim(),
        _passController.text.trim(),
      );
      if (nuevoUsuario == null) error = "El correo ya está en uso o es inválido.";
    }

    setState(() => _isLoading = false);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error), backgroundColor: Colors.red),
      );
    }
    // Si no hay error, el AuthGuardian detectará el cambio y redirigirá a Home automáticamente.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF386641), // Verde oscuro (Fondo)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Card(
            color: const Color(0xFFF2E8CF), // Crema (Fondo tarjeta)
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(25.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? '🌿 Bienvenido a GreenLife 🌱' : 'Únete a la Comunidad 🪴',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF386641),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // --- CAMPO NOMBRE (Solo visible en Registro) ---
                    if (!_isLogin)
                      TextFormField(
                        controller: _nombreController,
                        decoration: const InputDecoration(labelText: 'Nombre de usuario'),
                        validator: (val) =>
                        val!.isEmpty ? 'Ingresa tu nombre' : null,
                      ),

                    if (!_isLogin) const SizedBox(height: 15),

                    // --- CAMPO CORREO ---
                    TextFormField(
                      controller: _correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(labelText: 'Correo Electrónico'),
                      validator: (val) =>
                      !val!.contains('@') ? 'Correo inválido' : null,
                    ),
                    const SizedBox(height: 15),

                    // --- CAMPO CONTRASEÑA ---
                    TextFormField(
                      controller: _passController,
                      obscureText: true,
                      decoration: const InputDecoration(labelText: 'Contraseña'),
                      validator: (val) =>
                      val!.length < 6 ? 'Mínimo 6 caracteres' : null,
                    ),
                    const SizedBox(height: 25),

                    // --- BOTÓN PRINCIPAL ---
                    if (_isLoading)
                      const CircularProgressIndicator()
                    else
                      ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A994E),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        ),
                        child: Text(_isLogin ? 'Iniciar Sesión' : 'Crear Cuenta'),
                      ),

                    const SizedBox(height: 15),

                    // --- TOGGLE LOGIN/REGISTRO ---
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? '¿No tienes cuenta? Regístrate'
                            : '¿Ya tienes cuenta? Inicia Sesión',
                        style: const TextStyle(color: Color(0xFF386641)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}