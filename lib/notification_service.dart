import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton: una sola instancia global
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() => _notificationService;

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // --- Inicializar zona horaria ---
    tz.initializeTimeZones(); // <-- Corrección de la última vez (sin await)

    // --- Configuración Android ---
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/notification_icon');

    // --- Configuración iOS ---
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Pedir permisos (Android 13+)
    await _requestAndroidPermissions();
  }

  Future<void> _requestAndroidPermissions() async {
    final plugin = flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  // --- (MODIFICADO) Programar notificación con hora personalizada ---
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // --- ✅ ¡NUEVA LÍNEA! ---
    // Asegúrate de que la zona horaria esté inicializada antes de usar tz.local
    tz.initializeTimeZones();

    // Cancela cualquier notificación anterior para evitar duplicados
    await flutterLocalNotificationsPlugin.cancelAll();

    final nextInstance = _nextInstanceOf(time);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '¡Es hora de tu registro diario!',
      'Tómate un momento para registrar cómo te sientes en MindMirror.',
      nextInstance,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'mindmirror_daily_reminder_channel',
          'Recordatorio Diario',
          channelDescription:
              'Recordatorio diario para registrar el estado de ánimo.',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@drawable/notification_icon',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    debugPrint(
        "Notificación programada para las ${time.hour}:${time.minute} sin alarma exacta.");
  }

  // --- (MODIFICADO) Calcula la próxima ocurrencia de la hora seleccionada ---
  tz.TZDateTime _nextInstanceOf(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local); // <-- Esta línea causaba el error
    tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, time.hour, time.minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}

