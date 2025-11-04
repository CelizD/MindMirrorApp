import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mindmirrorapp/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _selectedTime;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSavedTime();
  }

  // Carga la hora guardada de SharedPreferences
  Future<void> _loadSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    // Default a 20:00 (8 PM) si no hay nada guardado
    final hour = prefs.getInt('reminder_hour') ?? 20;
    final minute = prefs.getInt('reminder_minute') ?? 0;

    if (mounted) {
      setState(() {
        _selectedTime = TimeOfDay(hour: hour, minute: minute);
        _isLoading = false;
      });
    }
  }

  // Muestra el TimePicker y guarda la selección
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 20, minute: 0),
    );

    if (picked != null && picked != _selectedTime) {
      // Guardar en SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', picked.hour);
      await prefs.setInt('reminder_minute', picked.minute);

      // (Re)programar la notificación
      try {
        await NotificationService().scheduleDailyReminder(picked);

        if (mounted) {
          setState(() {
            _selectedTime = picked;
          });
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Recordatorio actualizado'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar recordatorio: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuración'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[200],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ListTile(
                  leading: const Icon(Icons.notifications_active_outlined,
                      color: Colors.indigo),
                  title: const Text(
                    'Hora del recordatorio',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                  ),
                  subtitle: Text(
                    'Se te recordará diariamente a esta hora.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: Text(
                    // Formatea la hora
                    _selectedTime!.format(context),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  onTap: () => _selectTime(context),
                ),
                const Divider(),
              ],
            ),
    );
  }
}

