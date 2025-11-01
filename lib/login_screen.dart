import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controladores para leer el texto de los campos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // --- Muestra un pop-up de error ---
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  // --- Lógica de INICIAR SESIÓN ---
  Future<void> signIn() async {
    // Muestra un círculo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Cierra el círculo de carga
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Cierra el círculo de carga
      if (mounted) Navigator.pop(context);
      // Muestra el error
      _showErrorDialog(e.message ?? 'Ocurrió un error desconocido.');
    }
  }

  // --- Lógica de CREAR CUENTA ---
  Future<void> createAccount() async {
    // Muestra un círculo de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Valida la contraseña
      if (_passwordController.text.trim().length < 6) {
        if (mounted) Navigator.pop(context);
        _showErrorDialog('La contraseña debe tener al menos 6 caracteres.');
        return;
      }

      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Cierra el círculo de carga
      if (mounted) Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      // Cierra el círculo de carga
      if (mounted) Navigator.pop(context);
      // Muestra el error
      _showErrorDialog(e.message ?? 'Ocurrió un error desconocido.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- Título de la App ---
              Text(
                'MindMirror',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Tu diario emocional',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 50),

              // --- Campo de Email ---
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Email',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // --- Campo de Contraseña ---
              TextField(
                controller: _passwordController,
                obscureText: true, // Oculta la contraseña
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // --- Botón de Iniciar Sesión ---
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: signIn,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Iniciar Sesión',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 15),

              // --- Botón de Crear Cuenta ---
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: createAccount,
                  child: const Text(
                    'Crear una cuenta nueva',
                    style: TextStyle(fontSize: 16, color: Colors.indigo),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
