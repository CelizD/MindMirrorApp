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
    tz.initializeTimeZones();

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

  // --- Programar notificación diaria sin alarmas exactas ---
  Future<void> scheduleDailyReminder() async {
    final next8PM = _nextInstanceOf8PM();

    await flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      '¡Es hora de tu registro diario!',
      'Tómate un momento para registrar cómo te sientes en MindMirror.',
      next8PM,
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
      // 🔹 AQUÍ el cambio clave:
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    print("Notificación programada para las 8 PM sin alarma exacta.");
  }

  tz.TZDateTime _nextInstanceOf8PM() {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, 20);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
