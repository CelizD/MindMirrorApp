import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        // StreamBuilder escucha constantemente los cambios en el estado de autenticación
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1. Si está procesando, muestra un círculo de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Si el snapshot TIENE DATOS, significa que el usuario está logueado
          if (snapshot.hasData) {
            // Muestra la pantalla principal de la app
            return const HomeScreen();
          }

          // 3. Si no tiene datos, el usuario no está logueado
          // Muestra la pantalla de inicio de sesión
          return const LoginScreen();
        },
      ),
    );
  }
}
