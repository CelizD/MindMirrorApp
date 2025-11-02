import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmirrorapp/auth_gate.dart';
import 'package:mindmirrorapp/firebase_options.dart';
import 'package:mindmirrorapp/notification_service.dart'; // Servicio de notificaciones

void main() async {
  // Asegurarse de que Flutter esté listo antes de inicializar Firebase o notificaciones
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- Inicializar y programar notificaciones ---
  final NotificationService notificationService = NotificationService();
  await notificationService.init(); // Inicializa el plugin y permisos

  try {
    // Intentar programar el recordatorio de las 8 PM
    await notificationService.scheduleDailyReminder();
    print("✅ Notificación diaria programada correctamente.");
  } catch (e) {
    // Si ocurre un error (como falta de permiso para alarmas exactas)
    print("⚠️ Error al programar la notificación: $e");
  }
  // --- Fin de inicialización de notificaciones ---

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
        // Fondo gris suave para consistencia visual
        scaffoldBackgroundColor: Colors.grey[200],
      ),
      home: const AuthGate(), // Controla si mostrar login o pantalla principal
    );
  }
}
