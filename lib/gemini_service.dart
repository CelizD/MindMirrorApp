// --- Importación ÚNICA Y CORRECTA ---
// Solo necesitamos el paquete oficial de Firebase AI.
import 'package:firebase_ai/firebase_ai.dart';

class GeminiService {
  // --- ¡API KEY ELIMINADA! ---
  // La autenticación es automática y segura a través de Firebase.
  final GenerativeModel _model;
  
  // Usaremos este campo en los errores
  static const String _defaultError =
      'Ocurrió un error. Revisa tu conexión a internet y la configuración de Firebase.';

  // --- Constructor Actualizado ---
  GeminiService()
      // Inicializamos el modelo de forma segura desde la instancia de Firebase
      : _model = FirebaseGenerativeAI.instance.generativeModel(
          // --- ¡MODELO ESTABLE! ---
          // Usamos 'gemini-1.0-pro', el modelo estable
          // con mayor disponibilidad regional en Vertex AI.
          model: 'gemini-1.0-pro',
          
          // --- ¡NUEVO! Especificamos la ubicación ---
          // El error muestra que tu proyecto está en 'us-central1'.
          // Vamos a especificarlo explícitamente.
          location: 'us-central1',
          
          // No se necesita API Key
        );

  // --- Función 1: Para la pantalla de Check-in ---
  Future<String> generateCheckInPrompt(
      String energy, String emotion, String mind) async {
    try {
      final prompt =
          'Genera una pregunta de diario corta y reflexiva (máx 20 palabras) para alguien que se siente $emotion, con energía $energy y una mente $mind. No incluyas un saludo. Solo la pregunta.';

      // Creamos el 'Content' usando el tipo del paquete 'firebase_ai'
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);
      return response.text ?? '¿Cómo te sientes hoy?';
    } catch (e) {
      print('Error al generar prompt de check-in: $e');
      // Usamos el campo _defaultError
      return '$_defaultError\nDetalle: ${e.toString()}';
    }
  }

  // --- Función 2: Para el botón "💡" en HomeScreen ---
  Future<String> generateJournalSuggestion(String mood) async {
    try {
      final prompt =
          'Genera una pregunta de diario corta y reflexiva (máx 20 palabras) para alguien que se siente "$mood". No incluyas un saludo. Solo la pregunta.';

      // Creamos el 'Content' usando el tipo del paquete 'firebase_ai'
      final content = [Content.text(prompt)];

      final response = await _model.generateContent(content);
      return response.text ?? '¿Sobre qué quieres reflexionar hoy?';
    } catch (e) {
      print('Error al generar sugerencia de diario: $e');
      // Usamos el campo _defaultError
      return '$_defaultError\nDetalle: ${e.toString()}';
    }
  }
}