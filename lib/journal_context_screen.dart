import 'package:flutter/material.dart';

class JournalContextScreen extends StatefulWidget {
  final String title;
  final String body;
  final String? moodContext;

  const JournalContextScreen({
    super.key,
    required this.title,
    required this.body,
    this.moodContext,
  });

  @override
  State<JournalContextScreen> createState() => _JournalContextScreenState();
}

class _JournalContextScreenState extends State<JournalContextScreen> {
  // Etiquetas seleccionadas
  final Set<String> _selectedPeople = {};
  final Set<String> _selectedPlaces = {};
  final Set<String> _selectedActivities = {};

  bool _isSaving = false;

  // Datos predefinidos (En una app real, esto podría venir de BBDD o ser dinámico)
  final List<String> _peopleTags = ['Familia', 'Pareja', 'Amigos', 'Compañeros', 'Mascotas', 'Yo solo'];
  final List<String> _placeTags = ['Casa', 'Trabajo', 'Escuela', 'Naturaleza', 'Viaje', 'Gimnasio'];
  final List<String> _activityTags = ['Ejercicio', 'Lectura', 'Descanso', 'Cita', 'Trabajo profundo', 'Meditación'];

  Future<void> _saveEntry() async {
    setState(() => _isSaving = true);

    // SIMULACIÓN DE GUARDADO
    // Aquí llamarías a tu FirestoreService.addEntry(...)
    // pasando widget.title, widget.body, y los sets seleccionados.
    
    await Future.delayed(const Duration(seconds: 2)); // Simulando red

    if (mounted) {
      // Volver al inicio (o mostrar confirmación)
      // Usamos popUntil para volver a la pantalla principal limpiando el stack
      Navigator.of(context).popUntil((route) => route.isFirst);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Entrada guardada en tu MindMirror! 🧠✨'),
          backgroundColor: Colors.indigo,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Añadir Contexto", style: TextStyle(color: Colors.black87)),
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveEntry,
            child: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
              : const Text("Guardar", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "¿Qué acompañó a este momento?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            const Text(
              "Etiquetar tu contexto ayuda a la IA a encontrar patrones en tu bienestar.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            _buildSection("👥 Personas", _peopleTags, _selectedPeople),
            const Divider(height: 40),
            _buildSection("📍 Lugares", _placeTags, _selectedPlaces),
            const Divider(height: 40),
            _buildSection("🏃 Actividades", _activityTags, _selectedActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> options, Set<String> selectedSet) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.indigo)),
        const SizedBox(height: 16),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: options.map((tag) {
            final isSelected = selectedSet.contains(tag);
            return FilterChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (bool selected) {
                setState(() {
                  if (selected) {
                    selectedSet.add(tag);
                  } else {
                    selectedSet.remove(tag);
                  }
                });
              },
              backgroundColor: Colors.white,
              selectedColor: Colors.indigo.shade100,
              checkmarkColor: Colors.indigo,
              labelStyle: TextStyle(
                color: isSelected ? Colors.indigo.shade900 : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.indigo.shade200 : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}