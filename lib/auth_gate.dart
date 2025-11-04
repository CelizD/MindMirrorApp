import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'home_screen.dart'; // Ya no se usa aquí directamente
import 'login_screen.dart';
import 'main_scaffold.dart'; // <-- IMPORT clave para la nueva navegación

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        // Escucha en tiempo real los cambios de autenticación
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // 1️⃣ Mientras se conecta al stream → muestra un indicador de carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.indigo,
                strokeWidth: 3,
              ),
            );
          }

          // 2️⃣ Si ocurre un error → mostrar un mensaje claro
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                '⚠️ Ocurrió un error al conectar con el servidor.\nIntenta de nuevo más tarde.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          // 3️⃣ Si hay un usuario autenticado → ir a MainScaffold (nuestra nueva base)
          if (snapshot.hasData) {
            return const MainScaffold(); // <-- ESTE ES EL CAMBIO
          }

          // 4️⃣ Si no hay sesión iniciada → mostrar LoginScreen
          return const LoginScreen();
        },
      ),
    );
  }
}

