import 'package:google_generative_ai/google_generative_ai.dart';


class GeminiService {
  // -----------------------------------------------------------------
  // --- ¡PON TU API KEY DE GOOGLE AI AQUÍ! ---
  // -----------------------------------------------------------------
  static const String _apiKey = 'AIzaSyBUV_Tchc_mNkaJvCfDvL_J_jvY15CJEEw';

  final GenerativeModel _model;
  static const String _defaultError =
      'Ocurrió un error. ¿Revisaste tu API Key y conexión a internet?';

  GeminiService()
      : _model = GenerativeModel(
          // --- ¡CAMBIO FINAL! ---
          // Usando el modelo 'gemini-pro' que es más estable y compatible.
          model: 'gemini-pro',
          apiKey: _apiKey,
        );

  // --- Función 1: Para la pantalla de Check-in ---
  Future<String> generateCheckInPrompt(
      String energy, String emotion, String mind) async {
    // --- Comprobación MEJORADA ---
    if (_apiKey.startsWith('TU_API_KEY')) {
      return 'Error: API Key de Gemini no configurada en lib/gemini_service.dart';
    }

    try {
      final prompt =
          'Genera una pregunta de diario corta y reflexiva (máx 20 palabras) para alguien que se siente $emotion, con energía $energy y una mente $mind. No incluyas un saludo. Solo la pregunta.';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '¿Cómo te sientes hoy?';
    } catch (e) {
      // --- Error MEJORADO ---
      // Ahora te dirá el error real de la API
      print('Error al generar prompt de check-in: $e');
      return 'Error al contactar la IA: ${e.toString()}';
    }
  }

  // --- Función 2: Para el botón "💡" en HomeScreen ---
  Future<String> generateJournalSuggestion(String mood) async {
    // --- Comprobación MEJORADA ---
    if (_apiKey.startsWith('TU_API_KEY')) {
      return 'Error: API Key de Gemini no configurada en lib/gemini_service.dart';
    }

    try {
      final prompt =
          'Genera una pregunta de diario corta y reflexiva (máx 20 palabras) para alguien que se siente "$mood". No incluyas un saludo. Solo la pregunta.';
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      return response.text ?? '¿Sobre qué quieres reflexionar hoy?';
    } catch (e) {
      // --- Error MEJORADO ---
      print('Error al generar sugerencia de diario: $e');
      return 'Error al contactar la IA: ${e.toString()}';
    }
  }

  // Esta función estaba en tu archivo de ejemplo, la mantengo
  // pero no la estamos usando por ahora.
  Future generatePrompt(String s, String t, String u) async {}
}

