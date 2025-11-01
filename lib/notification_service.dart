import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Instancia Singleton (solo una copia de este servicio)
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- 1. Inicializar Timezone ---
    tz.initializeTimeZones();
    // Opcional: obtener la zona horaria local
    // final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    // tz.setLocalLocation(tz.getLocation(timeZoneName));
    
    // --- 2. Configuración de Android ---
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon'); // Usamos el ícono que creamos

    // --- 3. Configuración de iOS ---
    // (Pedimos permisos en AppDelegate.swift, aquí solo configuramos)
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    // --- 4. Inicialización General ---
    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
    
    // --- 5. Pedir permisos (solo para Android 13+) ---
    // iOS los pide al inicio (en AppDelegate)
    _requestAndroidPermissions();
  }

  // --- (NUEVO) Pedir permisos en Android 13+ ---
  Future<void> _requestAndroidPermissions() async {
    final plugin = flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  // --- 6. La función Mágica: Programar el Recordatorio Diario ---
  Future<void> scheduleDailyReminder() async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      0, // ID de la notificación
      '¡Es hora de tu registro diario!', // Título
      'Tómate un momento para registrar cómo te sientes en MindMirror.', // Cuerpo
      _nextInstanceOf8PM(), // Llama a la función que calcula las 8 PM
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindmirror_daily_reminder_channel', // ID del canal
          'Recordatorio Diario', // Nombre del canal
          channelDescription: 'Recordatorio diario para registrar el estado de ánimo.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/notification_icon',
        ),
        iOS: DarwinNotificationDetails(
          sound: 'default.wav',
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time, // ¡Repetir todos los días a esta hora!
    );
    print("Notificación programada para las 8 PM, todos los días.");
  }

  // --- 7. Helper: Calcular la próxima vez que sean las 8 PM ---
  tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20); // 20 = 8 PM
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1)); // Si ya pasaron las 8 PM, programar para mañana
    }
    return scheduledDate;
  }
}
