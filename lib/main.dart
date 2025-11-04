import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mindmirrorapp/auth_gate.dart';
import 'package:mindmirrorapp/firebase_options.dart';
import 'package:mindmirrorapp/notification_service.dart'; // Servicio de notificaciones
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  // Asegurarse de que Flutter esté listo
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // --- (MODIFICADO) Inicializar y programar notificaciones ---

  // 1. Cargar la hora guardada (o usar el default)
  final prefs = await SharedPreferences.getInstance();
  final hour = prefs.getInt('reminder_hour') ?? 20; // Default 8 PM
  final minute = prefs.getInt('reminder_minute') ?? 0;
  final TimeOfDay savedTime = TimeOfDay(hour: hour, minute: minute);

  // 2. Inicializar el servicio
  final NotificationService notificationService = NotificationService();
  await notificationService.init(); // Inicializa el plugin y permisos

  // 3. Programar la notificación con la hora guardada
  try {
    // --- ✅ ¡CAMBIO AQUÍ! ---
    // El nombre correcto es scheduleDailyReminder
    await notificationService.scheduleDailyReminder(savedTime);
    debugPrint("✅ Notificación diaria programada (al iniciar) correctamente.");
  } catch (e) {
    debugPrint("⚠️ Error al programar la notificación (al iniciar): $e");
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

