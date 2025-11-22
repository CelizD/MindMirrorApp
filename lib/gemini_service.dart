import 'package:firebase_vertexai/firebase_vertexai.dart';

class GeminiService {
  final GenerativeModel _model;

  // Constructor: Inicializa el modelo Gemini
  GeminiService()
      : _model = FirebaseVertexAI.instanceFor(location: 'us-central1').generativeModel(
          model: 'gemini-2.0-flash-exp',
        );

  // --- 1. Check-in Emocional (Pantalla de Inicio) ---
  // Genera una pregunta reflexiva basada en el estado del usuario
  Future<String> generateCheckInPrompt(
      String energy, String emotion, String mind) async {
    try {
      final prompt =
          '''Actúa como un coach de bienestar emocional empático. 
          El usuario reporta:
          - Energía: $energy
          - Emoción: $emotion
          - Mente: $mind
          
          Genera UNA SOLA pregunta de reflexión profunda y personalizada (máximo 20 palabras) para él.
          Si la energía es baja, sé suave y reconfortante. Si es alta, inspira acción.
          Ejemplo de tono (baja energía): "Con esa energía baja, ¿qué te gustaría soltar hoy?"
          NO incluyas saludos ni comillas. Solo la pregunta.''';

      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      
      return response.text?.trim() ?? '¿Cómo te sientes realmente hoy?';
    } catch (e) {
      print('Error Gemini Check-in: $e');
      return '¿Qué es lo más importante para ti en este momento?';
    }
  }

  // --- 2. Sugerencia General (Uso Genérico) ---
  // Sugerencias rápidas basadas en el estado de ánimo
  Future<String> generateJournalSuggestion(String mood) async {
    try {
      final prompt =
          'Dame una idea breve para escribir en mi diario. Me siento "$mood". Máximo 15 palabras.';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ?? 'Escribe sobre tu momento favorito del día.';
    } catch (e) {
      return 'Describe tu entorno ahora mismo.';
    }
  }

  // --- 3. Generador Creativo (Editor de Diario) ---
  // ESTA ES LA NUEVA FUNCIÓN que necesitas para el botón "¿No sabes qué escribir?"
  Future<String> generateCreativeWritingPrompt() async {
    try {
      final prompt = 
        'Dame una sugerencia creativa, única y profunda para escribir en un diario personal hoy. '
        'Que no sea genérica, sino que invite a la introspección o imaginación. '
        'Máximo 20 palabras. Tono inspirador.';
      
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text?.trim() ?? 'Si pudieras enviar un mensaje a tu yo del pasado, ¿qué le dirías?';
    } catch (e) {
      print('Error Gemini Creative: $e');
      return 'Describe un lugar donde te sientas completamente en paz.';
    }
  }
}