import 'package:flutter/material.dart';
import 'package:mindmirrorapp/main_scaffold.dart';
import 'gemini_service.dart'; // Importa el NUEVO servicio

class CheckInScreen extends StatefulWidget {
  const CheckInScreen({super.key});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  String _energy = 'media';
  String _emotion = 'neutral';
  String _mind = 'normal';
  bool _isLoading = false;

  final GeminiService _geminiService = GeminiService();

  Future<void> _generatePromptAndNavigate() async {
    setState(() => _isLoading = true);
    String generatedQuestion = '¿Cómo te sientes hoy?'; // Pregunta por defecto

    try {
      // ¡Llama al NUEVO GeminiService!
      // Este ya no usa la API Key, llama a tu Cloud Function.
      generatedQuestion = await _geminiService.generateCheckInPrompt(
        _energy,
        _emotion,
        _mind,
      );
    } catch (e) {
      print('Error al llamar a la Cloud Function: $e');
      // Si falla, usamos la pregunta por defecto
    }

    if (mounted) {
      // Navega al MainScaffold y le pasa la pregunta
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainScaffold(
            generatedQuestion: generatedQuestion,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.indigo),
                        SizedBox(height: 20),
                        Text('Generando tu pregunta...',
                            style: TextStyle(fontSize: 16)),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Check-in Rápido',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // --- Pregunta 1: Energía ---
                      _buildQuestion(
                        '¿Cómo está tu nivel de energía?',
                        ['Baja', 'Media', 'Alta'],
                        _energy,
                        (value) => setState(() => _energy = value.toLowerCase()),
                      ),
                      const SizedBox(height: 30),

                      // --- Pregunta 2: Emoción ---
                      _buildQuestion(
                        '¿Qué emoción predomina ahora?',
                        ['Neutral', 'Feliz', 'Triste', 'Ansiosa', 'Enojada'],
                        _emotion,
                        (value) =>
                            setState(() => _emotion = value.toLowerCase()),
                      ),
                      const SizedBox(height: 30),

                      // --- Pregunta 3: Mente ---
                      _buildQuestion(
                        '¿Cómo está tu mente?',
                        ['Normal', 'Distraída', 'Enfocada', 'Nublada'],
                        _mind,
                        (value) => setState(() => _mind = value.toLowerCase()),
                      ),
                      const SizedBox(height: 40),

                      // --- Botón de Continuar ---
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _generatePromptAndNavigate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.indigo,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Continuar',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestion(
      String title, List<String> options, String groupValue, Function(String) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8.0,
          children: options.map((option) {
            final isSelected =
                option.toLowerCase() == groupValue.toLowerCase();
            return ChoiceChip(
              label: Text(option),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) {
                  onChanged(option);
                }
              },
              selectedColor: Colors.indigo[100],
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected ? Colors.indigo : Colors.grey[300]!,
                ),
              ),
              labelStyle: TextStyle(
                color: isSelected ? Colors.indigo[900] : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

