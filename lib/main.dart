import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmirrorapp/auth_gate.dart';
import 'package:mindmirrorapp/firebase_options.dart';
import 'package:mindmirrorapp/notification_service.dart'; // (NUEVO) Importar servicio

void main() async {
  // Asegurarse de que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- (NUEVO) Inicializar y programar notificaciones ---
  final NotificationService notificationService = NotificationService();
  await notificationService.init(); // Prepara el servicio
  await notificationService.scheduleDailyReminder(); // Programa el recordatorio de las 8 PM
  // --- Fin del código nuevo ---

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MindMirror',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        // (NUEVO) Fondo gris para consistencia
        scaffoldBackgroundColor: Colors.grey[200], 
      ),
      home: const AuthGate(), // El AuthGate decide si mostrar Login o Home
    );
  }
}

